import assert from 'node:assert/strict';
import { createServer, type IncomingMessage, type Server, type ServerResponse } from 'node:http';
import type { AddressInfo } from 'node:net';
import { mkdirSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { chromium, type Browser, type Page } from 'playwright';

const output: string = fileURLToPath(new URL('./output/', import.meta.url));
mkdirSync(output, { recursive: true });
const server: Server = createServer((_request: IncomingMessage, response: ServerResponse): void => {
  response.setHeader('Content-Type', 'text/html; charset=utf-8');
  response.end('<!doctype html><title>Browser smoke test</title><label>Name <input></label><button onclick="document.querySelector(\'output\').textContent = document.querySelector(\'input\').value">Test</button><output></output>');
});
let browser: Browser | undefined;
try {
  await new Promise<void>((resolve, reject): void => {
    server.once('error', reject);
    server.listen(0, '127.0.0.1', resolve);
  });
  const address: AddressInfo = server.address() as AddressInfo;
  browser = await chromium.launch({ headless: true, executablePath: chromium.executablePath() });
  const page: Page = await browser.newPage();
  await page.goto(`http://127.0.0.1:${address.port}`);
  assert.equal(await page.title(), 'Browser smoke test');
  await page.getByRole('textbox', { name: 'Name' }).fill('Browser access works');
  await page.getByRole('button', { name: 'Test', exact: true }).click();
  assert.equal(await page.locator('output').textContent(), 'Browser access works');
  await page.screenshot({ path: `${output}smoke-test.png` });
  console.log('PASS: launch, navigation, reading, typing, clicking, screenshot');
  const url: string | undefined = process.argv[2];
  if (url) {
    await page.goto(url);
    console.log(`Website title: ${await page.title()}`);
    await page.screenshot({ path: `${output}website.png` });
  }
} finally {
  await browser?.close();
  server.close();
}
