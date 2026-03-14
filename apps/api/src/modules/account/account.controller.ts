import {
  BadRequestException,
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Inject,
  Patch,
  Param,
  Post,
  Put,
  Req,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { memoryStorage } from 'multer';
import { extname } from 'path';
import type { FileStorageService } from '../../common/storage/file-storage.interface';
import { FILE_STORAGE } from '../../common/storage/storage.module';
import type { Request } from 'express';
import type { Express } from 'express';
import type { RequestUser } from '../../modules/auth/auth.types';
import { AuthGuard } from '../../common/guards/auth.guard';
import { getCorrelationId } from '../../common/correlation-id.middleware';
import { successResponse } from '../../common/response-envelope';
import {
  CreateClosureRequestDto,
  CreateDataExportRequestDto,
  UpdateAccountProfileDto,
  UpdateCommunicationPreferencesDto,
} from './account.dto';
import { AccountService } from './account.service';
import { ExportRequestNotFoundException } from './account.types';
import { AuthService } from '../auth/auth.service';

const ALLOWED_AVATAR_EXTENSIONS = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];

function getClientIp(req: Request): string {
  const forwarded = req.header('x-forwarded-for');
  if (forwarded) return forwarded.split(',')[0].trim();
  return req.ip ?? 'unknown';
}

@Controller('account')
@UseGuards(AuthGuard)
export class AccountController {
  constructor(
    private readonly accountService: AccountService,
    private readonly authService: AuthService,
    @Inject(FILE_STORAGE) private readonly fileStorage: FileStorageService,
  ) {}

  @Get(['restriction', 'restriction-status'])
  async getRestrictionStatus(@Req() req: Request): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const data = await this.accountService.getRestrictionStatus(userId);
    return successResponse(data, getCorrelationId(req));
  }

  @Get('profile')
  async getProfile(@Req() req: Request): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const data = await this.accountService.getProfile(userId);
    return successResponse(data, getCorrelationId(req));
  }

  @Patch('profile')
  @HttpCode(HttpStatus.OK)
  async updateProfile(
    @Body() body: UpdateAccountProfileDto,
    @Req() req: Request,
  ): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const data = await this.accountService.updateProfile(userId, body);
    return successResponse(data, getCorrelationId(req));
  }

  @Get('communication-preferences')
  async getCommunicationPreferences(@Req() req: Request): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const data = await this.accountService.getCommunicationPreferences(userId);
    return successResponse(data, getCorrelationId(req));
  }

  @Put('communication-preferences')
  @HttpCode(HttpStatus.OK)
  async updateCommunicationPreferences(
    @Body() body: UpdateCommunicationPreferencesDto,
    @Req() req: Request,
  ): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const data = await this.accountService.updateCommunicationPreferences(
      userId,
      body,
    );
    return successResponse(data, getCorrelationId(req));
  }

  @Post('data-export-requests')
  @HttpCode(HttpStatus.CREATED)
  async createDataExportRequest(
    @Body() _body: CreateDataExportRequestDto,
    @Req() req: Request,
  ): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const correlationId = getCorrelationId(req);
    const data = await this.accountService.createDataExportRequest(
      userId,
      correlationId,
    );
    return successResponse(data, correlationId);
  }

  @Get('data-export-requests/:requestId')
  async getDataExportRequest(
    @Param('requestId') requestId: string,
    @Req() req: Request,
  ): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const data = await this.accountService.getDataExportRequest(
      userId,
      requestId,
    );
    if (!data) throw new ExportRequestNotFoundException();
    return successResponse(data, getCorrelationId(req));
  }

  @Post('closure-requests')
  @HttpCode(HttpStatus.CREATED)
  async createClosureRequest(
    @Body() body: CreateClosureRequestDto,
    @Req() req: Request,
  ): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const correlationId = getCorrelationId(req);
    const data = await this.accountService.createClosureRequest(
      userId,
      body,
      correlationId,
    );
    return successResponse(data, correlationId);
  }

  @Post('avatar')
  @HttpCode(HttpStatus.OK)
  @UseInterceptors(
    FileInterceptor('avatar', {
      storage: memoryStorage(),
      fileFilter: (_req, file, cb) => {
        if (!file.mimetype.match(/^image\//)) {
          cb(new BadRequestException('Only image files are allowed'), false);
        } else {
          const ext = extname(file.originalname).toLowerCase();
          if (ext && !ALLOWED_AVATAR_EXTENSIONS.includes(ext)) {
            cb(
              new BadRequestException(
                `Invalid file extension. Allowed: ${ALLOWED_AVATAR_EXTENSIONS.join(', ')}`,
              ),
              false,
            );
          } else {
            cb(null, true);
          }
        }
      },
      limits: { fileSize: 5 * 1024 * 1024 },
    }),
  )
  async uploadAvatar(
    @UploadedFile() file: Express.Multer.File,
    @Req() req: Request,
  ): Promise<object> {
    if (!file || !file.buffer)
      throw new BadRequestException('No file uploaded');
    this.authService.enforceRateLimit('avatar-upload', getClientIp(req), 10);
    const { id: userId } = req.user as RequestUser;
    const rawExt = extname(file.originalname).toLowerCase();
    const ext =
      rawExt && ALLOWED_AVATAR_EXTENSIONS.includes(rawExt) ? rawExt : '.jpg';
    const key = `avatars/${userId}${ext}`;
    await this.fileStorage.upload(key, file.buffer, file.mimetype);
    try {
      const data = await this.accountService.updateAvatar(userId, key);
      return successResponse(data, getCorrelationId(req));
    } catch (e) {
      await this.fileStorage.delete(key);
      throw e;
    }
  }

  @Get('closure-request')
  async getClosureRequest(@Req() req: Request): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const data = await this.accountService.getClosureRequest(userId);
    return successResponse(
      { status: data?.status ?? null, request: data },
      getCorrelationId(req),
    );
  }
}
