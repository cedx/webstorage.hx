package webstorage;

import haxe.Json;
import js.Browser.window;

using StringTools;

/** Tests the features of the `WebStorage` class. **/
@:asserts class WebStorageTest {

	/** Creates a new test. **/
	public function new() {}

	/** This method is invoked before each test. **/
	@:before public function before() {
		window.sessionStorage.clear();
		return Noise;
	}

	/** Tests the `keys` property. **/
	public function testKeys() {
		// It should return an empty array for an empty storage.
		final service = new SessionStorage();
		asserts.assert(service.keys.length == 0);

		// It should return the list of keys for a non-empty storage.
		window.sessionStorage.setItem("foo", "bar");
		window.sessionStorage.setItem("bar", "baz");

		final keys = service.keys;
		asserts.assert(keys.length == 2);
		asserts.assert(keys[0] == "foo");
		asserts.assert(keys[1] == "bar");

		return asserts.done();
	}

	/** Tests the `length` property. **/
	public function testLength() {
		// It should return zero for an empty storage.
		final service = new SessionStorage();
		asserts.assert(service.length == 0);

		// It should return the number of entries for a non-empty storage.
		window.sessionStorage.setItem("foo", "bar");
		window.sessionStorage.setItem("bar", "baz");
		asserts.assert(service.length == 2);

		return asserts.done();
	}

	/** Tests the `addEventListener("change")` method. **/
	/* TODO
	public function testAddEventListener() {
		// It should trigger an event when a value is added", public function(done) {
		final listener = event -> {
			asserts.equals("foo", event.key);
			asserts.assert(event.oldValue == null);
			asserts.equals("bar", event.newValue);
			done();
		};

		final service = new SessionStorage();
		service.addEventListener("change", listener);
		service.set("foo", "bar");
		service.removeEventListener("change", listener);

		// It should trigger an event when a value is updated", public function(done) {
		window.sessionStorage.setItem("foo", "bar");

		final listener = event -> {
			asserts.equals("foo", event.key);
			asserts.equals("bar", event.oldValue);
			asserts.equals("baz", event.newValue);
			done();
		};

		final service = new SessionStorage();
		service.addEventListener("change", listener);
		service.set("foo", "baz");
		service.removeEventListener("change", listener);

		// It should trigger an event when a value is removed", public function(done) {
		window.sessionStorage.setItem("foo", "bar");

		final listener = event -> {
			asserts.equals("foo", event.key);
			asserts.equals("bar", event.oldValue);
			asserts.assert(event.newValue == null);
			done();
		};

		final service = new SessionStorage();
		service.addEventListener("change", listener);
		service.remove("foo");
		service.removeEventListener("change", listener);

		// It should trigger an event when the storage is cleared", public function(done) {
		window.sessionStorage.setItem("foo", "bar");
		window.sessionStorage.setItem("bar", "baz");

		final listener = event -> {
			asserts.assert(event.key == null);
			asserts.assert(event.oldValue == null);
			asserts.assert(event.newValue == null);
			done();
		};

		final service = new SessionStorage();
		service.addEventListener("change", listener);
		service.clear();
		service.removeEventListener("change", listener);

		return asserts.done();
	}*/

	/** Tests the `clear()` method. **/
	public function testClear() {
		// It should remove all storage entries.
		window.sessionStorage.setItem("foo", "bar");
		window.sessionStorage.setItem("bar", "baz");

		final service = new SessionStorage();
		asserts.assert(service.length == 2);
		service.clear();
		asserts.assert(service.length == 0);

		return asserts.done();
	}

	/** Tests the `exists()` method. **/
	public function testExists() {
		// It should return `false` if the specified key is not contained.
		final service = new SessionStorage();
		asserts.assert(!service.exists("foo"));

		// It should return `true` if the specified key is contained.
		window.sessionStorage.setItem("foo", "bar");
		asserts.assert(service.exists("foo"));
		asserts.assert(!service.exists("bar"));

		return asserts.done();
	}

	/** Tests the `get()` method. **/
	public function testGet() {
		// It should properly get the storage entries.
		final service = new SessionStorage();
		asserts.assert(service.get("foo") == null);

		window.sessionStorage.setItem("foo", "bar");
		asserts.assert(service.get("foo") == "bar");

		window.sessionStorage.setItem("foo", "123");
		asserts.assert(service.get("foo") == "123");

		// It should return the given default value if the key is not found.
		asserts.assert(service.get("bar", "123") == "123");
		return asserts.done();
	}

	/** Tests the `getObject()` method. **/
	public function testGetObject() {
		// It should properly get the deserialized storage entries.
		final service = new SessionStorage();
		asserts.assert(service.getObject("foo") == null);

		window.sessionStorage.setItem("foo", "123");
		asserts.assert(service.getObject("foo") == 123);

		window.sessionStorage.setItem("foo", '"bar"');
		asserts.assert(service.getObject("foo") == "bar");

		window.sessionStorage.setItem("foo", '{"key": "value"}');
		asserts.compare({key: "value"}, service.getObject("foo"));

		// It should return the default value if the value can't be deserialized.
		window.sessionStorage.setItem("foo", "bar");
		asserts.assert(service.getObject("foo", "defaultValue") == "defaultValue");

		return asserts.done();
	}

	/** Tests the `keyValueIterator()` method. **/
	public function testKeyValueIterator() {
		// It should end iteration immediately if the storage is empty.
		final service = new SessionStorage();
		final iterator = service.keyValueIterator();
		asserts.assert(!iterator.hasNext());

		// It should iterate over the values if the storage is not empty.
		window.sessionStorage.setItem("foo", "bar");
		window.sessionStorage.setItem("bar", "baz");

		final iterator = service.keyValueIterator();
		asserts.assert(iterator.hasNext());
		asserts.compare({key: "foo", value: "bar"}, iterator.next());
		asserts.assert(iterator.hasNext());
		asserts.compare({key: "bar", value: "baz"}, iterator.next());
		asserts.assert(!iterator.hasNext());

		return asserts.done();
	}

	/** Tests the `putIfAbsent()` method. **/
	public function testPutIfAbsent() {
		// It should add a new entry if it does not exist.
		final service = new SessionStorage();
		asserts.assert(window.sessionStorage.getItem("foo") == null);
		asserts.assert(service.putIfAbsent("foo", () -> "bar") == "bar");
		asserts.assert(window.sessionStorage.getItem("foo") == "bar");

		// It should not add a new entry if it already exists.
		window.sessionStorage.setItem("foo", "bar");
		asserts.assert(service.putIfAbsent("foo", () -> "qux") == "bar");
		asserts.assert(window.sessionStorage.getItem("foo") == "bar");
		asserts.assert(service.putIfAbsent("bar", () -> "qux") == "qux");
		asserts.assert(window.sessionStorage.getItem("bar") == "qux");

		// It should support the key prefix.
		final service = new SessionStorage({keyPrefix: "prefix:"});
		window.sessionStorage.setItem("prefix:foo", "bar");
		asserts.assert(service.putIfAbsent("foo", () -> "qux") == "bar");
		asserts.assert(window.sessionStorage.getItem("prefix:foo") == "bar");
		asserts.assert(service.putIfAbsent("bar", () -> "qux") == "qux");
		asserts.assert(window.sessionStorage.getItem("prefix:bar") == "qux");

		return asserts.done();
	}

	/** Tests the `putObjectIfAbsent()` method. **/
	public function testPutObjectIfAbsent() {
		// It should add a new entry if it does not exist.
		final service = new SessionStorage();
		asserts.assert(window.sessionStorage.getItem("foo") == null);
		asserts.assert(service.putObjectIfAbsent("foo", () -> 123) == 123);
		asserts.assert(window.sessionStorage.getItem("foo") == "123");

		// It should not add a new entry if it already exists.
		final service = new SessionStorage();
		window.sessionStorage.setItem("foo", "123");
		asserts.assert(service.putObjectIfAbsent("foo", () -> 456) == 123);
		asserts.assert(window.sessionStorage.getItem("foo") == "123");
		asserts.assert(service.putObjectIfAbsent("bar", () -> 456) == 456);
		asserts.assert(window.sessionStorage.getItem("bar") == "456");

		// It should support the key prefix.
		final service = new SessionStorage({keyPrefix: "prefix:"});
		window.sessionStorage.setItem("prefix:foo", "123");
		asserts.assert(service.putObjectIfAbsent("foo", () -> 456) == 123);
		asserts.assert(window.sessionStorage.getItem("prefix:foo") == "123");
		asserts.assert(service.putObjectIfAbsent("bar", () -> 456) == 456);
		asserts.assert(window.sessionStorage.getItem("prefix:bar") == "456");

		return asserts.done();
	}

	/** Tests the `remove()` method. **/
	public function testRemove() {
		// It should properly remove the storage entries.
		final service = new SessionStorage();
		window.sessionStorage.setItem("foo", "bar");
		window.sessionStorage.setItem("bar", "baz");
		asserts.assert(window.sessionStorage.getItem("foo") == "bar");

		service.remove("foo");
		asserts.assert(window.sessionStorage.getItem("foo") == null);
		asserts.assert(window.sessionStorage.getItem("bar") == "baz");

		service.remove("bar");
		asserts.assert(window.sessionStorage.getItem("bar") == null);

		// It should support the key prefix.
		final service = new SessionStorage({keyPrefix: "prefix:"});
		window.sessionStorage.setItem("prefix:foo", "bar");
		window.sessionStorage.setItem("prefix:bar", "baz");
		asserts.assert(window.sessionStorage.getItem("prefix:foo") == "bar");

		service.remove("foo");
		asserts.assert(window.sessionStorage.getItem("prefix:foo") == null);
		asserts.assert(window.sessionStorage.getItem("prefix:bar") == "baz");

		service.remove("bar");
		asserts.assert(window.sessionStorage.getItem("prefix:bar") == null);
		return asserts.done();
	}

	/** Tests the `set()` method. **/
	public function testSet() {
		// It should properly set the storage entries.
		final service = new SessionStorage();
		asserts.assert(window.sessionStorage.getItem("foo") == null);

		service.set("foo", "bar");
		asserts.assert(window.sessionStorage.getItem("foo") == "bar");

		service.set("foo", "123");
		asserts.assert(window.sessionStorage.getItem("foo") == "123");

		// It should support the key prefix.
		final service = new SessionStorage({keyPrefix: "prefix:"});
		asserts.assert(window.sessionStorage.getItem("prefix:foo") == null);

		service.set("foo", "bar");
		asserts.assert(window.sessionStorage.getItem("foo") == null);
		asserts.assert(window.sessionStorage.getItem("prefix:foo") == "bar");

		service.set("foo", "123");
		asserts.assert(window.sessionStorage.getItem("prefix:foo") == "123");
		return asserts.done();
	}

	/** Tests the `setObject()` method. **/
	public function testSetObject() {
		// It should properly serialize and set the storage entries.
		final service = new SessionStorage();
		asserts.assert(window.sessionStorage.getItem("foo") == null);

		service.setObject("foo", 123);
		asserts.assert(window.sessionStorage.getItem("foo") == "123");

		service.setObject("foo", "bar");
		asserts.assert(window.sessionStorage.getItem("foo") == '"bar"');

		service.setObject("foo", {key: "value"});
		asserts.assert(window.sessionStorage.getItem("foo") == '{"key":"value"}');

		// It should support the key prefix.
		final service = new SessionStorage({keyPrefix: "prefix:"});
		asserts.assert(window.sessionStorage.getItem("prefix:foo") == null);

		service.setObject("foo", 123);
		asserts.assert(window.sessionStorage.getItem("foo") == null);
		asserts.assert(window.sessionStorage.getItem("prefix:foo") == "123");

		service.setObject("foo", "bar");
		asserts.assert(window.sessionStorage.getItem("prefix:foo") == '"bar"');

		service.setObject("foo", {key: "value"});
		asserts.assert(window.sessionStorage.getItem("prefix:foo") == '{"key":"value"}');
		return asserts.done();
	}

	/** Tests the `toJSON()` method. **/
	public function testToJSON() {
		// It should return an empty map for an empty storage.
		final service = new SessionStorage();
		asserts.compare({}, service.toJSON());
		asserts.assert(Json.stringify(service) == "{}");

		// It should return a non-empty map for a non-empty storage.
		final service = new SessionStorage().set("foo", "bar").set("baz", "qux");
		asserts.compare({baz: "qux", foo: "bar"}, service.toJSON());

		final json = Json.stringify(service);
		asserts.assert(json.contains('"foo":"bar"'));
		asserts.assert(json.contains('"baz":"qux"'));

		// It should support the key prefix.
		final service = new SessionStorage({keyPrefix: "prefix:"}).set("foo", "bar").set("baz", "qux");
		asserts.compare({"prefix:baz": "qux", "prefix:foo": "bar"}, service.toJSON());

		final json = Json.stringify(service);
		asserts.assert(json.contains('"prefix:foo":"bar"'));
		asserts.assert(json.contains('"prefix:baz":"qux"'));
		return asserts.done();
	}
}
