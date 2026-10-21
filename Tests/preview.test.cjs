const { chromium } = require("playwright");
const path = require("path");
const assert = require("assert");

(async () => {
  const browser = await chromium.launch({ headless: true });
  const output = path.resolve(__dirname, "../Evidence");
  const url = `file://${path.resolve(__dirname, "../WebPreview/index.html")}`;

  const page = await browser.newPage({ viewport: { width: 393, height: 852 } });
  await page.goto(url);
  await page.screenshot({ path: path.join(output, "exercise-1-welcome-iphone-15-pro.png") });

  await page.click("#get-started");
  assert.equal(await page.textContent("#subtitle"), "Let's get started!");
  await page.fill("#student-name", "Julian");
  await page.check("#notify-switch");
  await page.check("#role-faculty");
  await page.fill("#event-date", "2026-10-18");
  await page.click("#guest-plus");
  await page.click("#guest-plus");
  await page.click("#explore-campus");
  assert.match(await page.textContent("#detail-content"), /Welcome, Julian!/);
  assert.match(await page.textContent("#detail-content"), /Faculty/);
  assert.match(await page.textContent("#detail-content"), /October 18, 2026/);
  assert.match(await page.textContent("#detail-content"), /3/);
  await page.screenshot({ path: path.join(output, "exercise-2-personalized-detail.png") });

  await page.click("#detail-screen [data-back]");
  await page.click("#show-announcements");
  assert.equal(await page.locator(".announcement-row").count(), 6);
  assert.equal(await page.locator(".announcement-row.urgent").count(), 3);
  await page.screenshot({ path: path.join(output, "exercise-3-announcements-list.png") });

  await page.click('.announcement-row[data-index="0"]');
  const detailText = await page.textContent("#detail-content");
  assert.match(detailText, /Enrollment Period Extended/);
  assert.match(detailText, /Urgent/);
  assert.match(detailText, /Registrar/);
  await page.screenshot({ path: path.join(output, "exercise-3-announcement-detail.png") });
  await page.close();

  const small = await browser.newPage({ viewport: { width: 375, height: 667 } });
  await small.goto(url);
  await small.screenshot({ path: path.join(output, "exercise-1-welcome-iphone-se.png") });
  assert.equal(await small.locator("#welcome-screen").isVisible(), true);
  await small.close();

  await browser.close();
  console.log("Preview tests passed: navigation, data passing, defaults, six announcements, urgent styling, and detail display.");
})().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
