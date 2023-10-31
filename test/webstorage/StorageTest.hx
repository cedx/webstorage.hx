package webstorage;

import js.Browser.window;
import tink.Json;
using StringTools;

/** Tests the features of the `Storage` class. **/
@:asserts final class StorageTest {

	/** Creates a new test. **/
	public function new() {}

	/** Method invoked before each test. **/
	@:before public function before() {
		window.sessionStorage.clear();
		return Noise;
	}

	/** Tests the `keys` property. **/
	public function keys() {
		// It should return an empty array for an empty storage.
		final service = Storage.session();
		asserts.assert(service.keys.length == 0);

		// It should return the list of keys for a non-empty storage.
		setStorage("foo", "bar");
		setStorage("prefix:baz", "qux");

		var keys = service.keys;
		asserts.assert(keys.length == 2);
		asserts.assert(keys.contains("foo") && keys.contains("prefix:baz"));

		// It should handle the key prefix.
		keys = Storage.session({keyPrefix: "prefix:"}).keys;
		asserts.assert(keys.length == 1 && keys.pop() == "baz");

		return asserts.done();
	}

	/** Tests the `length` property. **/
	public function length() {
		// It should return zero for an empty storage.
		final service = Storage.session();
		asserts.assert(service.length == 0);

		// It should return the number of entries for a non-empty storage.
		setStorage("foo", "bar");
		setStorage("prefix:baz", "qux");
		asserts.assert(service.length == 2);

		// It should handle the key prefix.
		asserts.assert(Storage.session({keyPrefix: "prefix:"}).length == 1);
		return asserts.done();
	}

	/** Tests the `onChange` property. **/
	public function onChange() {
		// It should trigger an event when a value is added.
		var service = Storage.session();
		var subscription = service.onChange.handle(event -> {
			asserts.assert(event.key.equals("foo"));
			asserts.assert(event.oldValue == None);
			asserts.assert(event.newValue.equals("bar"));
		});

		service.set("foo", "bar");
		subscription.cancel();

		// It should trigger an event when a value is updated.
		subscription = service.onChange.handle(event -> {
			asserts.assert(event.key.equals("foo"));
			asserts.assert(event.oldValue.equals("bar"));
			asserts.assert(event.newValue.equals("baz"));
		});

		service.set("foo", "baz");
		subscription.cancel();

		// It should not trigger an event when a value is neither added nor updated.
		subscription = service.onChange.handle(event -> asserts.fail("This event should not have been triggered."));
		service.putIfAbsent("foo", () -> "qux");
		subscription.cancel();

		// It should trigger an event when a value is removed.
		subscription = service.onChange.handle(event -> {
			asserts.assert(event.key.equals("foo"));
			asserts.assert(event.oldValue.equals("baz"));
			asserts.assert(event.newValue == None);
		});

		service.remove("foo");
		subscription.cancel();

		// It should trigger an event when the storage is cleared.
		subscription = service.onChange.handle(event -> {
			asserts.assert(event.key == None);
			asserts.assert(event.oldValue == None);
			asserts.assert(event.newValue == None);
		});

		service.clear();
		subscription.cancel();

		// It should handle the key prefix.
		service = Storage.session({keyPrefix: "prefix:"});
		subscription = service.onChange.handle(event -> {
			asserts.assert(event.key.equals("baz"));
			asserts.assert(event.oldValue == None);
			asserts.assert(event.newValue.equals("qux"));
		});

		service.set("baz", "qux");
		subscription.cancel();

		return asserts.done();
	}

	/** Tests the `clear()` method. **/
	public function clear() {
		// It should remove all storage entries.
		setStorage("foo", "bar");
		setStorage("prefix:baz", "qux");

		Storage.session().clear();
		asserts.assert(window.sessionStorage.length == 0);

		// It should handle the key prefix.
		setStorage("foo", "bar");
		setStorage("prefix:baz", "qux");

		Storage.session({keyPrefix: "prefix:"}).clear();
		asserts.assert(window.sessionStorage.length == 1);

		return asserts.done();
	}

	/** Tests the `exists()` method. **/
	public function exists() {
		// It should return `false` if the specified key is not contained.
		var service = Storage.session();
		asserts.assert(!service.exists("foo"));

		// It should return `true` if the specified key is contained.
		setStorage("foo", "bar");
		setStorage("prefix:baz", "qux");

		asserts.assert(!service.exists("foo:bar"));
		asserts.assert(service.exists("foo") && service.exists("prefix:baz"));

		// It should handle the key prefix.
		service = Storage.session({keyPrefix: "prefix:"});
		asserts.assert(!service.exists("foo"));
		asserts.assert(service.exists("baz"));

		return asserts.done();
	}

	/** Tests the `get()` method. **/
	public function get() {
		// It should properly get the storage entries.
		var service = Storage.session();
		asserts.assert(service.get("foo") == None);

		setStorage("foo", "bar");
		asserts.assert(service.get("foo").equals("bar"));

		setStorage("foo", "123");
		asserts.assert(service.get("foo").equals("123"));

		removeStorage("foo");
		asserts.assert(service.get("foo") == None);

		// It should handle the key prefix.
		service = Storage.session({keyPrefix: "prefix:"});
		asserts.assert(service.get("baz") == None);

		setStorage("prefix:baz", "qux");
		asserts.assert(service.get("baz").equals("qux"));

		setStorage("prefix:baz", "456");
		asserts.assert(service.get("baz").equals("456"));

		removeStorage("prefix:baz");
		asserts.assert(service.get("baz") == None);

		return asserts.done();
	}

	/** Tests the `getObject()` method. **/
	public function getObject() {
		// It should properly get the deserialized storage entries.
		var service = Storage.session();
		asserts.assert(service.getObject("foo") == None);

		setStorage("foo", '"bar"');
		asserts.assert(service.getObject("foo").equals("bar"));

		setStorage("foo", "123");
		asserts.assert(service.getObject("foo").equals(123));

		setStorage("foo", '{"key": "value"}');
		asserts.compare(Some({key: "value"}), service.getObject("foo"));

		setStorage("foo", "{bar[123]}");
		asserts.assert(service.getObject("foo") == None);

		removeStorage("foo");
		asserts.assert(service.getObject("foo") == None);

		// It should handle the key prefix.
		service = Storage.session({keyPrefix: "prefix:"});
		asserts.assert(service.getObject("baz") == None);

		setStorage("prefix:baz", '"qux"');
		asserts.assert(service.getObject("baz").equals("qux"));

		setStorage("prefix:baz", "456");
		asserts.assert(service.getObject("baz").equals(456));

		setStorage("prefix:baz", '{"key": "value"}');
		asserts.compare(Some({key: "value"}), service.getObject("baz"));

		setStorage("prefix:baz", "{qux[456]}");
		asserts.assert(service.getObject("baz") == None);

		removeStorage("prefix:baz");
		asserts.assert(service.getObject("baz") == None);

		return asserts.done();
	}

	/** Tests the `keyValueIterator()` method. **/
	public function keyValueIterator() {
		final service = Storage.session();

		// It should end iteration immediately if the storage is empty.
		var iterator = service.keyValueIterator();
		asserts.assert(!iterator.hasNext());

		// It should iterate over the values if the storage is not empty.
		setStorage("foo", "bar");
		setStorage("prefix:baz", "qux");

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
	public function putIfAbsent() {
		// It should add a new entry if it does not exist.
		var service = Storage.session();
		asserts.assert(getStorage("foo") == null);
		asserts.assert(service.putIfAbsent("foo", () -> "bar").equals("bar"));
		asserts.assert(getStorage("foo") == "bar");

		// It should not add a new entry if it already exists.
		setStorage("foo", "123");
		asserts.assert(service.putIfAbsent("foo", () -> "XYZ").equals("123"));
		asserts.assert(getStorage("foo") == "123");

		// It should handle the key prefix.
		service = Storage.session({keyPrefix: "prefix:"});
		asserts.assert(getStorage("prefix:baz") == null);
		asserts.assert(service.putIfAbsent("baz", () -> "qux").equals("qux"));
		asserts.assert(getStorage("prefix:baz") == "qux");

		setStorage("prefix:baz", "456");
		asserts.assert(service.putIfAbsent("baz", () -> "XYZ").equals("456"));
		asserts.assert(getStorage("prefix:baz") == "456");

		return asserts.done();
	}

	/** Tests the `putObjectIfAbsent()` method. **/
	public function putObjectIfAbsent() {
		// It should add a new entry if it does not exist.
		var service = Storage.session();
		asserts.assert(getStorage("foo") == null);
		asserts.assert(service.putObjectIfAbsent("foo", () -> "bar").equals("bar"));
		asserts.assert(getStorage("foo") == '"bar"');

		// It should not add a new entry if it already exists.
		setStorage("foo", "123");
		asserts.assert(service.putObjectIfAbsent("foo", () -> 999).equals(123));
		asserts.assert(getStorage("foo") == "123");

		// It should handle the key prefix.
		service = Storage.session({keyPrefix: "prefix:"});
		asserts.assert(getStorage("prefix:baz") == null);
		asserts.assert(service.putObjectIfAbsent("baz", () -> "qux").equals("qux"));
		asserts.assert(getStorage("prefix:baz") == '"qux"');

		setStorage("prefix:baz", "456");
		asserts.assert(service.putObjectIfAbsent("baz", () -> 999).equals(456));
		asserts.assert(getStorage("prefix:baz") == "456");

		return asserts.done();
	}

	/** Tests the `remove()` method. **/
	public function remove() {
		setStorage("foo", "bar");
		setStorage("prefix:baz", "qux");

		// It should properly remove the storage entries.
		Storage.session().remove("foo");
		asserts.assert(window.sessionStorage.length == 1);
		asserts.assert(getStorage("foo") == null);

		// It should handle the key prefix.
		Storage.session({keyPrefix: "prefix:"}).remove("baz");
		asserts.assert(window.sessionStorage.length == 0);
		asserts.assert(getStorage("prefix:baz") == null);

		return asserts.done();
	}

	/** Tests the `set()` method. **/
	public function set() {
		// It should properly set the storage entries.
		var service = Storage.session();
		asserts.assert(getStorage("foo") == null);

		service.set("foo", "bar");
		asserts.assert(getStorage("foo") == "bar");

		service.set("foo", "123");
		asserts.assert(getStorage("foo") == "123");

		// It should handle the key prefix.
		service = Storage.session({keyPrefix: "prefix:"});
		asserts.assert(getStorage("prefix:baz") == null);

		service.set("baz", "qux");
		asserts.assert(getStorage("prefix:baz") == "qux");

		service.set("baz", "456");
		asserts.assert(getStorage("prefix:baz") == "456");

		return asserts.done();
	}

	/** Tests the `setObject()` method. **/
	public function setObject() {
		// It should properly serialize and set the storage entries.
		var service = Storage.session();
		asserts.assert(getStorage("foo") == null);

		service.setObject("foo", "bar");
		asserts.assert(getStorage("foo") == '"bar"');

		service.setObject("foo", 123);
		asserts.assert(getStorage("foo") == "123");

		service.setObject("foo", {key: "value"});
		asserts.assert(getStorage("foo") == '{"key":"value"}');

		// It should handle the key prefix.
		service = Storage.session({keyPrefix: "prefix:"});
		asserts.assert(getStorage("prefix:baz") == null);

		service.setObject("baz", "qux");
		asserts.assert(getStorage("prefix:baz") == '"qux"');

		service.setObject("baz", 456);
		asserts.assert(getStorage("prefix:baz") == "456");

		service.setObject("baz", {key: "value"});
		asserts.assert(getStorage("prefix:baz") == '{"key":"value"}');

		return asserts.done();
	}

	/** Tests the `toJSON()` method. **/
	public function toJson() {
		// It should return an empty array for an empty storage.
		final service = Storage.session();
		asserts.assert(Json.stringify(service) == "[]");

		// It should return a non-empty array for a non-empty storage.
		setStorage("foo", "bar");
		setStorage("prefix:baz", "qux");

		var json = Json.stringify(service);
		asserts.assert(json.contains('["foo","bar"]'));
		asserts.assert(json.contains('["prefix:baz","qux"]'));

		// It should handle the key prefix.
		json = Json.stringify(Storage.session({keyPrefix: "prefix:"}));
		asserts.assert(!json.contains('["foo","bar"]'));
		asserts.assert(json.contains('["baz","qux"]'));

		return asserts.done();
	}

	/** Gets the value associated with the specified storage key. **/
	inline function getStorage(key: String) return window.sessionStorage.getItem(key);

	/** Removes the value associated with the specified storage key. **/
	inline function removeStorage(key: String) window.sessionStorage.removeItem(key);

	/** Associates a value with the specified storage key. **/
	inline function setStorage(key: String, value: String) window.sessionStorage.setItem(key, value);
}
