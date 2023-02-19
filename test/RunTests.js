const console = require("node:console");
const {rm, writeFile} = require("node:fs/promises");
const {createServer} = require("node:http");
const {EOL} = require("node:os");
const process = require("node:process");
const {chromium} = require("playwright");
const handler = require("serve-handler");

(async function() {
	// Start the browser.
	const browser = await chromium.launch();
	const coverage = [];
	const page = await browser.newPage();
	const server = createServer((req, res) => handler(req, res, {public: "var"}));

	page.on("pageerror", error => console.error(error));
	page.on("console", async message => {
		const output = message.text().trim();
		if (output.startsWith("TN:") && output.endsWith("end_of_record")) coverage.push(output);
		else console.log(message.text());
	});

	await page.evaluate(() => console.log(navigator.userAgent));
	await page.exposeFunction("exit", async (/** @type {number} */ code) => {
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
				<meta charset="UTF-8"/>
				<script defer src="tests.js"></script>
			</head>
			<body></body>
		</html>
	`);

	const {default: getPort} = await import("get-port");
	const port = await getPort();
	server.listen(port);
	await page.goto(`http://localhost:${port}/tests.html`);
})();
