package webstorage;

import haxe.Json;
import js.Browser.window;
import js.html.Storage as DomStorage;
import js.html.StorageEvent as DomStorageEvent;
using Lambda;
using StringTools;

/** Provides access to the [Web Storage](https://developer.mozilla.org/docs/Web/API/Web_Storage_API). **/
@:jsonStringify(storage -> [for (key => value in storage) key => value])
class Storage {

	/** The keys of this storage. **/
	public var keys(get, never): Array<String>;
		function get_keys() {
			final keys = [for (index in 0...backend.length) backend.key(index)];
			return keyPrefix.length == 0 ? keys : [for (key in keys) if (key.startsWith(keyPrefix)) key.substr(keyPrefix.length)];
		}

	/** The number of entries in this storage. **/
	public var length(get, never): Int;
		function get_length() return keyPrefix.length == 0 ? backend.length : keys.length;

	/** The stream of storage events. **/
	public final onChange: Signal<StorageEvent>;

	/** The underlying data store. **/
	final backend: DomStorage;

	/** A string prefixed to every key so that it is unique globally in the whole storage. **/
	final keyPrefix: String;

	/** The controller of storage events. **/
	final onChangeTrigger: SignalTrigger<StorageEvent> = Signal.trigger();

	/** Creates a new storage service. **/
	function new(backend: DomStorage, ?options: StorageOptions) {
		var onChange = onChangeTrigger.asSignal();
		if (options?.listenToGlobalEvents ?? false) onChange = onChange.join(Signal
			.ofClassical(window.addEventListener.bind("storage"), window.removeEventListener.bind("storage"))
			.filter((event: DomStorageEvent) -> event.storageArea == backend && (event.key == null || event.key.startsWith(keyPrefix)))
			.map(event -> new StorageEvent(
				event.key == null ? None : Some(event.key.substr(keyPrefix.length)),
				event.oldValue == null ? None : Some(event.oldValue),
				event.newValue == null ? None : Some(event.newValue)
			)));

		this.backend = backend;
		this.onChange = onChange;
		keyPrefix = options?.keyPrefix ?? "";
	}

	/** Creates a new local storage service. **/
	public static inline function local(?options: StorageOptions): Storage
		return new Storage(window.localStorage, options);

	/** Creates a new session storage service. **/
	public static inline function session(?options: StorageOptions): Storage
		return new Storage(window.sessionStorage, options);

	/** Removes all entries from this storage. **/
	public function clear(): Void
		if (keyPrefix.length > 0) keys.iter(remove);
		else { backend.clear(); onChangeTrigger.trigger(new StorageEvent(None)); }

	/** Gets a value indicating whether this storage contains the specified `key`. **/
	public function exists(key: String): Bool
		return get(key) != None;

	/** Gets the value associated with the specified `key`. Returns `None` if the `key` does not exist. **/
	public function get(key: String): Option<String> {
		final value = backend.getItem(buildKey(key));
		return value == null ? None : Some(value);
	}

	/**
		Gets the deserialized value associated with the specified `key`.
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
		Removes the value associated with the specified `key`.
		Returns the value associated with the `key` before it was removed.
	**/
	public function remove(key: String): Option<String> {
		final oldValue = get(key);
		backend.removeItem(buildKey(key));
		onChangeTrigger.trigger(new StorageEvent(Some(key), oldValue));
		return oldValue;
	}

	/** Associates a given `value` with the specified `key`. **/
	public function set(key: String, value: String): Outcome<Noise, Error>
		return Error.catchExceptions(() -> {
			final oldValue = get(key);
			backend.setItem(buildKey(key), value);
			onChangeTrigger.trigger(new StorageEvent(Some(key), oldValue, Some(value)));
			Noise;
		}, exception -> Error.withData(InsufficientStorage, "The storage is full.", exception));

	/** Serializes and associates a given `value` with the specified `key`. **/
	public function setObject<T>(key: String, value: T): Outcome<Noise, Error>
		return switch Error.catchExceptions(() -> Json.stringify(value)) {
			case Failure(_): Failure(new Error(UnprocessableEntity, "Unable to encode the specified value in JSON."));
			case Success(json): set(key, json);
		}

	/** Builds a normalized storage key from the given `key`. **/
	function buildKey(key: String): String
		return '$keyPrefix$key';
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
		this.storage = storage;
		keys = storage.keys;
	}

	/** Returns a value indicating whether the iteration is complete. **/
	public function hasNext(): Bool
		return index < keys.length;

	/** Returns the current item of the iterator and advances to the next one. **/
	public function next(): {key: String, value: String} {
		final key = keys[index++];
		return {key: key, value: storage.get(key).sure()};
	}
}

/** Defines the options of a `Storage` instance. **/
typedef StorageOptions = {

	/** A string prefixed to every key so that it is unique globally in the whole storage. **/
	var ?keyPrefix: String;

	/** Value indicating whether to listen to the global storage events. **/
	var ?listenToGlobalEvents: Bool;
}
