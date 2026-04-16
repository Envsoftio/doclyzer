import { Logger, ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import type { NestExpressApplication } from '@nestjs/platform-express';
import { inspect } from 'node:util';
import { AppModule } from './app.module';
import { ApiExceptionFilter } from './common/api-exception.filter';
import { correlationIdMiddleware } from './common/correlation-id.middleware';
import { redactSecrets } from './common/redact-secrets';

const logger = new Logger('Bootstrap');

async function bootstrap() {
  const app = await NestFactory.create<NestExpressApplication>(AppModule, {
    rawBody: true,
  });
  app.getHttpAdapter().getInstance().set('trust proxy', 1);

  const corsOrigins = (
    process.env.CORS_ALLOWED_ORIGINS ??
    'http://localhost:3001,http://localhost:3000'
  )
    .split(',')
    .map((origin) => origin.trim())
    .filter((origin) => origin.length > 0);
  app.enableCors({
    origin: corsOrigins,
    credentials: true,
    methods: ['GET', 'HEAD', 'PUT', 'PATCH', 'POST', 'DELETE', 'OPTIONS'],
  });

  app.use(correlationIdMiddleware);
  // DEFAULT-DENY BODY LOGGING POLICY: No middleware or interceptor logs raw
  // request/response bodies. PHI-bearing endpoints must not expose clinical
  // or personal data in operational logs. See ApiExceptionFilter for details.
  app.useGlobalFilters(new ApiExceptionFilter());
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: false,
      transform: true,
    }),
  );
  app.setGlobalPrefix('v1');
  await app.listen(process.env.PORT ?? 3000);
}

bootstrap().catch((err: unknown) => {
  const msg =
    err instanceof Error
      ? err.message
      : typeof err === 'string'
        ? err
        : err != null
          ? inspect(err, { depth: 1, breakLength: 120 })
          : 'Unknown';
  logger.error(redactSecrets(`Bootstrap failed: ${msg}`));
  process.exit(1);
});
