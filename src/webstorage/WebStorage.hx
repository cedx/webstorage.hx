package webstorage;

import haxe.DynamicAccess;
import js.Browser;
import js.html.Storage;
import js.html.StorageEvent;

#if tink_json
import tink.Json;
#else
import haxe.Json;
#end

/** Provides access to the [Web Storage](https://developer.mozilla.org/en-US/docs/Web/API/Storage). **/
class WebStorage {

	/** A string prefixed to every key so that it is unique globally in the whole storage. **/
	public var keyPrefix = "";

	/** The keys of this storage. **/
	public var keys(get, never): Array<String>;

	/** The number of entries in this storage. **/
	public var length(get, never): Int;

	/** The underlying data store. **/
	final backend: Storage;

	/** The function that listens for storage events. **/
	final listener: Null<StorageEvent -> Void> = null;

	/** Creates a new storage service. **/
	function new(backend: Storage, ?options: WebStorageOptions) {
		this.backend = backend;
		if (options != null) {
			if (options.keyPrefix != null) keyPrefix = options.keyPrefix;
			if (options.listenToGlobalEvents != null && options.listenToGlobalEvents) {
				// TODO listener = event -> if (event.storageArea == backend) emit(event.key, event.oldValue, event.newValue, event.url);
				Browser.window.addEventListener("storage", listener);
			}
		}
	}

	/** Gets the keys of this storage. **/
	function get_keys() return [for (index in 0...backend.length) backend.key(index)];

	/** Gets the number of entries in this storage. **/
	inline function get_length() return backend.length;

	/** Removes all entries from this storage. **/
	public function clear() {
		backend.clear();
		// TODO emit(null);
	}

	/** Cancels the subscription to the storage events. **/
	public function destroy()
		if (listener != null) Browser.window.removeEventListener("storage", listener);

	/** Gets a value indicating whether this storage contains the specified `key`. **/
	public inline function exists(key: String) return backend.getItem(buildKey(key)) != null;

	/**
		Gets the deserialized value associated to the specified `key`.
		Returns the given `defaultValue` if the item does not exist.
	**/
	public function get<T>(key: String, ?defaultValue: T)
		return try {
			final value = backend.getItem(buildKey(key));
			value != null ? (Json.parse(value): T) : defaultValue;
		} catch (e) defaultValue;

	/**
		Gets the value associated to the specified `key`.
		Returns the given `defaultValue` if the item does not exist.
	**/
	public function getString(key: String, ?defaultValue: String) {
		final value = backend.getItem(buildKey(key));
		return value != null ? value : defaultValue;
	}

	/** Returns a new iterator that allows iterating the entries of this storage. **/
	public inline function keyValueIterator(): KeyValueIterator<String, String>
		return new WebStorageIterator(backend);

	/**
		Looks up the value of the specified `key`, or add a new value if it isn't there.

		Returns the deserialized value associated to `key`, if there is one.
		Otherwise calls `ifAbsent` to get a new value, serializes and associates `key` to that value, and then returns the new value.
	**/
	public function putIfAbsent<T>(key: String, ifAbsent: () -> T): T {
		if (!exists(key)) set(key, ifAbsent());
		return get(key);
	}

	/**
		Looks up the value of the specified `key`, or add a new value if it isn't there.

		Returns the value associated to `key`, if there is one.
		Otherwise calls `ifAbsent` to get a new value, associates `key` to that value, and then returns the new value.
	**/
	public function putStringIfAbsent(key: String, ifAbsent: () -> String): String {
		if (!exists(key)) setString(key, ifAbsent());
		return getString(key);
	}

	/**
		Removes the value associated to the specified `key`.
		Returns the value associated with the `key` before it was removed.
	**/
	public function remove(key: String) {
		final oldValue = getString(key);
		backend.removeItem(buildKey(key));
		// TODO emit(buildKey(key), oldValue);
		return oldValue;
	}

	/** Serializes and associates a given `value` to the specified `key`. **/
	public inline function set<T>(key: String, value: T) return setString(key, Json.stringify(value));

	/** Associates a given `value` to the specified `key`. **/
	public function setString(key: String, value: String) {
		final oldValue = getString(key);
		backend.setItem(buildKey(key), value);
		// TODO emit(buildKey(key), oldValue, value);
		return this;
	}

	/** Converts the specified storage to a JSON representation. **/
	public function toJSON() {
		final map: DynamicAccess<String> = {};
		for (key => value in this) map[key] = value;
		return map;
	}

	/** Builds a normalized cache key from the given `key`. **/
	inline function buildKey(key: String) return '$keyPrefix$key';

	/** Emits a new storage event. **/
	/* TODO
	function emit(key: Null<String>, ?oldValue: String, ?newValue: String, ?url: String)
		dispatchEvent(new StorageEvent("change", {
			key: key,
			newValue: newValue,
			oldValue: oldValue,
			storageArea: backend,
			url: url != null ? url : Browser.location.href
		})); */
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
	public inline function hasNext() return index < storage.length;

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
