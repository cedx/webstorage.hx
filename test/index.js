#!/usr/bin/env node
const {join} = require("path");
const {chromium} = require("playwright");

// Start the application.
(async function main() {
	const browser = await chromium.launch();
	const page = await browser.newPage();
	page.on("console", message => console.log(message.text()));
	page.on("pageerror", error => console.error(error));

	await page.exposeFunction("exit", code => {
		process.exitCode = code;
		return browser.close();
	});

	await page.evaluate(() => console.info(navigator.userAgent));
	await page.addScriptTag({path: join(__dirname, "../var/tests.js")});
})();
