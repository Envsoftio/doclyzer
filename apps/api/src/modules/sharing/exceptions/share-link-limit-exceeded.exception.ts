import { ForbiddenException } from '@nestjs/common';
import { SHARE_LINK_LIMIT_EXCEEDED } from '../sharing.types';

export interface ShareLinkLimitExceededData {
  limit: number;
  current: number;
  planName: string;
  tier: string;
  upgradeHint: string;
}

export class ShareLinkLimitExceededException extends ForbiddenException {
  constructor(data: ShareLinkLimitExceededData) {
    const baseMessage =
      data.tier === 'free'
        ? `Free plan allows ${data.limit} active share link. Upgrade to Pro for more.`
        : `${data.planName} plan allows ${data.limit} active share links. Manage your plan in Billing.`;
    super({
      code: SHARE_LINK_LIMIT_EXCEEDED,
      message: baseMessage,
      data,
    });
  }
}
