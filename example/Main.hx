import js.Browser.console;
import js.lib.Object;
import webstorage.LocalStorage;

/** The main class. **/
class Main {

	/** Application entry point. **/
	static function main() {
		final service = new LocalStorage();

		// Query the storage.
		console.log(service.exists("foo")); // false
		console.log(service.exists("baz")); // false
		console.log(service.length); // 0
		console.log(service.keys); // []

		// Write to the storage.
		service.set("foo", "bar");
		console.log(service.exists("foo")); // true
		console.log(service.length); // 1
		console.log(service.keys); // ["foo"]

		service.setObject("baz", {qux: 123});
		console.log(service.exists("baz")); // true
		console.log(service.length); // 2
		console.log(service.keys); // ["foo", "baz"]

		// Read the storage.
		console.log(Std.isOfType(service.get("foo"), String)); // true
		console.log(service.get("foo")); // "bar"

		console.log(Std.isOfType(service.getObject("baz"), Object)); // true
		console.log(service.getObject("baz")); // {qux: 123}
		console.log(service.getObject("baz").qux); // 123

		// Iterate the storage.
		for (key => value in service) console.log('$key => $value');

		// Delete from the storage.
		service.remove("foo");
		console.log(service.exists("foo")); // false
		console.log(service.length); // 1
		console.log(service.keys); // ["baz"]

		service.clear();
		console.log(service.exists("baz")); // false
		console.log(service.length); // 0
		console.log(service.keys); // []

		// Release the event listeners.
		service.destroy();
}
}
