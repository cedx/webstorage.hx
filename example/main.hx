import js.Browser.console;
import js.lib.Object;
import webstorage.Storage;

/** Application entry point. **/
function main() {
	final localStorage = Storage.local();

	// Query the storage.
	console.log(localStorage.exists("foo")); // false
	console.log(localStorage.exists("baz")); // false
	console.log(localStorage.length); // 0
	console.log(localStorage.keys); // []

	// Write to the storage.
	localStorage.set("foo", "bar");
	console.log(localStorage.exists("foo")); // true
	console.log(localStorage.length); // 1
	console.log(localStorage.keys); // ["foo"]

	localStorage.setObject("baz", {qux: 123});
	console.log(localStorage.exists("baz")); // true
	console.log(localStorage.length); // 2
	console.log(localStorage.keys); // ["foo", "baz"]

	// Read the storage.
	console.log(Std.isOfType(localStorage.get("foo"), String)); // true
	console.log(localStorage.get("foo")); // "bar"

	console.log(Std.isOfType(localStorage.getObject("baz"), Object)); // true
	console.log(localStorage.getObject("baz")); // {qux: 123}
	console.log(localStorage.getObject("baz").qux); // 123

	// Iterate the storage.
	for (key => value in localStorage) console.log('$key => $value');

	// Delete from the storage.
	localStorage.remove("foo");
	console.log(localStorage.exists("foo")); // false
	console.log(localStorage.length); // 1
	console.log(localStorage.keys); // ["baz"]

	localStorage.clear();
	console.log(localStorage.exists("baz")); // false
	console.log(localStorage.length); // 0
	console.log(localStorage.keys); // []

	// Release the event listeners.
	localStorage.destroy();
}
