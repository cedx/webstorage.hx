---
path: src/branch/main
source: src/webstorage/WebStorage.hx
---

# Programming interface
This package provides two services dedicated to the Web Storage: the `LocalStorage` and `SessionStorage` classes.

=== "Haxe"
		:::haxe
		import webstorage.LocalStorage;

		class Main {
			static function main() {
				final service = new LocalStorage();

				service.set("foo", "bar");
				trace(service.get("foo")); // "bar"

				service.setObject("foo", {baz: "qux"});
				trace(service.getObject("foo")); // {baz: "qux"}
			}
		}

=== "JavaScript"
		:::js
		import {LocalStorage} from "@cedx/webstorage.hx";

		function main() {
			const service = new LocalStorage;

			service.set("foo", "bar");
			console.log(service.get("foo")); // "bar"

			service.setObject("foo", {baz: "qux"});
			console.log(service.getObject("foo")); // {baz: "qux"}
		}

Each class extends from the `WebStorage` abstract class that has the following API:

## **keys**: Array&lt;String&gt;
Returns the keys of the associated storage:

=== "Haxe"
		:::haxe
		import webstorage.LocalStorage;

		class Main {
			static function main() {
				final service = new LocalStorage();
				trace(service.keys); // []
					
				service.set("foo", "bar");
				trace(service.keys); // ["foo"]
			}
		}

=== "JavaScript"
		:::js
		import {LocalStorage} from "@cedx/webstorage.hx";

		function main() {
			const service = new LocalStorage;
			console.log(service.keys); // []
				
			service.set("foo", "bar");
			console.log(service.keys); // ["foo"]
		}

## **length**: Int
Returns the number of entries in the associated storage:

=== "Haxe"
		:::haxe
		import webstorage.LocalStorage;

		class Main {
			static function main() {
				final service = new LocalStorage();
				trace(service.length); // 0
					
				service.set("foo", "bar");
				trace(service.length); // 1
			}
		}

=== "JavaScript"
		:::js
		import {LocalStorage} from "@cedx/webstorage.hx";

		function main() {
			const service = new LocalStorage;
			console.log(service.length); // 0
				
			service.set("foo", "bar");
			console.log(service.length); // 1
		}

## **clear**(): Void
Removes all entries from the associated storage:

=== "Haxe"
		:::haxe
		import webstorage.LocalStorage;

		class Main {
			static function main() {
				final service = new LocalStorage();

				service.set("foo", "bar");
				trace(service.length); // 1
					
				service.clear();
				trace(service.length); // 0
			}
		}

=== "JavaScript"
		:::js
		import {LocalStorage} from "@cedx/webstorage.hx";

		function main() {
			const service = new LocalStorage;

			service.set("foo", "bar");
			console.log(service.length); // 1
				
			service.clear();
			console.log(service.length); // 0
		}

## **destroy**(): Void
When a service is instantiated, it can listen to the global [storage events](https://developer.mozilla.org/en-US/docs/Web/API/Window/storage_event).
When you have done using the service instance, you should call the `destroy()` method to cancel the subscription to these events.

=== "Haxe"
		:::haxe
		import webstorage.LocalStorage;

		class Main {
			static function main() {
				// Work with the service...
				final service = new LocalStorage({listenToGlobalEvents: true});

				// Later, cancel the subscription to the storage events.
				service.destroy();
			}
		}

=== "JavaScript"
		:::js
		import {LocalStorage} from "@cedx/webstorage.hx";

		function main() {
			// Work with the service...
			const service = new LocalStorage({listenToGlobalEvents: true});

			// Later, cancel the subscription to the storage events.
			service.destroy();
		}

See the [events](events.md) section for more information.

## **exists**(key: String): Bool
Returns a boolean value indicating whether the associated storage contains the specified key:

=== "Haxe"
		:::haxe
		import webstorage.LocalStorage;

		class Main {
			static function main() {
				final service = new LocalStorage();
				trace(service.exists("foo")); // false
					
				service.set("foo", "bar");
				trace(service.exists("foo")); // true
			}
		}

=== "JavaScript"
		:::js
		import {LocalStorage} from "@cedx/webstorage.hx";

		function main() {
			const service = new LocalStorage;
			console.log(service.exists("foo")); // false
				
			service.set("foo", "bar");
			console.log(service.exists("foo")); // true
		}

## **get**(key: String, ?defaultValue: String): Null&lt;String&gt;
Returns the value associated to the specified key:

=== "Haxe"
		:::haxe
		import webstorage.LocalStorage;

		class Main {
			static function main() {
				final service = new LocalStorage();
				trace(service.get("foo")); // null
				trace(service.get("foo", "qux")); // "qux"

				service.set("foo", "bar");
				trace(service.get("foo")); // "bar"
			}
		}

=== "JavaScript"
		:::js
		import {LocalStorage} from "@cedx/webstorage.hx";

		function main() {
			const service = new LocalStorage;
			console.log(service.get("foo")); // undefined
			console.log(service.get("foo", "qux")); // "qux"

			service.set("foo", "bar");
			console.log(service.get("foo")); // "bar"
		}

Returns `null` (`undefined` in JavaScript) or the given default value if the key is not found.

## **getObject**&lt;T&gt;(key: String, ?defaultValue: T): Null&lt;T&gt;
Deserializes and returns the value associated to the specified key:

=== "Haxe"
		:::haxe
		import webstorage.LocalStorage;

		class Main {
			static function main() {
				final service = new LocalStorage();
				trace(service.getObject("foo")); // null
				trace(service.getObject("foo", "qux")); // "qux"
				
				service.setObject("foo", {bar: "baz"});
				trace(service.getObject("foo")); // {bar: "baz"}
			}
		}

=== "JavaScript"
		:::js
		import {LocalStorage} from "@cedx/webstorage.hx";

		function main() {
			const service = new LocalStorage;
			console.log(service.getObject("foo")); // undefined
			console.log(service.getObject("foo", "qux")); // "qux"
			
			service.setObject("foo", {bar: "baz"});
			console.log(service.getObject("foo")); // {bar: "baz"}
		}

!!! info
	The value is deserialized using the [`JSON.parse`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/JSON/parse) method.

Returns `null` (`undefined` in JavaScript) or the given default value if the key is not found.

## **putIfAbsent**(key: String, ifAbsent: () -> String): String
Looks up the value of the specified key, or add a new value if it isn't there.

Returns the value associated to the key, if there is one.
Otherwise calls `ifAbsent` to get a new value, associates the key to that value, and then returns the new value:

=== "Haxe"
		:::haxe
		import webstorage.LocalStorage;

		class Main {
			static function main() {
				final service = new LocalStorage();
				trace(service.exists("foo")); // false

				var value = service.putIfAbsent("foo", () -> "bar");
				trace(service.exists("foo")); // true
				trace(value); // "bar"

				value = service.putIfAbsent("foo", () -> "qux");
				trace(value); // "bar"
			}
		}

=== "JavaScript"
		:::js
		import {LocalStorage} from "@cedx/webstorage.hx";

		function main() {
			const service = new LocalStorage;
			console.log(service.exists("foo")); // false

			let value = service.putIfAbsent("foo", () => "bar");
			console.log(service.exists("foo")); // true
			console.log(value); // "bar"

			value = service.putIfAbsent("foo", () => "qux");
			console.log(value); // "bar"
		}

## **putObjectIfAbsent**&lt;T&gt;(key: String, ifAbsent: () -> T): Null&lt;T&gt;
Looks up the value of the specified key, or add a new value if it isn't there.

Returns the deserialized value associated to the key, if there is one.
Otherwise calls `ifAbsent` to get a new value, serializes it and associates the key to that value, and then returns the new value:

=== "Haxe"
		:::haxe
		import webstorage.LocalStorage;

		class Main {
			static function main() {
				final service = new LocalStorage();
				trace(service.exists("foo")); // false

				var value = service.putObjectIfAbsent("foo", () -> 123);
				trace(service.exists("foo")); // true
				trace(value); // 123

				value = service.putObjectIfAbsent("foo", () -> 456);
				trace(value); // 123
			}
		}

=== "JavaScript"
		:::js
		import {LocalStorage} from "@cedx/webstorage.hx";

		function main() {
			const service = new LocalStorage;
			console.log(service.exists("foo")); // false

			let value = service.putObjectIfAbsent("foo", () => 123);
			console.log(service.exists("foo")); // true
			console.log(value); // 123

			value = service.putObjectIfAbsent("foo", () => 456);
			console.log(value); // 123
		}

!!! info
	The value is serialized using the [`JSON.stringify`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/JSON/stringify) method,
	and deserialized using the [`JSON.parse`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/JSON/parse) method.

## **remove**(key: String): Null&lt;String&gt;
Removes the value associated to the specified key:

=== "Haxe"
		:::haxe
		import webstorage.LocalStorage;

		class Main {
			static function main() {
				final service = new LocalStorage();

				service.set("foo", "bar");
				trace(service.exists("foo")); // true

				console.log(service.remove("foo")); // "bar"
				trace(service.exists("foo")); // false
			}
		}

=== "JavaScript"
		:::js
		import {LocalStorage} from "@cedx/webstorage.hx";

		function main() {
			const service = new LocalStorage;

			service.set("foo", "bar");
			console.log(service.exists("foo")); // true
				
			console.log(service.remove("foo")); // "bar"
			console.log(service.exists("foo")); // false
		}

Returns the value associated with the specified key before it was removed.

## **set**(key: String, value: String): WebStorage
Associates a given value to the specified key:

=== "Haxe"
		:::haxe
		import webstorage.LocalStorage;

		class Main {
			static function main() {
				final service = new LocalStorage();
				trace(service.get("foo")); // null

				service.set("foo", "bar");
				trace(service.get("foo")); // "bar"
			}
		}

=== "JavaScript"
		:::js
		import {LocalStorage} from "@cedx/webstorage.hx";

		function main() {
			const service = new LocalStorage;
			console.log(service.get("foo")); // undefined
				
			service.set("foo", "bar");
			console.log(service.get("foo")); // "bar"
		}

## **setObject**(key: String, value: Any): WebStorage
Serializes and associates a given value to the specified key:

=== "Haxe"
		:::haxe
		import webstorage.LocalStorage;

		class Main {
			static function main() {
				final service = new LocalStorage();
				trace(service.getObject("foo")); // null

				service.setObject("foo", {bar: "baz"});
				trace(service.getObject("foo")); // {bar: "baz"}
			}
		}

=== "JavaScript"
		:::js
		import {LocalStorage} from "@cedx/webstorage.hx";
			
		function main() {
			const service = new LocalStorage;
			console.log(service.getObject("foo")); // undefined
				
			service.setObject("foo", {bar: "baz"});
			console.log(service.getObject("foo")); // {bar: "baz"}
		}

!!! info
	The value is serialized using the [`JSON.stringify`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/JSON/stringify) method.
