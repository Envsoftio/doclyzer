export interface RegisterRequest {
  email: string;
  password: string;
}

export interface RegisterResponse {
  userId: string;
  requiresVerification: boolean;
  nextStep: 'verify_then_login';
}

export interface LoginRequest {
  email: string;
  password: string;
}

export interface LoginResponse {
  accessToken: string;
  refreshToken: string;
  tokenType: 'Bearer';
  accessTokenExpiresInSec: number;
  refreshTokenExpiresInSec: number;
}

export interface AuthUser {
  id: string;
  email: string;
  passwordHash: string;
  displayName: string | null;
  createdAt: Date;
}

export interface AuthSession {
  sessionId: string;
  userId: string;
  accessToken: string;
  refreshToken: string;
  accessExpiresAt: Date;
  refreshExpiresAt: Date;
  revokedAt?: Date;
  createdAt: Date;
  /** Set at login for device session list (story 1.7) */
  ip?: string;
  userAgent?: string;
}

export interface RefreshRequest {
  refreshToken: string;
}

export interface ForgotPasswordRequest {
  email: string;
}

export interface ForgotPasswordResponse {
  message: string;
}

export interface ResetPasswordRequest {
  token: string;
  newPassword: string;
}

export interface ResetPasswordResponse {
  message: string;
}

// Device session list/revoke (story 1.7)
export interface DeviceSessionData {
  userId: string;
  sessionId: string;
  ip: string;
  userAgent: string;
  createdAt: string;
}

export interface DeviceSessionSummary {
  sessionId: string;
  ip: string;
  userAgent: string;
  createdAt: string;
  isCurrent: boolean;
}

export const SESSION_NOT_FOUND = 'SESSION_NOT_FOUND' as const;

export interface RequestUser {
  id: string;
}
