"use strict";
const console = require("node:console");
const {rm, writeFile} = require("node:fs/promises");
const {createServer} = require("node:http");
const {EOL} = require("node:os");
const process = require("node:process");
const {firefox} = require("playwright");
const handler = require("serve-handler");

(async function() {
	// Start the browser.
	const browser = await firefox.launch();
	const coverage = [];
	const server = createServer((req, res) => handler(req, res, {public: "var"}));

	const page = await browser.newPage();
	page.on("pageerror", error => console.error(error));
	page.on("console", message => {
		const output = message.text().trim();
		if (output.startsWith("TN:") && output.endsWith("end_of_record")) coverage.push(output);
		else console.log(message.text());
	});

	await page.evaluate(() => console.log(navigator.userAgent));
	await page.exposeFunction("exit", async code => {
		await browser.close();
		await writeFile("var/lcov.info", coverage.join(EOL));
		server.close();
		process.exit(code);
	});

	// Run the test suite.
	await rm("var/lcov.info", {force: true});
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
})();
