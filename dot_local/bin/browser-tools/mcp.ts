import { spawn, type ChildProcess } from 'node:child_process';
import { mkdirSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { chromium } from 'playwright';

const root: string = fileURLToPath(new URL('.', import.meta.url));
const output: string = `${root}output`;
mkdirSync(output, { recursive: true });

const child: ChildProcess = spawn(process.execPath, [
  `${root}node_modules/@playwright/mcp/cli.js`,
  '--headless',
  '--isolated',
  '--executable-path', chromium.executablePath(),
  '--output-dir', output,
], { stdio: 'inherit', cwd: root });

const signals: NodeJS.Signals[] = ['SIGINT', 'SIGTERM'];
signals.forEach((signal: NodeJS.Signals): void => {
  process.on(signal, (): void => { child.kill(signal); });
});
child.on('error', (error: Error): void => {
  console.error(error.message);
  process.exitCode = 1;
});
child.on('exit', (code: number | null): void => {
  process.exitCode = code ?? 1;
});
