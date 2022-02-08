package webstorage;

import haxe.Json;
import haxe.ds.Option;
import js.Browser;
import js.html.Storage as WebStorage;
import js.html.StorageEvent;
using Lambda;
using StringTools;
using tink.CoreApi;

/** Provides access to the [Web Storage](https://developer.mozilla.org/en-US/docs/Web/API/Web_Storage_API). **/
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

	/** The controller of storage events. **/
	final onChangeTrigger: SignalTrigger<StorageEvent> = Signal.trigger();

	/** Creates a new storage service. **/
	function new(backend: WebStorage, ?options: StorageOptions) {
		var onChange = onChangeTrigger.asSignal();
		if (options != null) {
			if (options.listenToGlobalEvents) onChange = onChange.join(Signal.ofClassical(
				Browser.window.addEventListener.bind("storage"),
				Browser.window.removeEventListener.bind("storage")
			).filter(event -> (event: StorageEvent).storageArea == backend));

			if (options.keyPrefix != null) {
				keyPrefix = options.keyPrefix;
				onChange = onChange.filter(event -> event.key.startsWith(keyPrefix));
			}
		}

		this.backend = backend;
		this.onChange = onChange;
	}

	/** Creates a new local storage service. **/
	public static inline function local(?options: StorageOptions)
		return new LocalStorage(options);

	/** Creates a new session storage service. **/
	public static inline function session(?options: StorageOptions)
		return new SessionStorage(options);

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
		else { backend.clear(); trigger(null); }

	/** Gets a value indicating whether this storage contains the specified `key`. **/
	public inline function exists(key: String)
		return backend.getItem(buildKey(key)) != null;

	/**
		Gets the value associated to the specified `key`.
		Returns `None` if the `key` does not exist.
	**/
	public function get(key: String): Option<String> {
		final value = backend.getItem(buildKey(key));
		return value == null ? None : Some(value);
	}

	/**
		Gets the deserialized value associated to the specified `key`.
		Returns `None` if the `key` does not exist or its value cannot be deserialized.
	**/
	public function getObject<T>(key: String): Option<T> {
		final value = backend.getItem(buildKey(key));
		return value == null ? None : switch Error.catchExceptions(() -> Json.parse(value)) {
			case Failure(_): None;
			case Success(json): Some(json);
		}
	}

	/** Returns a new iterator that allows iterating the entries of this storage. **/
	public inline function keyValueIterator(): KeyValueIterator<String, String>
		return new StorageIterator(this);

	/**
		Looks up the value of the specified `key`, or add a new value if it isn't there.

		Returns the value associated to `key`, if there is one.
		Otherwise calls `ifAbsent` to get a new value, associates `key` to that value, and then returns the new value.
	**/
	public function putIfAbsent(key: String, ifAbsent: () -> String): Outcome<String, Error>
		return switch exists(key) ? Success(Noise) : set(key, ifAbsent()) {
			case Failure(error): Failure(error);
			case Success(_): get(key).toOutcome();
		}

	/**
		Looks up the value of the specified `key`, or add a new value if it isn't there.

		Returns the deserialized value associated to `key`, if there is one.
		Otherwise calls `ifAbsent` to get a new value, serializes it and associates `key` to that value, and then returns the new value.
	**/
	public function putObjectIfAbsent<T>(key: String, ifAbsent: () -> T): Outcome<T, Error>
		return switch exists(key) ? Success(Noise) : setObject(key, ifAbsent()) {
			case Failure(error): Failure(error);
			case Success(_): getObject(key).toOutcome();
		}

	/**
		Removes the value associated to the specified `key`.
		Returns the value associated with the `key` before it was removed.
	**/
	public function remove(key: String): Option<String> {
		final normalizedKey = buildKey(key);
		final oldValue = get(key);
		backend.removeItem(normalizedKey);
		trigger(normalizedKey, oldValue.orNull());
		return oldValue;
	}

	/** Associates a given `value` to the specified `key`. **/
	public function set(key: String, value: String): Outcome<Noise, Error>
		return Error.catchExceptions(() -> {
			final normalizedKey = buildKey(key);
			final oldValue = get(key);
			backend.setItem(normalizedKey, value);
			trigger(normalizedKey, oldValue.orNull(), value);
			Noise;
		}, exception -> Error.withData(InsufficientStorage, "The storage is full.", exception));

	/** Serializes and associates a given `value` to the specified `key`. **/
	public inline function setObject<T>(key: String, value: T): Outcome<Noise, Error>
		return switch Error.catchExceptions(() -> Json.stringify(value)) {
			case Failure(_): Failure(new Error(UnprocessableEntity, "Unable to encode the specified value in JSON."));
			case Success(json): set(key, json);
		}

	#if !tink_json
	/** Converts this storage to a JSON representation. **/
	public function toJSON() return [for (key => value in this) [key, value]];
	#end

	/** Builds a normalized storage key from the given `key`. **/
	function buildKey(key: String) return '$keyPrefix$key';

	/** Triggers a new storage event. **/
	function trigger(key: Null<String>, ?oldValue: String, ?newValue: String) onChangeTrigger.trigger(new StorageEvent("storage", {
		key: key,
		newValue: newValue,
		oldValue: oldValue,
		storageArea: backend,
		url: Browser.location.href
	}));
}

/** Iterates over the items of a `Storage` instance. **/
private class StorageIterator {

	/** The current index. **/
	var index = 0;

	/** The storage keys. **/
	final keys: Array<String>;

	/** The storage to iterate. **/
	final storage: Storage;

	/** Creates a new storage iterator. **/
	public function new(storage: Storage) {
		keys = storage.keys;
		this.storage = storage;
	}

	/** Returns a value indicating whether the iteration is complete. **/
	public inline function hasNext() return index < keys.length;

	/** Returns the current item of the iterator and advances to the next one. **/
	public function next(): {key: String, value: String} {
		final key = keys[index++];
		return {key: key, value: storage.get(key).sure()};
	}
}

/** Defines the options of a `Storage` instance. **/
typedef StorageOptions = {

	/** A string prefixed to every key so that it is unique globally in the whole storage. **/
	?keyPrefix: String,

	/** Value indicating whether to listen to the global storage events. **/
	?listenToGlobalEvents: Bool
}
