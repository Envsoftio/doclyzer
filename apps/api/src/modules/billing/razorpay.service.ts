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
    this.keyId = this.configService.get<string>('razorpay.keyId', '');
    this.keySecret = this.configService.get<string>('razorpay.keySecret', '');
    this.webhookSecret = this.configService.get<string>(
      'razorpay.webhookSecret',
      '',
    );

    this.instance = new Razorpay({
      key_id: this.keyId,
      key_secret: this.keySecret,
    });
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
