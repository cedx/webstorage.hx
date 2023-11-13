//! --class-path src --library tink_core
import sys.FileSystem;
import sys.io.File;
import webstorage.Platform;
using Lambda;

/** Builds the documentation. **/
function main() {
	["CHANGELOG.md", "LICENSE.md"].iter(file -> File.copy(file, 'docs/${file.toLowerCase()}'));
	if (FileSystem.exists("docs/api")) Tools.removeDirectory("docs/api");

	Sys.command("haxe --define doc-gen --no-output --xml var/api.xml build.hxml");
	Sys.command("lix", ["run", "dox",
		"--define", "description", "Service for interacting with the Web Storage, in Haxe.",
		"--define", "source-path", "https://github.com/cedx/webstorage.hx/blob/main/src",
		"--define", "themeColor", "0xea8220",
		"--define", "version", Platform.packageVersion,
		"--define", "website", "https://cedx.github.io/webstorage.hx",
		"--input-path", "var",
		"--output-path", "docs/api",
		"--title", "Web Storage for Haxe",
		"--toplevel-package", "webstorage"
	]);

	File.copy("docs/favicon.ico", "docs/api/favicon.ico");
}
