import console from "node:console";
import {appendFile, rm, writeFile} from "node:fs/promises";
import {createServer} from "node:http";
import {join} from "node:path";
import process from "node:process";
import {fileURLToPath} from "node:url";
import puppeteer from "puppeteer";
import handler from "serve-handler";

// Remove the previous artifacts.
const basePath = fileURLToPath(new URL("../var", import.meta.url));
const lcovFile = join(basePath, "lcov.info");
await rm(lcovFile, {force: true});

// Start the browser.
const browser = await puppeteer.launch();
const page = await browser.newPage();
const server = createServer((req, res) => handler(req, res, {public: basePath}));

page.on("pageerror", error => console.error(error));
page.on("console", async message => {
	const output = message.text().trim();
	if (output.startsWith("TN:") && output.endsWith("end_of_record")) await appendFile(lcovFile, output);
	else console.log(message.text());
});

await page.evaluateOnNewDocument(() => console.info(navigator.userAgent));
await page.exposeFunction("exit", async code => {
	await page.close();
	await page.browser().close();
	server.close();
	process.exit(code);
});

// Run the test suite.
await writeFile(join(basePath, "tests.html"), `
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
