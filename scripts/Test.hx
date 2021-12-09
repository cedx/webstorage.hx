import Sys.*;

/** Runs the script. **/
function main() {
	println('> Testing with "haxe.Json" serializer...');
	command("haxe test.hxml");

	println('> Testing with "tink.Json" serializer...');
	command("haxe --library tink_json test.hxml");
}
