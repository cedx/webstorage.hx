package webstorage;

import Mocha.*;
import haxe.Json;
import js.Browser;
import utest.Assert;

/** Tests the features of the `WebStorage` class. **/
class WebStorageTest {

	/** The native session storage. **/
	final sessionStorage = Browser.window.sessionStorage;

	/** Creates a new test suite. **/
	public function new() {}

	/** Runs the tests. **/
	public function run(): Void {
		beforeEach(() -> sessionStorage.clear());
		describe(".keys", testKeys);
		describe(".length", testLength);
		describe(".addEventListener('change')", testAddEventListener);
		describe(".clear()", testLength);
		describe(".exists()", testExists);
		describe(".get()", testGet);
		describe(".getObject()", testGetObject);
		describe(".keyValueIterator()", testKeyValueIterator);
		describe(".putIfAbsent()", testPutIfAbsent);
		describe(".putObjectIfAbsent()", testPutObjectIfAbsent);
		describe(".remove()", testRemove);
		describe(".set()", testSet);
		describe(".setObject()", testSetObject);
		describe(".toJSON()", testToJSON);
	}

	/** Tests the `keys` property. **/
	function testKeys(): Void {
		it("should return an empty array for an empty storage", function() {
			Assert.equals(0, new SessionStorage().keys.length);
		});

		it("should return the list of keys for a non-empty storage", function() {
			sessionStorage.setItem("foo", "bar");
			sessionStorage.setItem("bar", "baz");

			final keys = new SessionStorage().keys;
			Assert.equals(2, keys.length);
			Assert.equals("foo", keys[0]);
			Assert.equals("bar", keys[1]);
		});
	}

	/** Tests the `length` property. **/
	function testLength(): Void {
		it("should return zero for an empty storage", function() {
			Assert.equals(0, new SessionStorage().length);
		});

		it("should return the number of entries for a non-empty storage", function() {
			sessionStorage.setItem("foo", "bar");
			sessionStorage.setItem("bar", "baz");
			Assert.equals(2, new SessionStorage().length);
		});
	}

	/** Tests the `addEventListener("change")` method. **/
	function testAddEventListener(): Void {
		it("should trigger an event when a value is added", function(done) {
			final listener = event -> {
				Assert.equals("foo", event.key);
				Assert.isNull(event.oldValue);
				Assert.equals("bar", event.newValue);
				done();
			};

			final service = new SessionStorage();
			service.addEventListener("change", listener);
			service.set("foo", "bar");
			service.removeEventListener("change", listener);
		});

		it("should trigger an event when a value is updated", function(done) {
			sessionStorage.setItem("foo", "bar");

			final listener = event -> {
				Assert.equals("foo", event.key);
				Assert.equals("bar", event.oldValue);
				Assert.equals("baz", event.newValue);
				done();
			};

			final service = new SessionStorage();
			service.addEventListener("change", listener);
			service.set("foo", "baz");
			service.removeEventListener("change", listener);
		});

		it("should trigger an event when a value is removed", function(done) {
			sessionStorage.setItem("foo", "bar");

			final listener = event -> {
				Assert.equals("foo", event.key);
				Assert.equals("bar", event.oldValue);
				Assert.isNull(event.newValue);
				done();
			};

			final service = new SessionStorage();
			service.addEventListener("change", listener);
			service.remove("foo");
			service.removeEventListener("change", listener);
		});

		it("should trigger an event when the storage is cleared", function(done) {
			sessionStorage.setItem("foo", "bar");
			sessionStorage.setItem("bar", "baz");

			final listener = event -> {
				Assert.isNull(event.key);
				Assert.isNull(event.oldValue);
				Assert.isNull(event.newValue);
				done();
			};

			final service = new SessionStorage();
			service.addEventListener("change", listener);
			service.clear();
			service.removeEventListener("change", listener);
		});
	}

	/** Tests the `clear()` method. **/
	function testClear(): Void {
		it("should remove all storage entries", function() {
			sessionStorage.setItem("foo", "bar");
			sessionStorage.setItem("bar", "baz");

			final service = new SessionStorage();
			Assert.equals(2, service.length);
			service.clear();
			Assert.equals(0, service.length);
		});
	}

	/** Tests the `exists()` method. **/
	function testExists(): Void {
		it("should return `false` if the specified key is not contained", function() {
			Assert.isFalse(new SessionStorage().exists("foo"));
		});

		it("should return `true` if the specified key is contained", function() {
			final service = new SessionStorage();
			sessionStorage.setItem("foo", "bar");
			Assert.isTrue(service.exists("foo"));
			Assert.isFalse(service.exists("bar"));
		});
	}

	/** Tests the `get()` method. **/
	function testGet(): Void {
		it("should properly get the storage entries", function() {
			final service = new SessionStorage();
			Assert.isNull(service.get("foo"));

			sessionStorage.setItem("foo", "bar");
			Assert.equals("bar", service.get("foo"));

			sessionStorage.setItem("foo", "123");
			Assert.equals("123", service.get("foo"));
		});

		it("should return the given default value if the key is not found", function() {
			Assert.equals("123", new SessionStorage().get("bar", "123"));
		});
	}

	/** Tests the `getObject()` method. **/
	function testGetObject(): Void {
		it("should properly get the deserialized storage entries", function() {
			final service = new SessionStorage();
			Assert.isNull(service.getObject("foo"));

			sessionStorage.setItem("foo", "123");
			Assert.equals(123, service.getObject("foo"));

			sessionStorage.setItem("foo", '"bar"');
			Assert.equals("bar", service.getObject("foo"));

			sessionStorage.setItem("foo", '{"key": "value"}');
			Assert.same({key: "value"}, service.getObject("foo"));
		});

		it("should return the default value if the value can't be deserialized", function() {
			sessionStorage.setItem("foo", "bar");
			Assert.equals("defaultValue", new SessionStorage().getObject("foo", "defaultValue"));
		});
	}

	/** Tests the `keyValueIterator()` method. **/
	function testKeyValueIterator(): Void {
		it("should end iteration immediately if storage is empty", function() {
			final iterator = new SessionStorage().keyValueIterator();
			Assert.isFalse(iterator.hasNext());
		});

		it("should iterate over the values if storage is not empty", function() {
			sessionStorage.setItem("foo", "bar");
			sessionStorage.setItem("bar", "baz");

			final iterator = new SessionStorage().keyValueIterator();
			Assert.isTrue(iterator.hasNext());
			Assert.same({key: "foo", value: "bar"}, iterator.next());
			Assert.isTrue(iterator.hasNext());
			Assert.same({key: "bar", value: "baz"}, iterator.next());
			Assert.isFalse(iterator.hasNext());
		});
	}

	/** Tests the `putIfAbsent()` method. **/
	function testPutIfAbsent(): Void {
		it("should add a new entry if it does not exist", function() {
			final service = new SessionStorage();
			Assert.isNull(sessionStorage.getItem("foo"));
			Assert.equals("bar", service.putIfAbsent("foo", () -> "bar"));
			Assert.equals("bar", sessionStorage.getItem("foo"));
		});

		it("should not add a new entry if it already exists", function() {
			final service = new SessionStorage();
			sessionStorage.setItem("foo", "bar");
			Assert.equals("bar", service.putIfAbsent("foo", () -> "qux"));
			Assert.equals("bar", sessionStorage.getItem("foo"));
		});
	}

	/** Tests the `putObjectIfAbsent()` method. **/
	function testPutObjectIfAbsent(): Void {
		it("should add a new entry if it does not exist", function() {
			final service = new SessionStorage();
			Assert.isNull(sessionStorage.getItem("foo"));
			Assert.equals(123, service.putObjectIfAbsent("foo", () -> 123));
			Assert.equals("123", sessionStorage.getItem("foo"));
		});

		it("should not add a new entry if it already exists", function() {
			final service = new SessionStorage();
			sessionStorage.setItem("foo", "123");
			Assert.equals(123, service.putObjectIfAbsent("foo", () -> 456));
			Assert.equals("123", sessionStorage.getItem("foo"));
		});
	}

	/** Tests the `remove()` method. **/
	function testRemove(): Void {
		it("should properly remove the storage entries", function() {
			final service = new SessionStorage();
			sessionStorage.setItem("foo", "bar");
			sessionStorage.setItem("bar", "baz");
			Assert.equals("bar", sessionStorage.getItem("foo"));

			service.remove("foo");
			Assert.isNull(sessionStorage.getItem("foo"));
			Assert.equals("baz", sessionStorage.getItem("bar"));

			service.remove("bar");
			Assert.isNull(sessionStorage.getItem("bar"));
		});
	}

	/** Tests the `set()` method. **/
	function testSet(): Void {
		it("should properly set the storage entries", function() {
			final service = new SessionStorage();
			Assert.isNull(sessionStorage.getItem("foo"));
			service.set("foo", "bar");
			Assert.equals("bar", sessionStorage.getItem("foo"));
			service.set("foo", "123");
			Assert.equals("123", sessionStorage.getItem("foo"));
		});
	}

	/** Tests the `setObject()` method. **/
	function testSetObject(): Void {
		it("should properly serialize and set the storage entries", function() {
			final service = new SessionStorage();
			Assert.isNull(sessionStorage.getItem("foo"));
			service.setObject("foo", 123);
			Assert.equals("123", sessionStorage.getItem("foo"));
			service.setObject("foo", "bar");
			Assert.equals('"bar"', sessionStorage.getItem("foo"));
			service.setObject("foo", {key: "value"});
			Assert.equals('{"key":"value"}', sessionStorage.getItem("foo"));
		});
	}

	/** Tests the `toJSON()` method. **/
	function testToJSON(): Void {
		it("should return an empty map for an empty storage", function() {
			final service = new SessionStorage();
			Assert.same({}, service.toJSON());
			Assert.equals("{}", Json.stringify(service));
		});

		it("should return a non-empty map for a non-empty storage", function() {
			final service = new SessionStorage().set("foo", "bar").set("baz", "qux");
			Assert.same({baz: "qux", foo: "bar"}, service.toJSON());

			final json = Json.stringify(service);
			Assert.stringContains('"foo":"bar"', json);
			Assert.stringContains('"baz":"qux"', json);
		});
	}
}
