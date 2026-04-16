import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { promises as fs } from 'node:fs';
import { join } from 'node:path';

@Injectable()
export class EmailTemplateService {
  private readonly templatesPath: string;

  constructor(private readonly configService: ConfigService) {
    this.templatesPath = this.configService.getOrThrow<string>(
      'email.templatesPath',
    );
  }

  async renderHtml(
    templateKey: string,
    data: Record<string, string | number | boolean | null> = {},
  ): Promise<string> {
    const template = await this.loadTemplate(`${templateKey}.html`);
    return this.interpolate(template, data, true);
  }

  async renderText(
    templateKey: string,
    data: Record<string, string | number | boolean | null> = {},
  ): Promise<string> {
    const html = await this.renderHtml(templateKey, data);
    return this.stripHtml(html);
  }

  private async loadTemplate(fileName: string): Promise<string> {
    const path = join(this.templatesPath, fileName);
    return fs.readFile(path, 'utf8');
  }

  private interpolate(
    template: string,
    data: Record<string, string | number | boolean | null>,
    escapeHtml: boolean,
  ): string {
    return template.replace(
      /{{\s*([a-zA-Z0-9_]+)\s*}}/g,
      (_m: string, key: string) => {
        const raw = data[key];
        const value = raw === null || raw === undefined ? '' : String(raw);
        return escapeHtml ? this.escapeHtml(value) : value;
      },
    );
  }

  private escapeHtml(value: string): string {
    return value
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#39;');
  }

  private stripHtml(value: string): string {
    return value
      .replace(/<\s*br\s*\/?>/gi, '\n')
      .replace(/<\s*\/p\s*>/gi, '\n')
      .replace(/<[^>]+>/g, '')
      .replace(/&nbsp;/gi, ' ')
      .replace(/&amp;/gi, '&')
      .replace(/&quot;/gi, '"')
      .replace(/&#39;/gi, "'")
      .replace(/\n{3,}/g, '\n\n')
      .trim();
  }
}
