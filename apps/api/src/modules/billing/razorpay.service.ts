import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import Razorpay from 'razorpay';
import { createHmac } from 'node:crypto';

@Injectable()
export class RazorpayService {
  private readonly logger = new Logger(RazorpayService.name);
  private readonly instance: Razorpay;
  private readonly keySecret: string;
  private readonly webhookSecret: string;
  readonly keyId: string;

  constructor(private readonly configService: ConfigService) {
    this.keyId = this.getRequiredConfig('keyId', 'RAZORPAY_KEY_ID');
    this.keySecret = this.getRequiredConfig('keySecret', 'RAZORPAY_KEY_SECRET');
    this.webhookSecret = this.getRequiredConfig(
      'webhookSecret',
      'RAZORPAY_WEBHOOK_SECRET',
    );

    this.instance = new Razorpay({
      key_id: this.keyId,
      key_secret: this.keySecret,
    });
  }

  private getRequiredConfig(configKey: string, envVar: string): string {
    const value = this.configService.get<string>(`razorpay.${configKey}`, '');
    if (!value?.trim()) {
      const message =
        `Razorpay configuration missing: ${envVar}. ` +
        'Set the environment variables listed in .env.example.';
      this.logger.error(message);
      throw new Error(message);
    }

    return value;
  }

  async createOrder(
    amount: number,
    currency: string,
    receipt: string,
  ): Promise<{ id: string; amount: number; currency: string }> {
    const order = await this.instance.orders.create({
      amount,
      currency,
      receipt,
    });
    return {
      id: order.id,
      amount: order.amount as number,
      currency: order.currency,
    };
  }

  verifyPaymentSignature(
    orderId: string,
    paymentId: string,
    signature: string,
  ): boolean {
    const expectedSignature = createHmac('sha256', this.keySecret)
      .update(`${orderId}|${paymentId}`)
      .digest('hex');
    return expectedSignature === signature;
  }

  async createSubscription(
    planRazorpayId: string,
    totalCount: number,
    customerId?: string,
  ): Promise<{ id: string }> {
    const options: Record<string, unknown> = {
      plan_id: planRazorpayId,
      total_count: totalCount,
      customer_notify: 0,
    };
    if (customerId) {
      options.customer_id = customerId;
    }
    const subscription = await (
      this.instance as unknown as {
        subscriptions: {
          create: (opts: Record<string, unknown>) => Promise<{ id: string }>;
        };
      }
    ).subscriptions.create(options);
    return { id: subscription.id };
  }

  verifySubscriptionSignature(
    subscriptionId: string,
    paymentId: string,
    signature: string,
  ): boolean {
    // For subscriptions: HMAC-SHA256 of "payment_id|subscription_id"
    const expectedSignature = createHmac('sha256', this.keySecret)
      .update(`${paymentId}|${subscriptionId}`)
      .digest('hex');
    return expectedSignature === signature;
  }

  verifyWebhookSignature(body: string, signature: string): boolean {
    const expectedSignature = createHmac('sha256', this.webhookSecret)
      .update(body)
      .digest('hex');
    return expectedSignature === signature;
  }
}
