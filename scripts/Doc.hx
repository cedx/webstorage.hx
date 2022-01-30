import Sys.*;
import haxe.Json;
import sys.FileSystem.*;
import sys.io.File.*;

/** Runs the script. **/
function main() {
	if (exists("docs")) Tools.removeDirectory("docs");

	command("haxe --define doc-gen --no-output --xml var/api.xml build.hxml");
	command("lix", [
		"run", "dox",
		"--define", "description", "Services for interacting with the Web Storage, in Haxe.",
		"--define", "source-path", "https://bitbucket.org/cedx/webstorage.hx/src/main/src",
		"--define", "themeColor", "0xffc105",
		"--define", "version", Json.parse(getContent("haxelib.json")).version,
		"--define", "website", "https://bitbucket.org/cedx/webstorage.hx",
		"--input-path", "var",
		"--output-path", "docs",
		"--title", "Web Storage for Haxe",
		"--toplevel-package", "webstorage"
	]);

	copy("www/favicon.ico", "docs/favicon.ico");
}
