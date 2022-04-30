import console from "node:console";
import {appendFile, writeFile} from "node:fs/promises";
import {createServer} from "node:http";
import process from "node:process";
import del from "del";
import puppeteer from "puppeteer";
import handler from "serve-handler";

// Start the browser.
const browser = await puppeteer.launch();
const page = await browser.newPage();
const server = createServer((req, res) => handler(req, res, {public: "var"}));

page.on("pageerror", error => console.error(error));
page.on("console", async message => {
	const output = message.text().trim();
	if (output.startsWith("TN:") && output.endsWith("end_of_record")) await appendFile("var/lcov.info", output);
	else console.log(message.text());
});

await page.evaluateOnNewDocument(() => console.info(navigator.userAgent));
await page.exposeFunction("exit", async (/** @type {number} */ code) => {
	await page.close();
	await page.browser().close();
	server.close();
	process.exit(code);
});

// Run the test suite.
await del("var/lcov.info");
await writeFile("var/tests.html", `
	<!DOCTYPE html>
	<html dir="ltr" lang="en">
	<head>
		<meta charset="UTF-8"/>
		<script defer src="tests.js"></script>
	</head>
	<body></body>
	</html>
`);

server.listen(8192);
await Promise.all([
	page.goto("http://localhost:8192/tests.html"),
	page.waitForNavigation()
]);
