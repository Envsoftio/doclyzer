import { randomUUID } from 'node:crypto';
import type { NextFunction, Request, Response } from 'express';

export function correlationIdMiddleware(
  req: Request,
  res: Response,
  next: NextFunction,
): void {
  const incomingCorrelationId = req.header('x-correlation-id');
  const correlationId =
    incomingCorrelationId && incomingCorrelationId.trim().length > 0
      ? incomingCorrelationId
      : randomUUID();

  req.correlationId = correlationId;
  res.setHeader('x-correlation-id', correlationId);
  next();
}

export function getCorrelationId(req: Request): string {
  return req.correlationId ?? randomUUID();
}
