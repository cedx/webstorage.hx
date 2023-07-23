/** Runs the test suite. **/
function main() {
	var exitCode = 0;

	Sys.println("> Testing with `haxe.Json` serializer...");
	if (Sys.command("haxe test.hxml") != 0) exitCode++;

	Sys.println("> Testing with `tink.Json` serializer...");
	if (Sys.command("haxe --library tink_json test.hxml") != 0) exitCode++;

	Sys.exit(exitCode);
}
