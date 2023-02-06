import sys.FileSystem;
using Lambda;

/** Runs the script. **/
function main() {
	["lib", "res"].filter(FileSystem.exists).iter(Tools.removeDirectory);
	Tools.cleanDirectory("var");
}
