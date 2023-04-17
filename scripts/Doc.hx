//! --class-path src --library tink_core
import sys.FileSystem;
import sys.io.File;
import webstorage.Version;

/** Builds the documentation. **/
function main() {
	if (FileSystem.exists("docs")) Tools.removeDirectory("docs");

	Sys.command("haxe --define doc-gen --no-output --xml var/api.xml build.hxml");
	Sys.command("lix", ["run", "dox",
		"--define", "description", "Service for interacting with the Web Storage, in Haxe.",
		"--define", "source-path", "https://github.com/cedx/webstorage.hx/blob/main/src",
		"--define", "themeColor", "0xea8220",
		"--define", "version", Version.packageVersion,
		"--define", "website", "https://github.com/cedx/webstorage.hx",
		"--input-path", "var",
		"--output-path", "docs",
		"--title", "Web Storage for Haxe",
		"--toplevel-package", "webstorage"
	]);

	File.copy("www/favicon.ico", "docs/favicon.ico");
}
