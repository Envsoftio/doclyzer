import { ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import type { Express } from 'express';
import { AppModule } from './app.module';
import { ApiExceptionFilter } from './common/api-exception.filter';
import { correlationIdMiddleware } from './common/correlation-id.middleware';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  (app.getHttpAdapter().getInstance() as Express).set('trust proxy', 1);
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
void bootstrap();
