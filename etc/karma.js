process.env.CHROME_BIN = "C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe";
module.exports = config => config.set({
	basePath: "..",
	browsers: ["ChromeHeadless"],
	files: ["var/tests.js"],
	frameworks: ["mocha"],
	reporters: ["progress"],
	singleRun: true
});
