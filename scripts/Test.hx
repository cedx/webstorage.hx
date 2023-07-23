/** Runs the test suite. **/
function main() {
	var exitCode = 0;

	Sys.println("> Testing with `haxe.Json` serializer...");
	exitCode = Sys.command("haxe test.hxml");
	if (exitCode != 0) Sys.exit(exitCode);

	Sys.println("> Testing with `tink.Json` serializer...");
	exitCode = Sys.command("haxe --library tink_json test.hxml");
	if (exitCode != 0) Sys.exit(exitCode);
}
