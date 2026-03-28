import { Logger, ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import type { NestExpressApplication } from '@nestjs/platform-express';
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

  app.use(correlationIdMiddleware);
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
    err instanceof Error ? err.message : err != null ? String(err) : 'Unknown';
  logger.error(redactSecrets(`Bootstrap failed: ${msg}`));
  process.exit(1);
});
