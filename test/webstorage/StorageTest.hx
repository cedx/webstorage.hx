package webstorage;

import js.Browser.window;

#if tink_json
import tink.Json;
#else
import haxe.Json;
#end

using StringTools;

/** Tests the features of the `Storage` class. **/
@:asserts class StorageTest {

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
		final service = Storage.session();
		asserts.assert(service.keys.length == 0);

		// It should return the list of keys for a non-empty storage.
		window.sessionStorage.setItem("foo", "bar");
		window.sessionStorage.setItem("prefix:baz", "qux");

		var keys = service.keys;
		asserts.assert(keys.length == 2);
		asserts.assert(keys.contains("foo") && keys.contains("prefix:baz"));

		// It should handle the key prefix.
		keys = Storage.session({keyPrefix: "prefix:"}).keys;
		asserts.assert(keys.length == 1 && keys[0] == "baz");

		return asserts.done();
	}

	/** Tests the `length` property. **/
	public function testLength() {
		// It should return zero for an empty storage.
		final service = Storage.session();
		asserts.assert(service.length == 0);

		// It should return the number of entries for a non-empty storage.
		window.sessionStorage.setItem("foo", "bar");
		window.sessionStorage.setItem("prefix:baz", "qux");
		asserts.assert(service.length == 2);

		// It should handle the key prefix.
		asserts.assert(Storage.session({keyPrefix: "prefix:"}).length == 1);
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

		final service = Storage.session();
		service.addEventListener("change", listener);
		service.setString("foo", "bar");
		service.removeEventListener("change", listener);

		// It should trigger an event when a value is updated", public function(done) {
		window.sessionStorage.setItem("foo", "bar");

		final listener = event -> {
			asserts.equals("foo", event.key);
			asserts.equals("bar", event.oldValue);
			asserts.equals("baz", event.newValue);
			done();
		};

		final service = Storage.session();
		service.addEventListener("change", listener);
		service.setString("foo", "baz");
		service.removeEventListener("change", listener);

		// It should trigger an event when a value is removed", public function(done) {
		window.sessionStorage.setItem("foo", "bar");

		final listener = event -> {
			asserts.equals("foo", event.key);
			asserts.equals("bar", event.oldValue);
			asserts.assert(event.newValue == null);
			done();
		};

		final service = Storage.session();
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

		final service = Storage.session();
		service.addEventListener("change", listener);
		service.clear();
		service.removeEventListener("change", listener);

		return asserts.done();
	}*/

	/** Tests the `clear()` method. **/
	public function testClear() {
		// It should remove all storage entries.
		window.sessionStorage.setItem("foo", "bar");
		window.sessionStorage.setItem("prefix:baz", "qux");

		Storage.session().clear();
		asserts.assert(window.sessionStorage.length == 0);

		// It should handle the key prefix.
		window.sessionStorage.setItem("foo", "bar");
		window.sessionStorage.setItem("prefix:baz", "qux");

		Storage.session({keyPrefix: "prefix:"}).clear();
		asserts.assert(window.sessionStorage.length == 1);

		return asserts.done();
	}

	/** Tests the `exists()` method. **/
	public function testExists() {
		// It should return `false` if the specified key is not contained.
		var service = Storage.session();
		asserts.assert(!service.exists("foo"));

		// It should return `true` if the specified key is contained.
		window.sessionStorage.setItem("foo", "bar");
		window.sessionStorage.setItem("prefix:baz", "qux");

		asserts.assert(!service.exists("foo:bar"));
		asserts.assert(service.exists("foo") && service.exists("prefix:baz"));

		// It should handle the key prefix.
		service = Storage.session({keyPrefix: "prefix:"});
		asserts.assert(!service.exists("foo"));
		asserts.assert(service.exists("baz"));

		return asserts.done();
	}

	/** Tests the `get()` method. **/
	public function testGet() {
		// It should properly get the deserialized storage entries.
		var service = Storage.session();
		asserts.assert(service.get("foo") == null);

		window.sessionStorage.setItem("foo", '"bar"');
		asserts.assert(service.get("foo") == "bar");

		window.sessionStorage.setItem("foo", "123");
		asserts.assert(service.get("foo") == 123);

		window.sessionStorage.setItem("foo", '{"key": "value"}');
		asserts.compare({key: "value"}, service.get("foo"));

		window.sessionStorage.setItem("foo", 'bar123');
		asserts.assert(service.get("foo") == null);

		final defaultValue = {k: "_Oops_"};
		window.sessionStorage.removeItem("foo");
		asserts.assert(service.get("foo", defaultValue) == defaultValue);

		// It should handle the key prefix.
		var service = Storage.session({keyPrefix: "prefix:"});
		asserts.assert(service.get("baz") == null);

		window.sessionStorage.setItem("prefix:baz", '"qux"');
		asserts.assert(service.get("baz") == "qux");

		window.sessionStorage.setItem("prefix:baz", "456");
		asserts.assert(service.get("baz") == 456);

		window.sessionStorage.setItem("prefix:baz", '{"key": "value"}');
		asserts.compare({key: "value"}, service.get("baz"));

		window.sessionStorage.setItem("prefix:baz", 'qux456');
		asserts.assert(service.get("baz") == null);

		final defaultValue = {k: "_Oops_"};
		window.sessionStorage.removeItem("prefix:baz");
		asserts.assert(service.get("baz", defaultValue) == defaultValue);

		return asserts.done();
	}

	/** Tests the `getString()` method. **/
	public function testGetString() {
		// It should properly get the storage entries.
		var service = Storage.session();
		asserts.assert(service.getString("foo") == null);

		window.sessionStorage.setItem("foo", "bar");
		asserts.assert(service.getString("foo") == "bar");

		window.sessionStorage.setItem("foo", "123");
		asserts.assert(service.getString("foo") == "123");

		window.sessionStorage.removeItem("foo");
		asserts.assert(service.getString("foo", "_Oops_") == "_Oops_");

		// It should handle the key prefix.
		var service = Storage.session({keyPrefix: "prefix:"});
		asserts.assert(service.getString("baz") == null);

		window.sessionStorage.setItem("prefix:baz", "qux");
		asserts.assert(service.getString("baz") == "qux");

		window.sessionStorage.setItem("prefix:baz", "456");
		asserts.assert(service.getString("baz") == "456");

		window.sessionStorage.removeItem("prefix:baz");
		asserts.assert(service.getString("baz", "_Oops_") == "_Oops_");

		return asserts.done();
	}

	/** Tests the `keyValueIterator()` method. **/
	/*
	public function testKeyValueIterator() {
		// It should end iteration immediately if the storage is empty.
		final service = Storage.session();
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
	}*/

	/** Tests the `putIfAbsent()` method. **/
	/*
	public function testPutIfAbsent() {
		// It should add a new entry if it does not exist.
		final service = Storage.session();
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
		final service = Storage.session({keyPrefix: "prefix:"});
		window.sessionStorage.setItem("prefix:foo", "bar");
		asserts.assert(service.putIfAbsent("foo", () -> "qux") == "bar");
		asserts.assert(window.sessionStorage.getItem("prefix:foo") == "bar");
		asserts.assert(service.putIfAbsent("bar", () -> "qux") == "qux");
		asserts.assert(window.sessionStorage.getItem("prefix:bar") == "qux");

		return asserts.done();
	}*/

	/** Tests the `putObjectIfAbsent()` method. **/
	/*
	public function testPutObjectIfAbsent() {
		// It should add a new entry if it does not exist.
		final service = Storage.session();
		asserts.assert(window.sessionStorage.getItem("foo") == null);
		asserts.assert(service.putObjectIfAbsent("foo", () -> 123) == 123);
		asserts.assert(window.sessionStorage.getItem("foo") == "123");

		// It should not add a new entry if it already exists.
		final service = Storage.session();
		window.sessionStorage.setItem("foo", "123");
		asserts.assert(service.putObjectIfAbsent("foo", () -> 456) == 123);
		asserts.assert(window.sessionStorage.getItem("foo") == "123");
		asserts.assert(service.putObjectIfAbsent("bar", () -> 456) == 456);
		asserts.assert(window.sessionStorage.getItem("bar") == "456");

		// It should support the key prefix.
		final service = Storage.session({keyPrefix: "prefix:"});
		window.sessionStorage.setItem("prefix:foo", "123");
		asserts.assert(service.putObjectIfAbsent("foo", () -> 456) == 123);
		asserts.assert(window.sessionStorage.getItem("prefix:foo") == "123");
		asserts.assert(service.putObjectIfAbsent("bar", () -> 456) == 456);
		asserts.assert(window.sessionStorage.getItem("prefix:bar") == "456");

		return asserts.done();
	}*/

	/** Tests the `remove()` method. **/
	public function testRemove() {
		window.sessionStorage.setItem("foo", "bar");
		window.sessionStorage.setItem("prefix:baz", "qux");

		// It should properly remove the storage entries.
		Storage.session().remove("foo");
		asserts.assert(window.sessionStorage.length == 1);
		asserts.assert(window.sessionStorage.getItem("foo") == null);

		// It should handle the key prefix.
		Storage.session({keyPrefix: "prefix:"}).remove("baz");
		asserts.assert(window.sessionStorage.length == 0);
		asserts.assert(window.sessionStorage.getItem("prefix:baz") == null);

		return asserts.done();
	}

	/** Tests the `setString()` method. **/
	/*
	public function testSetString() {
		// It should properly set the storage entries.
		final service = Storage.session();
		asserts.assert(window.sessionStorage.getItem("foo") == null);

		service.setString("foo", "bar");
		asserts.assert(window.sessionStorage.getItem("foo") == "bar");

		service.setString("foo", "123");
		asserts.assert(window.sessionStorage.getItem("foo") == "123");

		// It should support the key prefix.
		final service = Storage.session({keyPrefix: "prefix:"});
		asserts.assert(window.sessionStorage.getItem("prefix:foo") == null);

		service.setString("foo", "bar");
		asserts.assert(window.sessionStorage.getItem("foo") == null);
		asserts.assert(window.sessionStorage.getItem("prefix:foo") == "bar");

		service.setString("foo", "123");
		asserts.assert(window.sessionStorage.getItem("prefix:foo") == "123");
		return asserts.done();
	}*/

	/** Tests the `setObject()` method. **/
	/*
	public function testSetObject() {
		// It should properly serialize and set the storage entries.
		final service = Storage.session();
		asserts.assert(window.sessionStorage.getItem("foo") == null);

		service.setObject("foo", 123);
		asserts.assert(window.sessionStorage.getItem("foo") == "123");

		service.setObject("foo", "bar");
		asserts.assert(window.sessionStorage.getItem("foo") == '"bar"');

		service.setObject("foo", {key: "value"});
		asserts.assert(window.sessionStorage.getItem("foo") == '{"key":"value"}');

		// It should support the key prefix.
		final service = Storage.session({keyPrefix: "prefix:"});
		asserts.assert(window.sessionStorage.getItem("prefix:foo") == null);

		service.setObject("foo", 123);
		asserts.assert(window.sessionStorage.getItem("foo") == null);
		asserts.assert(window.sessionStorage.getItem("prefix:foo") == "123");

		service.setObject("foo", "bar");
		asserts.assert(window.sessionStorage.getItem("prefix:foo") == '"bar"');

		service.setObject("foo", {key: "value"});
		asserts.assert(window.sessionStorage.getItem("prefix:foo") == '{"key":"value"}');
		return asserts.done();
	}*/

	/** Tests the `toJSON()` method. **/
	/*
	public function testToJSON() {
		// It should return an empty map for an empty storage.
		final service = Storage.session();
		asserts.compare({}, service.toJSON());
		asserts.assert(Json.stringify(service) == "{}");

		// It should return a non-empty map for a non-empty storage.
		final service = Storage.session().setString("foo", "bar").setString("baz", "qux");
		asserts.compare({baz: "qux", foo: "bar"}, service.toJSON());

		final json = Json.stringify(service);
		asserts.assert(json.contains('"foo":"bar"'));
		asserts.assert(json.contains('"baz":"qux"'));

		// It should support the key prefix.
		final service = Storage.session({keyPrefix: "prefix:"}).setString("foo", "bar").setString("baz", "qux");
		asserts.compare({"prefix:baz": "qux", "prefix:foo": "bar"}, service.toJSON());

		final json = Json.stringify(service);
		asserts.assert(json.contains('"prefix:foo":"bar"'));
		asserts.assert(json.contains('"prefix:baz":"qux"'));
		return asserts.done();
	}*/
}
