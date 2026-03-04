import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ApiExceptionFilter } from './common/api-exception.filter';
import { correlationIdMiddleware } from './common/correlation-id.middleware';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.use(correlationIdMiddleware);
  app.useGlobalFilters(new ApiExceptionFilter());
  app.setGlobalPrefix('v1');
  await app.listen(process.env.PORT ?? 3000);
}
void bootstrap();
