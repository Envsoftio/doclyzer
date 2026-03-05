export interface RegisterRequest {
  email: string;
  password: string;
  policyAccepted: boolean;
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
