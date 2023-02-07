/** Runs the script. **/
function main() {
	Sys.println("> Testing with `haxe.Json` serializer...");
	Sys.command("haxe", ["test.hxml"]);

	Sys.println("> Testing with `tink.Json` serializer...");
	Sys.command("haxe", ["--library", "tink_json", "test.hxml"]);
}
