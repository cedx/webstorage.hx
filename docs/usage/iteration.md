# Iteration
The `LocalStorage` and `SessionStorage` classes are iterable.
You can go through all key/value pairs contained using a `for` loop:

<!-- tabs:start -->

#### **Haxe**
```haxe
import webstorage.LocalStorage;

class Main {
	static function main() {
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
```

#### **JavaScript**
```javascript
import {LocalStorage} from "@cedx/webstorage.hx";

function main() {
	const service = new LocalStorage;
	service.set("foo", "bar");
	service.set("anotherKey", "anotherValue");

	for (const [key, value] of service) {
		console.log(`${key} => ${value}`);
		// Round 1: "foo => bar"
		// Round 2: "anotherKey => anotherValue"
	}
}
```

<!-- tabs:end -->
