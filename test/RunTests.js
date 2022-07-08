import console from "node:console";
import {appendFile, rm, writeFile} from "node:fs/promises";
import {createServer} from "node:http";
import process from "node:process";
import getPort from "get-port";
import {chromium} from "playwright";
import handler from "serve-handler";

// Start the browser.
const browser = await chromium.launch();
const page = await browser.newPage();
const server = createServer((req, res) => handler(req, res, {public: "var"}));

page.on("pageerror", error => console.error(error));
page.on("console", async message => {
	const output = message.text().trim();
	if (output.startsWith("TN:") && output.endsWith("end_of_record")) await appendFile("var/lcov.info", output);
	else console.log(message.text());
});

await page.evaluate(() => console.info(navigator.userAgent));
await page.exposeFunction("exit", (/** @type {number} */ code) => {
	process.exitCode = code;
	server.close();
	return browser.close();
});

// Run the test suite.
await rm("var/lcov.info", {force: true});
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

const port = await getPort();
server.listen(port);
await page.goto(`http://localhost:${port}/tests.html`);
