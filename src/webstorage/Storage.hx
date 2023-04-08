package webstorage;

import haxe.Json;
import js.Browser.window;
import js.html.Storage as DomStorage;
import js.html.StorageEvent as DomStorageEvent;
using Lambda;
using StringTools;

/** Provides access to the [Web Storage](https://developer.mozilla.org/docs/Web/API/Web_Storage_API). **/
@:ignoreInstrument
@:jsonStringify(storage -> [for (key => value in storage) key => value])
class Storage {

	/** The keys of this storage. **/
	public var keys(get, never): Array<String>;
		function get_keys() {
			final keys = [for (index in 0...backend.length) backend.key(index)];
			return keyPrefix.length == 0 ? keys : [for (key in keys) if (key.startsWith(keyPrefix)) key.substring(keyPrefix.length)];
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
		if (options?.listenToGlobalEvents ?? false) {
			final signal = Signal
				.ofClassical(window.addEventListener.bind("storage"), window.removeEventListener.bind("storage"))
				.filter((event: DomStorageEvent) -> event.storageArea == backend && (event.key == null || event.key.startsWith(keyPrefix)))
				.map(event -> new StorageEvent(
					event.key == null ? None : Some(event.key.substring(keyPrefix.length)),
					event.oldValue == null ? None : Some(event.oldValue),
					event.newValue == null ? None : Some(event.newValue)
				));

			onChange = onChange.join(signal);
		}

		this.backend = backend;
		this.onChange = onChange;
		keyPrefix = options?.keyPrefix ?? "";
	}

	/** Creates a new local storage service. **/
	public static inline function local(?options: StorageOptions)
		return new Storage(window.localStorage, options);

	/** Creates a new session storage service. **/
	public static inline function session(?options: StorageOptions)
		return new Storage(window.sessionStorage, options);

	/** Removes all entries from this storage. **/
	public function clear()
		if (keyPrefix.length > 0) keys.iter(remove);
		else { backend.clear(); onChangeTrigger.trigger(new StorageEvent(None)); }

	/** Gets a value indicating whether this storage contains the specified `key`. **/
	public function exists(key: String) return get(key) != None;

	/** Gets the value associated with the specified `key`. Returns `None` if the `key` does not exist. **/
	public function get(key: String) {
		final value = backend.getItem(buildKey(key));
		return value == null ? None : Some(value);
	}

	/**
		Gets the deserialized value associated with the specified `key`.
		Returns `None` if the `key` does not exist or its value cannot be deserialized.
	**/
	public function getObject(key: String): Option<Dynamic> {
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
		Returns the value associated with `key`, if there is one.
		Otherwise calls `ifAbsent` to get a new value, associates `key` with that value, and then returns the new value.
	**/
	public function putIfAbsent(key: String, ifAbsent: () -> String) return switch get(key) {
		case Some(value): Success(value);
		case None: final value = ifAbsent(); set(key, value).map(_ -> value);
	}

	/**
		Looks up the value of the specified `key`, or add a new value if it isn't there.
		Returns the deserialized value associated with `key`, if there is one.
		Otherwise calls `ifAbsent` to get a new value, serializes it and associates `key` with that value, and then returns the new value.
	**/
	public function putObjectIfAbsent(key: String, ifAbsent: () -> Any): Outcome<Dynamic, Error>
		return switch getObject(key) {
			case Some(value): Success(value);
			case None: final value = ifAbsent(); setObject(key, value).map(_ -> value);
		}

	/**
		Removes the value associated with the specified `key`.
		Returns the value associated with the `key` before it was removed.
	**/
	public function remove(key: String) {
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
	public function setObject(key: String, value: Any): Outcome<Noise, Error>
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
	public function hasNext() return index < keys.length;

	/** Returns the current item of the iterator and advances to the next one. **/
	public function next() {
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
