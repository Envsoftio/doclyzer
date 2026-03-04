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
