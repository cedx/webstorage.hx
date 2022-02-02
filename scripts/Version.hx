import haxe.Json;
import sys.io.File;

/** Runs the script. **/
function main() {
	final version = Json.parse(File.getContent("haxelib.json")).version;
	Tools.replaceInFile("package.json", ~/"version": "\d+(\.\d+){2}"/, '"version": "$version"');
}
