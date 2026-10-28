import { MigrationInterface, QueryRunner } from 'typeorm';

export class CompletePushNotifications1730819400000 implements MigrationInterface {
  async up(q: QueryRunner): Promise<void> {
    await q.query(`
      ALTER TABLE user_device_tokens ADD COLUMN notification_permission varchar(24) NOT NULL DEFAULT 'unknown',
        ADD COLUMN token_updated_at timestamptz NOT NULL DEFAULT now();
      UPDATE user_device_tokens SET installation_id=NULL WHERE trim(installation_id)='';
      WITH ranked AS (SELECT id,row_number() OVER (PARTITION BY installation_id ORDER BY last_seen_at DESC,id) n
        FROM user_device_tokens WHERE installation_id IS NOT NULL)
      UPDATE user_device_tokens SET installation_id=NULL,active=false,disabled_at=now()
        WHERE id IN (SELECT id FROM ranked WHERE n>1);
      CREATE UNIQUE INDEX "UQ_push_installation" ON user_device_tokens(installation_id) WHERE installation_id IS NOT NULL;
      ALTER TABLE account_preferences ADD COLUMN marketing_push_enabled boolean NOT NULL DEFAULT false;
      CREATE TABLE push_campaigns (
        id uuid PRIMARY KEY REFERENCES push_send_audit(id) ON DELETE CASCADE,
        name varchar(120) NOT NULL,
        deep_link varchar(255), image_url varchar(2048),
        scheduled_at timestamptz, started_at timestamptz, completed_at timestamptz,
        is_test boolean NOT NULL DEFAULT false,
        cursor uuid,
        materialized boolean NOT NULL DEFAULT false,
        created_at timestamptz NOT NULL DEFAULT now()
      );
      CREATE INDEX ON push_campaigns(scheduled_at) WHERE completed_at IS NULL;
      CREATE TABLE push_recipients (
        id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
        campaign_id uuid NOT NULL REFERENCES push_campaigns(id) ON DELETE CASCADE,
        user_id uuid REFERENCES users(id) ON DELETE SET NULL,
        device_id uuid REFERENCES user_device_tokens(id) ON DELETE SET NULL,
        platform varchar(24) NOT NULL,
        status varchar(24) NOT NULL DEFAULT 'queued',
        attempts integer NOT NULL DEFAULT 0,
        available_at timestamptz NOT NULL DEFAULT now(),
        lease_token uuid, lease_until timestamptz,
        provider_message_id varchar(255), failure_code varchar(96),
        accepted_at timestamptz, received_at timestamptz, opened_at timestamptz, actioned_at timestamptz,
        created_at timestamptz NOT NULL DEFAULT now(),
        UNIQUE(campaign_id,device_id)
      );
      CREATE INDEX ON push_recipients(status,available_at);
      CREATE TABLE push_events (
        id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
        campaign_id uuid REFERENCES push_campaigns(id) ON DELETE CASCADE,
        recipient_id uuid REFERENCES push_recipients(id) ON DELETE CASCADE,
        actor_id uuid REFERENCES users(id) ON DELETE SET NULL,
        event_type varchar(48) NOT NULL,
        metadata jsonb NOT NULL DEFAULT '{}',
        created_at timestamptz NOT NULL DEFAULT now()
      );
      CREATE INDEX ON push_events(campaign_id,created_at);
      CREATE UNIQUE INDEX ON push_events(recipient_id,event_type)
        WHERE event_type IN ('received','opened','deep_link_opened','converted');
    `);
  }
  async down(q: QueryRunner): Promise<void> {
    await q.query(`DROP TABLE push_events; DROP TABLE push_recipients; DROP TABLE push_campaigns;
      ALTER TABLE account_preferences DROP COLUMN marketing_push_enabled;
      DROP INDEX "UQ_push_installation";
      ALTER TABLE user_device_tokens DROP COLUMN notification_permission, DROP COLUMN token_updated_at;`);
  }
}
