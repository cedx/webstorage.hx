#!/usr/bin/env node
const {writeFile} = require("fs/promises");
const {createServer} = require("http");
const {join} = require("path");
const {chromium} = require("playwright");
const handler = require("serve-handler");

// Start the application.
(async function main() {
	await writeFile(join(__dirname, "../var/tests.html"), [
		'<!DOCTYPE html>',
		'<html dir="ltr" lang="en">',
		'\t<head><meta charset="UTF-8"/></head>',
		'\t<body><script src="tests.js"></script></body>',
		'</html>'
	].join("\n"));

	const server = createServer((req, res) => handler(req, res, {public: join(__dirname, "../var")}));
	server.listen(8080);

	const browser = await chromium.launch();
	const page = await browser.newPage();
	page.on("console", message => console.log(message.text()));
	page.on("pageerror", error => console.error(error));

	await page.exposeFunction("exit", code => {
		process.exitCode = code;
		server.close();
		return browser.close();
	});

	await page.evaluate(() => console.info(navigator.userAgent));
	await page.goto("http://localhost:8080/tests.html");
})();
