package webstorage;

import haxe.DynamicAccess;
import js.Browser;
import js.html.Storage as WebStorage;
import js.html.StorageEvent;
import tink.core.Signal;

#if tink_json
import tink.Json;
#else
import haxe.Json;
#end

using Lambda;
using StringTools;

/** Provides access to the [Web Storage](https://developer.mozilla.org/en-US/docs/Web/API/Storage). **/
abstract class Storage {

	/** The keys of this storage. **/
	public var keys(get, never): Array<String>;

	/** A string prefixed to every key so that it is unique globally in the whole storage. **/
	public final keyPrefix = "";

	/** The number of entries in this storage. **/
	public var length(get, never): Int;

	/** The stream of storage events. **/
	public final onChange: Signal<StorageEvent>;

	/** The underlying data store. **/
	final backend: WebStorage;

	/** The handler of storage events. **/
	final onChangeTrigger: SignalTrigger<StorageEvent> = Signal.trigger();

	/** Creates a new storage service. **/
	function new(backend: WebStorage, ?options: StorageOptions) {
		var onChange = onChangeTrigger.asSignal();
		if (options != null) {
			if (options.listenToGlobalEvents) onChange = onChange.join(Signal.ofClassical(
				Browser.window.addEventListener.bind("storage"),
				Browser.window.removeEventListener.bind("storage")
			).filter((event: StorageEvent) -> event.storageArea == backend));

			if (options.keyPrefix != null) {
				keyPrefix = options.keyPrefix;
				onChange = onChange.filter(event -> event.key.startsWith(keyPrefix));
			}
		}

		this.backend = backend;
		this.onChange = onChange;
	}

	/** Creates a new local storage service. **/
	public inline static function local(?options: StorageOptions) return new LocalStorage(options);

	/** Creates a new session storage service. **/
	public inline static function session(?options: StorageOptions) return new SessionStorage(options);

	/** Gets the keys of this storage. **/
	function get_keys() {
		final keys = [for (index in 0...backend.length) backend.key(index)];
		return keyPrefix.length == 0 ? keys : [for (key in keys) if (key.startsWith(keyPrefix)) key.substring(keyPrefix.length)];
	}

	/** Gets the number of entries in this storage. **/
	function get_length() return keyPrefix.length == 0 ? backend.length : keys.length;

	/** Removes all entries from this storage. **/
	public function clear()
		if (keyPrefix.length > 0) keys.iter(remove);
		else {
			backend.clear();
			trigger(null);
		}

	/** Gets a value indicating whether this storage contains the specified `key`. **/
	public inline function exists(key: String) return backend.getItem(buildKey(key)) != null;

	/**
		Gets the deserialized value associated to the specified `key`.
		Returns the given `defaultValue` if the key does not exist or its value is invalid.
	**/
	public function get<T>(key: String, ?defaultValue: T) return try {
		final value = backend.getItem(buildKey(key));
		value != null ? (Json.parse(value): T) : defaultValue;
	} catch (e) defaultValue;

	/**
		Gets the value associated to the specified `key`.
		Returns the given `defaultValue` if the key does not exist.
	**/
	public function getString(key: String, ?defaultValue: String) {
		final value = backend.getItem(buildKey(key));
		return value != null ? value : defaultValue;
	}

	/** Returns a new iterator that allows iterating the entries of this storage. **/
	public inline function keyValueIterator(): KeyValueIterator<String, String>
		return new StorageIterator(backend, keyPrefix);

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
		trigger(buildKey(key), oldValue);
		return oldValue;
	}

	/** Serializes and associates a given `value` to the specified `key`. **/
	public inline function set<T>(key: String, value: T) return setString(key, Json.stringify(value));

	/** Associates a given `value` to the specified `key`. **/
	public function setString(key: String, value: String) {
		final oldValue = getString(key);
		backend.setItem(buildKey(key), value);
		trigger(buildKey(key), oldValue, value);
		return this;
	}

	/** Converts this storage to a JSON representation. **/
	#if !tink_json
	public function toJSON() {
		final map: DynamicAccess<String> = {};
		for (key => value in this) map[key] = value;
		return map;
	}
	#end

	/** Builds a normalized cache key from the given `key`. **/
	inline function buildKey(key: String) return '$keyPrefix$key';

	/** Triggers a new storage event. **/
	function trigger(key: Null<String>, ?oldValue: String, ?newValue: String, ?url: String) onChangeTrigger.trigger(new StorageEvent("storage", {
		key: key,
		newValue: newValue,
		oldValue: oldValue,
		storageArea: backend,
		url: url != null ? url : Browser.location.href
	}));
}

/** Permits iteration over elements of a `Storage` instance. **/
private class StorageIterator {

	/** The current index. **/
	var index = 0;

	/** The key prefix. **/
	final keyPrefix: String;

	/** The instance to iterate. **/
	final storage: WebStorage;

	/** Creates a new storage iterator. **/
	public function new(storage: WebStorage, keyPrefix: String) {
		this.keyPrefix = keyPrefix;
		this.storage = storage;
	}

	/** Returns a value indicating whether the iteration is complete. **/
	public inline function hasNext() return index < storage.length;

	/** Returns the current item of the iterator and advances to the next one. **/
	public function next(): {key: String, value: String} {
		final key = storage.key(index++);
		return {key: key, value: storage.getItem(key)};
	}
}

/** Defines the options of a `Storage` instance. **/
typedef StorageOptions = {

	/** A string prefixed to every key so that it is unique globally in the whole storage. **/
	var ?keyPrefix: String;

	/** Value indicating whether to listen to the global storage events. **/
	var ?listenToGlobalEvents: Bool;
}