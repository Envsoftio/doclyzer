import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { mkdtemp, readFile, readdir, rm, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { extname, join } from 'node:path';
import { spawn } from 'node:child_process';
import { redactSecrets } from '../../common/redact-secrets';

@Injectable()
export class OpenDataLoaderClient {
  private readonly logger = new Logger(OpenDataLoaderClient.name);

  constructor(private readonly configService: ConfigService) {}

  async parsePdf(
    buffer: Buffer,
  ): Promise<{ text: string; parsedJson?: unknown } | null> {
    const enabled =
      this.configService.get<boolean>('reports.opendataloaderEnabled') ?? false;
    if (!enabled) return null;

    const command =
      this.configService.get<string>('reports.opendataloaderCliCommand') ??
      'opendataloader-pdf';
    const timeoutMs =
      this.configService.get<number>('reports.opendataloaderTimeoutMs') ??
      120_000;
    const extraArgsRaw =
      this.configService.get<string>('reports.opendataloaderExtraArgs') ?? '';
    const extraArgs = extraArgsRaw
      .split(' ')
      .map((p) => p.trim())
      .filter((p) => p.length > 0);

    const workDir = await mkdtemp(join(tmpdir(), 'odl-'));
    const inputPath = join(workDir, 'report.pdf');
    const outputDir = join(workDir, 'out');

    try {
      await writeFile(inputPath, buffer);

      const args = [
        inputPath,
        '--output-dir',
        outputDir,
        '--format',
        'markdown,json',
        '--image-output',
        'external',
        ...extraArgs,
      ];

      await this.runCommand(command, args, timeoutMs);
      const json = await this.readLargestFileByExtension(outputDir, '.json');
      let parsedJson: unknown;
      if (json) {
        try {
          parsedJson = JSON.parse(json);
        } catch {
          parsedJson = undefined;
        }
        // Disabled for now: full parser JSON is too large/noisy in logs.
        // this.logger.log(
        //   JSON.stringify({
        //     action: 'OPENDATALOADER_PARSED_JSON',
        //     parsedJson: parsedJson ?? json,
        //   }),
        // );
      }
      const markdown = await this.readLargestMarkdown(outputDir);
      if (!markdown) {
        this.logger.warn(
          'OpenDataLoader completed but no markdown output file was found',
        );
        return null;
      }
      return { text: markdown, ...(parsedJson ? { parsedJson } : {}) };
    } catch (err) {
      this.logger.warn(
        redactSecrets(
          `OpenDataLoader parse failed: ${err instanceof Error ? err.message : String(err)}`,
        ),
      );
      return null;
    } finally {
      await rm(workDir, { recursive: true, force: true }).catch(
        () => undefined,
      );
    }
  }

  private runCommand(
    command: string,
    args: string[],
    timeoutMs: number,
  ): Promise<void> {
    return new Promise((resolve, reject) => {
      const child = spawn(command, args, { stdio: ['ignore', 'pipe', 'pipe'] });
      let stderr = '';
      let stdout = '';
      const timer = setTimeout(() => {
        child.kill('SIGKILL');
        reject(
          new Error(`OpenDataLoader command timed out after ${timeoutMs}ms`),
        );
      }, timeoutMs);

      child.stdout.on('data', (chunk: Buffer) => {
        stdout += chunk.toString('utf8');
      });
      child.stderr.on('data', (chunk: Buffer) => {
        stderr += chunk.toString('utf8');
      });

      child.on('error', (err) => {
        clearTimeout(timer);
        reject(err);
      });

      child.on('close', (code) => {
        clearTimeout(timer);
        if (code === 0) {
          resolve();
          return;
        }
        reject(
          new Error(
            `OpenDataLoader exited with code ${code}. stdout=${stdout.slice(0, 300)} stderr=${stderr.slice(0, 500)}`,
          ),
        );
      });
    });
  }

  private async readLargestMarkdown(dir: string): Promise<string | null> {
    return this.readLargestFileByExtension(dir, '.md');
  }

  private async readLargestFileByExtension(
    dir: string,
    ext: string,
  ): Promise<string | null> {
    const files = await this.listFilesRecursive(dir);
    const matched = files.filter((p) => extname(p).toLowerCase() === ext);
    if (matched.length === 0) return null;

    let best: { path: string; size: number } | null = null;
    for (const path of matched) {
      const content = await readFile(path, 'utf8');
      const size = content.trim().length;
      if (!best || size > best.size) {
        best = { path, size };
      }
    }
    if (!best || best.size === 0) return null;
    return readFile(best.path, 'utf8');
  }

  private async listFilesRecursive(root: string): Promise<string[]> {
    const out: string[] = [];
    const stack = [root];
    while (stack.length > 0) {
      const current = stack.pop()!;
      const entries = await readdir(current, { withFileTypes: true });
      for (const entry of entries) {
        const full = join(current, entry.name);
        if (entry.isDirectory()) {
          stack.push(full);
        } else if (entry.isFile()) {
          out.push(full);
        }
      }
    }
    return out;
  }
}
