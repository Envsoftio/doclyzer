import { ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import type { NestExpressApplication } from '@nestjs/platform-express';
import { join, mkdirSync } from 'path';
import { AppModule } from './app.module';
import { ApiExceptionFilter } from './common/api-exception.filter';
import { correlationIdMiddleware } from './common/correlation-id.middleware';

async function bootstrap() {
  const app = await NestFactory.create<NestExpressApplication>(AppModule);
  app.getHttpAdapter().getInstance().set('trust proxy', 1);

  const uploadsDir = join(process.cwd(), 'uploads', 'avatars');
  mkdirSync(uploadsDir, { recursive: true });
  app.useStaticAssets(join(process.cwd(), 'uploads'), { prefix: '/uploads' });

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
