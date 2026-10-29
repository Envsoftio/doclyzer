import { spawn } from 'node:child_process';
import { resolve } from 'node:path';

const node = process.execPath;
const nest = resolve('node_modules/@nestjs/cli/bin/nest.js');
const tsNode = resolve('node_modules/ts-node/dist/bin.js');

const processes = [
  {
    name: 'api',
    command: node,
    args: [nest, 'start', '--watch', '--entryFile', 'apps/api/src/main'],
    env: { REPORT_PROCESS_ROLE: 'api' },
  },
  {
    name: 'report-worker',
    command: node,
    args: [tsNode, '--files', 'src/report-worker.ts'],
    env: {
      REPORT_ASYNC_RUNTIME_ENABLED: 'true',
      REPORT_ASYNC_ACCEPTANCE_ENABLED: 'false',
      REPORT_PROCESS_ROLE: 'worker',
    },
  },
  {
    // The report dispatcher also consumes queued push campaigns.
    name: 'report-dispatcher',
    command: node,
    args: [tsNode, '--files', 'src/report-worker.ts'],
    env: {
      REPORT_ASYNC_RUNTIME_ENABLED: 'true',
      REPORT_ASYNC_ACCEPTANCE_ENABLED: 'false',
      REPORT_PROCESS_ROLE: 'dispatcher',
    },
  },
];

const children = new Map();
let shuttingDown = false;

function stop(signal = 'SIGTERM', exitCode = 0) {
  if (shuttingDown) return;
  shuttingDown = true;
  for (const child of children.values()) {
    if (!child.killed) child.kill(signal);
  }
  const forceTimer = setTimeout(() => {
    for (const child of children.values()) {
      if (!child.killed) child.kill('SIGKILL');
    }
  }, 5000);
  forceTimer.unref();
  process.exitCode = exitCode;
}

for (const spec of processes) {
  const child = spawn(spec.command, spec.args, {
    cwd: process.cwd(),
    env: { ...process.env, ...spec.env },
    stdio: 'inherit',
  });
  children.set(spec.name, child);
  child.once('error', (error) => {
    console.error(`[dev-stack] ${spec.name} failed to start: ${error.message}`);
    stop('SIGTERM', 1);
  });
  child.once('exit', (code, signal) => {
    children.delete(spec.name);
    if (!shuttingDown) {
      console.error(
        `[dev-stack] ${spec.name} stopped unexpectedly (${signal ?? `exit ${code ?? 1}`})`,
      );
      stop('SIGTERM', code && code > 0 ? code : 1);
    }
  });
}

process.once('SIGINT', () => stop('SIGINT'));
process.once('SIGTERM', () => stop('SIGTERM'));
