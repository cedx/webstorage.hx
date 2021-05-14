package webstorage;

import haxe.DynamicAccess;
import haxe.Json;
import js.Browser;
import js.html.EventTarget;
import js.html.Storage;
import js.html.StorageEvent;

/** Provides access to the [Web Storage](https://developer.mozilla.org/en-US/docs/Web/API/Storage). **/
#if tink_json
@:jsonStringify(webstorage.WebStorage.toJson)
#end
class WebStorage extends EventTarget {

	/** A string prefixed to every key so that it is unique globally in the whole storage. **/
	public var keyPrefix: String;

	/** The keys of this storage. **/
	public var keys(get, never): Array<String>;

	/** The number of entries in this storage. **/
	public var length(get, never): Int;

	/** The underlying data store. **/
	final backend: Storage;

	/** The function that listens for storage events. **/
	final listener: Null<StorageEvent -> Void>;

	/** Creates a new storage service. **/
	function new(backend: Storage, ?options: WebStorageOptions) {
		super();

		this.backend = backend;
		keyPrefix = "";
		listener = null;

		if (options != null) {
			if (options.keyPrefix != null) keyPrefix = options.keyPrefix;
			if (options.listenToGlobalEvents != null && options.listenToGlobalEvents) {
				listener = event -> if (event.storageArea == backend) emit(event.key, event.oldValue, event.newValue, event.url);
				Browser.window.addEventListener("storage", listener);
			}
		}
	}

	/** Gets the keys of this storage. **/
	function get_keys() return [for (index in 0...backend.length) backend.key(index)];

	/** Gets the number of entries in this storage. **/
	function get_length() return backend.length;

	/** Removes all entries from this storage. **/
	public function clear() {
		backend.clear();
		emit(null);
	}

	/** Cancels the subscription to the storage events. **/
	public function destroy()
		if (listener != null) Browser.window.removeEventListener("storage", listener);

	/** Gets a value indicating whether this storage contains the specified `key`. **/
	public function exists(key: String) return backend.getItem(buildKey(key)) != null;

	/**
		Gets the value associated to the specified `key`.
		Returns the given `defaultValue` if the item does not exist.
	**/
	public function get(key: String, ?defaultValue: String) {
		final value = backend.getItem(buildKey(key));
		return value != null ? value : defaultValue;
	}

	/**
		Gets the deserialized value associated to the specified `key`.
		Returns the given `defaultValue` if the item does not exist.
	**/
	public function getObject(key: String, ?defaultValue: Any): Dynamic
		return try {
			final value = backend.getItem(buildKey(key));
			value != null ? Json.parse(value) : defaultValue;
		} catch (e) defaultValue;

	/** Returns a new iterator that allows iterating the entries of this storage. **/
	public function keyValueIterator(): KeyValueIterator<String, String>
		return new WebStorageIterator(backend);

	/**
		Looks up the value of the specified `key`, or add a new value if it isn't there.

		Returns the value associated to `key`, if there is one.
		Otherwise calls `ifAbsent` to get a new value, associates `key` to that value, and then returns the new value.
	**/
	public function putIfAbsent(key: String, ifAbsent: () -> String): String {
		if (!exists(key)) set(key, ifAbsent());
		return get(key);
	}

	/**
		Looks up the value of the specified `key`, or add a new value if it isn't there.

		Returns the deserialized value associated to `key`, if there is one.
		Otherwise calls `ifAbsent` to get a new value, serializes and associates `key` to that value, and then returns the new value.
	**/
	public function putObjectIfAbsent(key: String, ifAbsent: () -> Any): Dynamic {
		if (!exists(key)) setObject(key, ifAbsent());
		return getObject(key);
	}

	/**
		Removes the value associated to the specified `key`.
		Returns the value associated with the `key` before it was removed.
	**/
	public function remove(key: String) {
		final oldValue = get(key);
		backend.removeItem(buildKey(key));
		emit(buildKey(key), oldValue);
		return oldValue;
	}

	/** Associates a given `value` to the specified `key`. **/
	public function set(key: String, value: String) {
		final oldValue = get(key);
		backend.setItem(buildKey(key), value);
		emit(buildKey(key), oldValue, value);
		return this;
	}

	/** Serializes and associates a given `value` to the specified `key`. **/
	public function setObject(key: String, value: Any) return set(key, Json.stringify(value));

	/** Converts the specified storage to a JSON representation. **/
	#if tink_json
	public static function toJson(storage: WebStorage) {
		final map: DynamicAccess<String> = {};
		for (key => value in storage) map[key] = value;
		return map;
	}
	#end

	/** Builds a normalized cache key from the given `key`. **/
	inline function buildKey(key: String) return '$keyPrefix$key';

	/** Emits a new storage event. **/
	function emit(key: Null<String>, ?oldValue: String, ?newValue: String, ?url: String)
		dispatchEvent(new StorageEvent("change", {
			key: key,
			newValue: newValue,
			oldValue: oldValue,
			storageArea: backend,
			url: url != null ? url : Browser.location.href
		}));
}

/** Permits iteration over elements of a `WebStorage` instance. **/
private class WebStorageIterator {

	/** The current index. **/
	var index = 0;

	/** The instance to iterate. **/
	final storage: Storage;

	/** Creates a new storage iterator. **/
	public function new(storage: Storage) this.storage = storage;

	/** Returns a value indicating whether the iteration is complete. **/
	public function hasNext() return index < storage.length;

	/** Returns the current item of the iterator and advances to the next one. **/
	public function next(): {key: String, value: String} {
		final key = storage.key(index++);
		return {key: key, value: storage.getItem(key)};
	}
}

/** Defines the options of a `WebStorage` instance. **/
typedef WebStorageOptions = {

	/** A string prefixed to every key so that it is unique globally in the whole storage. **/
	var ?keyPrefix: String;

	/** Value indicating whether to listen to the global storage events. **/
	var ?listenToGlobalEvents: Bool;
}
