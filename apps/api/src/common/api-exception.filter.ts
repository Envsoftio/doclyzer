import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import type { Request, Response } from 'express';
import { getCorrelationId } from './correlation-id.middleware';

@Catch()
export class ApiExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger(ApiExceptionFilter.name);

  catch(exception: unknown, host: ArgumentsHost): void {
    const ctx = host.switchToHttp();
    const req = ctx.getRequest<Request>();
    const res = ctx.getResponse<Response>();
    const correlationId = getCorrelationId(req);

    let status: number = HttpStatus.INTERNAL_SERVER_ERROR;
    let code = 'INTERNAL_ERROR';
    let message = 'An unexpected error occurred';
    let extraKeys: Record<string, unknown> = {};

    if (exception instanceof HttpException) {
      status = exception.getStatus();
      const response = exception.getResponse();

      if (
        typeof response === 'object' &&
        response !== null &&
        'code' in response &&
        'message' in response
      ) {
        const typed = response as Record<string, unknown>;
        code = typed.code as string;
        message = typed.message as string;
        // Whitelist extra keys allowed in error response (e.g. existingReport for 409 duplicate).
        const allowedExtraKeys = ['existingReport'];
        for (const key of allowedExtraKeys) {
          if (key in typed && typed[key] !== undefined) {
            extraKeys[key] = typed[key];
          }
        }
      } else if (typeof response === 'string') {
        message = response;
      }
    } else if (exception instanceof Error) {
      this.logger.error(
        `Unhandled error: ${exception.name}`,
        undefined,
        `correlationId=${correlationId}`,
      );
    }

    if (status >= 500) {
      this.logger.error(
        `Request failed with server error status=${status} path=${req.path}`,
        undefined,
        `correlationId=${correlationId} code=${code}`,
      );
    } else {
      this.logger.warn(
        `Request failed status=${status} path=${req.path}`,
        `correlationId=${correlationId} code=${code}`,
      );
    }

    const body: Record<string, unknown> = {
      success: false,
      error: {
        code,
        message,
      },
      correlationId,
      ...extraKeys,
    };

    res.status(status).json(body);
  }
}
