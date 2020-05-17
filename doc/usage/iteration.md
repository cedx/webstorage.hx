# Iteration
The [`LocalStorage`](api.md) and [`SessionStorage`](api.md) classes are iterable.
You can go through all key/value pairs contained using a `for` loop:

=== "Haxe"
		:::haxe
		import webstorage.LocalStorage;

		class Main {
			static function main(): Void {
				final service = new LocalStorage();
				service.set("foo", "bar");
				service.set("anotherKey", "anotherValue");

				for (key => value in service) {
					trace('$key => $value');
					// Round 1: "foo => bar"
					// Round 2: "anotherKey => anotherValue"
				}
			}
		}

=== "JavaScript"
		:::js
		import {LocalStorage} from "@cedx/webstorage.hx";

		function main() {
			const service = new LocalStorage;
			service.set("foo", "bar");
			service.set("anotherKey", "anotherValue");

			for (const entry of service) {
				console.log(entry);
				// Round 1: ["foo", "bar"]
				// Round 2: ["anotherKey", "anotherValue"]
			}
		}
