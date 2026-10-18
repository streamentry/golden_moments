// Run against a served Flutter release build. Uses real content and downloads.
const { chromium } = require('playwright');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const baseUrl = process.env.APP_URL || 'http://127.0.0.1:8765';
const output = path.resolve('output/playwright');
fs.mkdirSync(output, { recursive: true });
const results = [];
const errors = [];
let browser;
let page;
async function shot(name) {
  // Flutter semantics can update before route and sheet animations finish.
  await page.waitForTimeout(600);
  await page.screenshot({ path: path.join(output, `${name}.png`) });
  fs.writeFileSync(path.join(output, `${name}.yaml`), await page.locator('body').ariaSnapshot());
}
async function check(name, fn) {
  await fn();
  results.push({ name, status: 'passed' });
  console.log(`PASS ${name}`);
}
async function eventually(read, expected) {
  for (let attempt = 0; attempt < 50; attempt++) {
    if (await read() === expected) return;
    await page.waitForTimeout(100);
  }
  assert.equal(await read(), expected);
}
(async () => {
  browser = await chromium.launch({ channel: process.env.PLAYWRIGHT_CHANNEL || 'chrome', headless: true });
  const context = await browser.newContext({ viewport: { width: 390, height: 844 }, locale: 'en-US' });
  page = await context.newPage();
  page.setDefaultTimeout(20000);
  page.on('pageerror', error => errors.push(error.message));
  await page.goto(baseUrl);
  await page.locator('flt-semantics-placeholder').evaluate(el => el.click());
  await page.getByRole('heading', { name: 'Golden Moments', exact: true }).waitFor();
  await page.getByRole('button', { name: /^DAILY / }).first().waitFor();
  await check('real image downloads persist in browser storage', async () => {
    const index = await (await context.request.get(`${baseUrl}/assets/assets/data/packs_index.json`)).json();
    const urls = [...new Set(index.packs.flatMap(pack => pack.images.map(image => image.url)))];
    await page.waitForFunction(async expected => {
      const cache = await caches.open('golden-moments-images-v1');
      return (await Promise.all(expected.map(url => cache.match(url)))).every(Boolean);
    }, urls, { timeout: 120000 });
    assert(urls.length > 0);
    results.push({ name: 'cached images', count: urls.length, status: 'passed' });
  });
  await check('home renders at mobile, tablet, and desktop sizes', async () => {
    for (const [width, height] of [[320, 740], [390, 844], [768, 1024], [1440, 1000]]) {
      await page.setViewportSize({ width, height });
      await page.waitForTimeout(600);
      await shot(`home-${width}`);
      const settings = await page.getByRole('button', { name: 'Settings', exact: true }).boundingBox();
      assert(settings && settings.x >= 0 && settings.x + settings.width <= width + 1);
      assert.equal(await page.getByText("You're offline. Playing with cached packs only.", { exact: true }).count(), 0);
    }
  });
  await page.setViewportSize({ width: 390, height: 844 });
  await check('settings toggles and saves', async () => {
    await page.getByRole('button', { name: 'Settings', exact: true }).click();
    const toggle = page.getByRole('switch').first();
    await toggle.waitFor();
    const before = await toggle.getAttribute('aria-checked');
    await toggle.click();
    await eventually(() => toggle.getAttribute('aria-checked'), before === 'true' ? 'false' : 'true');
    await shot('settings-mobile');
    await page.getByRole('button', { name: 'Save', exact: true }).first().click();
    await page.getByRole('button', { name: 'Settings', exact: true }).click();
    assert.notEqual(await page.getByRole('switch').first().getAttribute('aria-checked'), before);
    await page.getByRole('button', { name: 'Save', exact: true }).first().click();
  });
  await check('download manager renders completed packs', async () => {
    await page.getByRole('button', { name: 'Download', exact: true }).click();
    await shot('downloads-mobile');
    await page.getByRole('button', { name: 'Home', exact: true }).click();
  });
  await check('downloaded pack opens a playable game', async () => {
    await page.getByRole('button', { name: /^DAILY / }).first().click();
    await page.getByRole('button', { name: 'Hidden tile', exact: true }).first().waitFor();
    assert.equal(await page.getByText('Game Error', { exact: true }).count(), 0);
    await shot('game-mobile');
  });
  await check('tile reveals, pause/resume, and replay work', async () => {
    const hidden = page.getByRole('button', { name: 'Hidden tile', exact: true });
    const count = await hidden.count();
    await hidden.first().click();
    await page.waitForTimeout(500);
    await eventually(() => hidden.count(), count - 1);
    await shot('tile-revealed');
    await page.getByRole('button', { name: 'Pause Game', exact: true }).click();
    await page.getByText('Game Paused', { exact: true }).waitFor();
    await shot('paused-mobile');
    await page.getByRole('button', { name: 'Resume', exact: true }).first().click();
    await page.getByRole('button', { name: 'Replay', exact: true }).click();
    await eventually(() => hidden.count(), count);
    await shot('game-restarted');
  });
  await check('cached gameplay works without network', async () => {
    await context.setOffline(true);
    const hidden = page.getByRole('button', { name: 'Hidden tile', exact: true });
    const count = await hidden.count();
    await hidden.first().click();
    await eventually(() => hidden.count(), count - 1);
    await shot('offline-tile-revealed');
    assert.equal(await page.getByText('Game Error', { exact: true }).count(), 0);
    await context.setOffline(false);
  });
  await check('hint and leaving game do not emit after disposal', async () => {
    await page.getByRole('button', { name: 'Replay', exact: true }).click();
    await page.getByRole('button', { name: 'Show Hint', exact: true }).click();
    await shot('hint-revealed');
    await page.getByRole('button', { name: 'Back', exact: true }).click();
    await page.waitForTimeout(1500);
    await page.getByRole('heading', { name: 'Golden Moments', exact: true }).waitFor();
  });
  await check('library category opens its packs', async () => {
    await page.getByRole('button', { name: /^Animals Cute/ }).click();
    await page.getByRole('heading', { name: 'Animals', exact: true }).waitFor();
    await shot('library-animals');
    await page.getByRole('button', { name: 'Back', exact: true }).click();
  });
  await check('full game completes and can be played again', async () => {
    await page.getByRole('button', { name: /^Animals Cute/ }).click();
    await page.getByRole('button', { name: /Farm Animals/ }).click();
    await page.getByRole('button', { name: 'Hidden tile', exact: true }).first().waitFor();
    const tiles = page.getByRole('group').getByRole('button');
    const count = await tiles.count();
    const known = new Map();
    const matched = new Set();
    // Remember only names revealed by clicking, as a player would.
    async function flip(index) {
      await tiles.nth(index).click();
      await page.waitForTimeout(120);
      const snapshot = await tiles.nth(index).ariaSnapshot();
      const name = JSON.parse(snapshot.match(/"(?:[^"\\]|\\.)*"/)[0]);
      assert.notEqual(name, 'Hidden tile');
      known.set(index, name);
      return name;
    }
    for (let turn = 0; matched.size < count && turn < 100; turn++) {
      const left = Array.from({ length: count }, (_, index) => index).filter(index => !matched.has(index));
      let pair;
      for (const first of left) {
        const second = left.find(second => first !== second && known.has(first) && known.get(first) === known.get(second));
        if (second !== undefined) { pair = [first, second]; break; }
      }
      const first = pair ? pair[0] : left.find(index => !known.has(index));
      assert.notEqual(first, undefined);
      const firstName = await flip(first);
      const second = pair ? pair[1] : left.find(index => index !== first && known.get(index) === firstName)
        ?? left.find(index => index !== first && !known.has(index))
        ?? left.find(index => index !== first);
      // The final match opens a modal, removing the board's semantics.
      const secondName = matched.size === count - 2
        ? (await tiles.nth(second).click(), firstName) : await flip(second);
      if (firstName === secondName || secondName === `Matched: ${firstName}`) {
        matched.add(first); matched.add(second);
      } else {
        await page.waitForTimeout(1600);
      }
    }
    assert.equal(matched.size, count);
    await page.getByText('You completed the memory game!', { exact: true }).waitFor();
    assert.equal(await page.getByText(/You've completed 3 memory games/).count(), 0);
    await shot('game-completed');
    await page.getByRole('button', { name: 'Play Again', exact: true }).first().click();
    await page.getByRole('button', { name: 'Hidden tile', exact: true }).first().waitFor();
    await shot('play-again');
  });
  assert.deepEqual(errors, [], 'Unhandled browser errors');
})().catch(async error => {
  results.push({ name: 'automation', status: 'failed', error: error.message });
  if (page) await shot('failure').catch(() => {});
  console.error(error);
  process.exitCode = 1;
}).finally(async () => {
  fs.writeFileSync(path.join(output, 'results.json'), JSON.stringify({ baseUrl, timestamp: new Date().toISOString(), results, errors }, null, 2));
  if (browser) await browser.close();
});
