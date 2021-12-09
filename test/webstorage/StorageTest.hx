package webstorage;

import js.Browser.window;
import #if tink_json tink.Json #else haxe.Json #end;

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

	/** Tests the `onChange` property. **/
	public function testOnChange() {
		var service = Storage.session();

		// It should trigger an event when a value is added.
		var subscription = service.onChange.handle(event -> {
			asserts.assert(event.key == "foo");
			asserts.assert(event.oldValue == null);
			asserts.assert(event.newValue == "bar");
			asserts.assert(event.storageArea == window.sessionStorage);
		});

		service.set("foo", "bar");
		subscription.cancel();

		// It should trigger an event when a value is updated.
		subscription = service.onChange.handle(event -> {
			asserts.assert(event.key == "foo");
			asserts.assert(event.oldValue == "bar");
			asserts.assert(event.newValue == "baz");
			asserts.assert(event.storageArea == window.sessionStorage);
		});

		service.set("foo", "baz");
		subscription.cancel();

		// It should not trigger an event when a value is neither added nor updated.
		subscription = service.onChange.handle(event -> asserts.fail("This event should not have been triggered."));
		service.putIfAbsent("foo", () -> "qux");
		subscription.cancel();

		// It should trigger an event when a value is removed.
		subscription = service.onChange.handle(event -> {
			asserts.assert(event.key == "foo");
			asserts.assert(event.oldValue == "baz");
			asserts.assert(event.newValue == null);
			asserts.assert(event.storageArea == window.sessionStorage);
		});

		service.remove("foo");
		subscription.cancel();

		// It should trigger an event when the storage is cleared.
		subscription = service.onChange.handle(event -> {
			asserts.assert(event.key == null);
			asserts.assert(event.oldValue == null);
			asserts.assert(event.newValue == null);
			asserts.assert(event.storageArea == window.sessionStorage);
		});

		service.clear();
		subscription.cancel();

		// It should handle the key prefix.
		service = Storage.session({keyPrefix: "prefix:"});
		subscription = service.onChange.handle(event -> {
			asserts.assert(event.key == "prefix:baz");
			asserts.assert(event.oldValue == null);
			asserts.assert(event.newValue == "qux");
			asserts.assert(event.storageArea == window.sessionStorage);
		});

		service.set("baz", "qux");
		subscription.cancel();

		return asserts.done();
	}

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
		// It should properly get the storage entries.
		var service = Storage.session();
		asserts.assert(service.get("foo") == null);

		window.sessionStorage.setItem("foo", "bar");
		asserts.assert(service.get("foo") == "bar");

		window.sessionStorage.setItem("foo", "123");
		asserts.assert(service.get("foo") == "123");

		window.sessionStorage.removeItem("foo");
		asserts.assert(service.get("foo", "_Oops_") == "_Oops_");

		// It should handle the key prefix.
		service = Storage.session({keyPrefix: "prefix:"});
		asserts.assert(service.get("baz") == null);

		window.sessionStorage.setItem("prefix:baz", "qux");
		asserts.assert(service.get("baz") == "qux");

		window.sessionStorage.setItem("prefix:baz", "456");
		asserts.assert(service.get("baz") == "456");

		window.sessionStorage.removeItem("prefix:baz");
		asserts.assert(service.get("baz", "_Oops_") == "_Oops_");

		return asserts.done();
	}

	/** Tests the `getObject()` method. **/
	public function testGetObject() {
		// It should properly get the deserialized storage entries.
		var service = Storage.session();
		asserts.assert(service.getObject("foo") == null);

		window.sessionStorage.setItem("foo", '"bar"');
		asserts.assert(service.getObject("foo") == "bar");

		window.sessionStorage.setItem("foo", "123");
		asserts.assert(service.getObject("foo") == 123);

		window.sessionStorage.setItem("foo", '{"key": "value"}');
		asserts.compare({key: "value"}, service.getObject("foo"));

		window.sessionStorage.setItem("foo", "{bar[123]}");
		asserts.assert(service.getObject("foo") == null);

		var defaultValue = {k: "_Oops_"};
		window.sessionStorage.removeItem("foo");
		asserts.assert(service.getObject("foo", defaultValue) == defaultValue);

		// It should handle the key prefix.
		service = Storage.session({keyPrefix: "prefix:"});
		asserts.assert(service.getObject("baz") == null);

		window.sessionStorage.setItem("prefix:baz", '"qux"');
		asserts.assert(service.getObject("baz") == "qux");

		window.sessionStorage.setItem("prefix:baz", "456");
		asserts.assert(service.getObject("baz") == 456);

		window.sessionStorage.setItem("prefix:baz", '{"key": "value"}');
		asserts.compare({key: "value"}, service.getObject("baz"));

		window.sessionStorage.setItem("prefix:baz", "{qux[456]}");
		asserts.assert(service.getObject("baz") == null);

		defaultValue = {k: "_Oops_"};
		window.sessionStorage.removeItem("prefix:baz");
		asserts.assert(service.getObject("baz", defaultValue) == defaultValue);

		return asserts.done();
	}

	/** Tests the `keyValueIterator()` method. **/
	public function testKeyValueIterator() {
		final service = Storage.session();

		// It should end iteration immediately if the storage is empty.
		var iterator = service.keyValueIterator();
		asserts.assert(!iterator.hasNext());

		// It should iterate over the values if the storage is not empty.
		window.sessionStorage.setItem("foo", "bar");
		window.sessionStorage.setItem("prefix:baz", "qux");

		iterator = service.keyValueIterator();
		asserts.assert(iterator.hasNext());
		asserts.compare({key: "foo", value: "bar"}, iterator.next());
		asserts.assert(iterator.hasNext());
		asserts.compare({key: "prefix:baz", value: "qux"}, iterator.next());
		asserts.assert(!iterator.hasNext());

		// It should handle the key prefix.
		iterator = Storage.session({keyPrefix: "prefix:"}).keyValueIterator();
		asserts.assert(iterator.hasNext());
		asserts.compare({key: "baz", value: "qux"}, iterator.next());
		asserts.assert(!iterator.hasNext());

		return asserts.done();
	}

	/** Tests the `putIfAbsent()` method. **/
	/*
	public function testPutIfAbsent() {
		// It should add a new entry if it does not exist.
		final service = Storage.session();
		asserts.assert(window.sessionStorage.getItem("foo") == null);
		asserts.assert(service.putIfAbsent("foo", () -> 123) == 123);
		asserts.assert(window.sessionStorage.getItem("foo") == "123");

		// It should not add a new entry if it already exists.
		final service = Storage.session();
		window.sessionStorage.setItem("foo", "123");
		asserts.assert(service.putIfAbsent("foo", () -> 456) == 123);
		asserts.assert(window.sessionStorage.getItem("foo") == "123");
		asserts.assert(service.putIfAbsent("bar", () -> 456) == 456);
		asserts.assert(window.sessionStorage.getItem("bar") == "456");

		// It should handle the key prefix.
		final service = Storage.session({keyPrefix: "prefix:"});
		window.sessionStorage.setItem("prefix:baz", "123");
		asserts.assert(service.putIfAbsent("foo", () -> 456) == 123);
		asserts.assert(window.sessionStorage.getItem("prefix:baz") == "123");
		asserts.assert(service.putIfAbsent("bar", () -> 456) == 456);
		asserts.assert(window.sessionStorage.getItem("prefix:bar") == "456");

		return asserts.done();
	}*/

	/** Tests the `putStringIfAbsent()` method. **/
	/*
	public function testPutStringIfAbsent() {
		// It should add a new entry if it does not exist.
		var service = Storage.session();
		asserts.assert(window.sessionStorage.getItem("foo") == null);
		asserts.assert(service.putStringIfAbsent("foo", () -> "bar") == "bar");
		asserts.assert(window.sessionStorage.getItem("foo") == "bar");

		// It should not add a new entry if it already exists.
		window.sessionStorage.setItem("foo", "bar");
		asserts.assert(service.putStringIfAbsent("foo", () -> "123") == "bar");
		asserts.assert(window.sessionStorage.getItem("foo") == "bar");
		asserts.assert(service.putStringIfAbsent("baz", () -> "qux") == "qux");
		asserts.assert(window.sessionStorage.getItem("baz") == "qux");

		// It should handle the key prefix.
		service = Storage.session({keyPrefix: "prefix:"});
		window.sessionStorage.setItem("prefix:baz", "qux");
		asserts.assert(service.putStringIfAbsent("foo", () -> "qux") == "bar");
		asserts.assert(window.sessionStorage.getItem("prefix:baz") == "bar");
		asserts.assert(service.putStringIfAbsent("bar", () -> "qux") == "qux");
		asserts.assert(window.sessionStorage.getItem("prefix:bar") == "qux");

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

	/** Tests the `set()` method. **/
	public function testSetString() {
		// It should properly set the storage entries.
		var service = Storage.session();
		asserts.assert(window.sessionStorage.getItem("foo") == null);

		service.set("foo", "bar");
		asserts.assert(window.sessionStorage.getItem("foo") == "bar");

		service.set("foo", "123");
		asserts.assert(window.sessionStorage.getItem("foo") == "123");

		// It should handle the key prefix.
		service = Storage.session({keyPrefix: "prefix:"});
		asserts.assert(window.sessionStorage.getItem("prefix:baz") == null);

		service.set("baz", "qux");
		asserts.assert(window.sessionStorage.getItem("prefix:baz") == "qux");

		service.set("baz", "456");
		asserts.assert(window.sessionStorage.getItem("prefix:baz") == "456");

		return asserts.done();
	}

	/** Tests the `setObject()` method. **/
	public function testSetObject() {
		// It should properly serialize and set the storage entries.
		var service = Storage.session();
		asserts.assert(window.sessionStorage.getItem("foo") == null);

		service.setObject("foo", "bar");
		asserts.assert(window.sessionStorage.getItem("foo") == '"bar"');

		service.setObject("foo", 123);
		asserts.assert(window.sessionStorage.getItem("foo") == "123");

		service.setObject("foo", {key: "value"});
		asserts.assert(window.sessionStorage.getItem("foo") == '{"key":"value"}');

		// It should handle the key prefix.
		service = Storage.session({keyPrefix: "prefix:"});
		asserts.assert(window.sessionStorage.getItem("prefix:baz") == null);

		service.setObject("baz", "qux");
		asserts.assert(window.sessionStorage.getItem("prefix:baz") == '"qux"');

		service.setObject("baz", 456);
		asserts.assert(window.sessionStorage.getItem("prefix:baz") == "456");

		service.setObject("baz", {key: "value"});
		asserts.assert(window.sessionStorage.getItem("prefix:baz") == '{"key":"value"}');

		return asserts.done();
	}

	/** Tests the `toJSON()` method. **/
	public function testToJson() {
		// It should return an empty array for an empty storage.
		final service = Storage.session();
		asserts.assert(Json.stringify(service) == "[]");

		// It should return a non-empty array for a non-empty storage.
		window.sessionStorage.setItem("foo", "bar");
		window.sessionStorage.setItem("prefix:baz", "qux");

		var json = Json.stringify(service);
		asserts.assert(json.contains('["foo","bar"]'));
		asserts.assert(json.contains('["prefix:baz","qux"]'));

		// It should handle the key prefix.
		json = Json.stringify(Storage.session({keyPrefix: "prefix:"}));
		asserts.assert(!json.contains('["foo","bar"]'));
		asserts.assert(json.contains('["baz","qux"]'));

		return asserts.done();
	}
}
