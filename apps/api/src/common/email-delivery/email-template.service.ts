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
    const renderData = this.withDefaultTemplateData(data);
    const template = await this.loadTemplate(`${templateKey}.hbs`);
    const content = await this.renderHbs(template, renderData);
    const layout = await this.loadTemplate('layouts/default.hbs');
    return this.renderHbs(layout, {
      ...renderData,
      content,
    });
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

  private async renderHbs(
    template: string,
    data: Record<string, string | number | boolean | null>,
  ): Promise<string> {
    const withPartials = await this.expandPartials(template, data);
    return this.interpolate(withPartials, data);
  }

  private async expandPartials(
    template: string,
    data: Record<string, string | number | boolean | null>,
  ): Promise<string> {
    const partialPattern = /{{>\s*([a-zA-Z0-9_-]+)\s*}}/g;
    let rendered = '';
    let lastIndex = 0;

    for (const match of template.matchAll(partialPattern)) {
      rendered += template.slice(lastIndex, match.index);
      const partialName = match[1];
      const partial = await this.loadTemplate(`partials/${partialName}.hbs`);
      rendered += this.interpolate(partial, data);
      lastIndex = (match.index ?? 0) + match[0].length;
    }

    rendered += template.slice(lastIndex);
    return rendered;
  }

  private withDefaultTemplateData(
    data: Record<string, string | number | boolean | null>,
  ): Record<string, string | number | boolean | null> {
    return {
      brandName: 'Doclyzer',
      previewText: 'A secure update from Doclyzer',
      supportUrl: 'https://doclyzer.com/support',
      currentYear: new Date().getUTCFullYear(),
      ...data,
    };
  }

  private interpolate(
    template: string,
    data: Record<string, string | number | boolean | null>,
  ): string {
    const withRawBlocks = template.replace(
      /{{{\s*([a-zA-Z0-9_]+)\s*}}}/g,
      (_m: string, key: string) => this.valueFor(data, key),
    );

    return withRawBlocks.replace(
      /{{\s*([a-zA-Z0-9_]+)\s*}}/g,
      (_m: string, key: string) => this.escapeHtml(this.valueFor(data, key)),
    );
  }

  private valueFor(
    data: Record<string, string | number | boolean | null>,
    key: string,
  ): string {
    const raw = data[key];
    return raw === null || raw === undefined ? '' : String(raw);
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
