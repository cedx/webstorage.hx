const console = require("node:console");
const {writeFile} = require("node:fs/promises");
const {createServer} = require("node:http");
const {join} = require("node:path");
const process = require("node:process");
const puppeteer = require("puppeteer");
const handler = require("serve-handler");

// Run the test suite.
(async function main() {
	const browser = await puppeteer.launch();
	const server = createServer((req, res) => handler(req, res, {public: join(__dirname, "../var")}));

	const page = await browser.newPage();
	page.on("console", message => console.log(message.text()));
	page.on("pageerror", error => console.error(error));

	await page.evaluate(() => console.log(navigator.userAgent));
	await page.exposeFunction("exit", async code => {
		await browser.close();
		server.close();
		process.exit(code);
	});

	await writeFile(join(__dirname, "../var/tests.html"), `
		<!DOCTYPE html>
		<html dir="ltr" lang="en">
			<head>
				<meta charset="utf-8">
				<script defer src="tests.js"></script>
			</head>
			<body></body>
		</html>
	`);

	server.listen(0, "127.0.0.1", () => {
		const {address, port} = server.address();
		page.goto(`http://${address}:${port}/tests.html`);
	});
})();
