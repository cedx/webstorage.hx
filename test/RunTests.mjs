import console from "node:console";
import {writeFile} from "node:fs/promises";
import {createServer} from "node:http";
import process from "node:process";
import puppeteer from "puppeteer";
import handler from "serve-handler";

// Start the browser.
const browser = await puppeteer.launch();
const server = createServer((req, res) => handler(req, res, {public: "var"}));

const page = await browser.newPage();
page.on("console", message => console.log(message.text()));
page.on("pageerror", error => console.error(error));

await page.evaluate(() => console.log(navigator.userAgent));
await page.exposeFunction("exit", async code => {
	await browser.close();
	server.close();
	process.exit(code);
});

// Run the test suite.
await writeFile("var/tests.html", `
	<!DOCTYPE html>
	<html dir="ltr" lang="en">
		<head>
			<meta charset="utf-8"/>
			<script defer src="tests.js"></script>
		</head>
		<body></body>
	</html>
`);

server.listen(0, "127.0.0.1", () => {
	const {address, port} = server.address();
	page.goto(`http://${address}:${port}/tests.html`);
});
