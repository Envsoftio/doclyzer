import {
  BadRequestException,
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
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
import { diskStorage } from 'multer';
import { extname, join } from 'path';
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

@Controller('account')
@UseGuards(AuthGuard)
export class AccountController {
  constructor(private readonly accountService: AccountService) {}

  @Get('restriction')
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
      storage: diskStorage({
        destination: join(process.cwd(), 'uploads', 'avatars'),
        filename: (_req, file, cb) => {
          const unique = `${Date.now()}-${Math.round(Math.random() * 1e9)}`;
          cb(null, `${unique}${extname(file.originalname)}`);
        },
      }),
      fileFilter: (_req, file, cb) => {
        if (!file.mimetype.match(/^image\//)) {
          cb(new BadRequestException('Only image files are allowed'), false);
        } else {
          cb(null, true);
        }
      },
      limits: { fileSize: 5 * 1024 * 1024 },
    }),
  )
  async uploadAvatar(
    @UploadedFile() file: Express.Multer.File,
    @Req() req: Request,
  ): Promise<object> {
    if (!file) throw new BadRequestException('No file uploaded');
    const { id: userId } = req.user as RequestUser;
    const avatarUrl = `/uploads/avatars/${file.filename}`;
    const data = await this.accountService.updateAvatar(userId, avatarUrl);
    return successResponse(data, getCorrelationId(req));
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
