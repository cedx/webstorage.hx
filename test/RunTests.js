const {appendFileSync} = require("node:fs");
const {rm, writeFile} = require("node:fs/promises");
const {createServer} = require("node:http");
const {join} = require("node:path");
const puppeteer = require("puppeteer");
const handler = require("serve-handler");

// Start the application.
(async function main() {
	const basePath = join(__dirname, "../var");
	const lcovFile = join(basePath, "lcov.info");
	await rm(lcovFile, {force: true});
	await writeFile(join(basePath, "tests.html"), [
		'<!DOCTYPE html>',
		'<html dir="ltr" lang="en">',
		'\t<head><meta charset="UTF-8"/></head>',
		'\t<body><script src="tests.js"></script></body>',
		'</html>'
	].join("\n"));

	const browser = await puppeteer.launch();
	const page = await browser.newPage();
	page.on("pageerror", error => console.error(error));
	page.on("console", message => {
		const output = message.text().trim();
		if (output.startsWith("TN:") && output.endsWith("end_of_record")) appendFileSync(lcovFile, output);
		else console.log(message.text());
	});

	const server = createServer((req, res) => handler(req, res, {public: basePath}));
	server.listen(8080);
	await page.exposeFunction("exit", async code => {
		process.exitCode = code;
		server.close();
		await browser.close();
	});

	await page.evaluate(() => console.info(navigator.userAgent));
	await Promise.all([
		page.waitForNavigation(),
		page.goto("http://localhost:8080/tests.html")
	]);
})();
