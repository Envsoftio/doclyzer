declare namespace Express {
  interface Request {
    correlationId?: string;
    user?: import('../modules/auth/auth.types').AuthUser;
  }
}
