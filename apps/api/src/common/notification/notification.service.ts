export abstract class NotificationService {
  abstract sendPasswordResetToken(
    email: string,
    rawToken: string,
  ): Promise<void>;
}
