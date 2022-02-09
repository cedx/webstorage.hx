import js.lib.Object;
import webstorage.Storage;

/** Application entry point. **/
function main() {
	final localStorage = Storage.local();

	// Query the storage.
	trace(localStorage.exists("foo")); // false
	trace(localStorage.exists("baz")); // false
	trace(localStorage.length); // 0
	trace(localStorage.keys); // []

	// Write to the storage.
	localStorage.set("foo", "bar");
	trace(localStorage.exists("foo")); // true
	trace(localStorage.length); // 1
	trace(localStorage.keys); // ["foo"]

	localStorage.setObject("baz", {qux: 123});
	trace(localStorage.exists("baz")); // true
	trace(localStorage.length); // 2
	trace(localStorage.keys); // ["foo", "baz"]

	// Read the storage.
	trace(Std.isOfType(localStorage.get("foo"), String)); // true
	trace(localStorage.get("foo")); // "bar"

	trace(Std.isOfType(localStorage.getObject("baz"), Object)); // true
	trace(localStorage.getObject("baz")); // {qux: 123}
	trace(localStorage.getObject("baz").qux); // 123

	// Iterate the storage.
	for (key => value in localStorage) trace('$key => $value');

	// Delete from the storage.
	localStorage.remove("foo");
	trace(localStorage.exists("foo")); // false
	trace(localStorage.length); // 1
	trace(localStorage.keys); // ["baz"]

	localStorage.clear();
	trace(localStorage.exists("baz")); // false
	trace(localStorage.length); // 0
	trace(localStorage.keys); // []

	// Release the event listeners.
	localStorage.destroy();
}
