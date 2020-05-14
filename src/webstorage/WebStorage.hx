package webstorage;

import haxe.DynamicAccess;
import haxe.Json;
import js.Browser;
import js.Syntax;
import js.html.EventTarget;
import js.html.Storage;
import js.html.StorageEvent;
import js.lib.Object;
import js.lib.Symbol;

/** Provides access to the [Web Storage](https://developer.mozilla.org/en-US/docs/Web/API/Storage). **/
@:yield
class WebStorage extends EventTarget {

  /** An event that is triggered when a storage value is changed (added, modified, or removed). **/
  public static final eventChange = 'changes';

  /** The keys of this storage. **/
  public var keys(get, never): Array<String>;

  /** The number of entries in this storage. **/
  public var length(get, never): Int;

  /** The underlying data store. **/
  private final backend: Storage;

  /** The function that listens for storage events. **/
  private final listener: Null<StorageEvent -> Void>;
  
  /** Creates a new storage service. **/
  private function new(backend: Storage, ?options: StorageOptions) {
    super();
    this.backend = backend;

    if (options == null || !options.listenToStorageEvents) listener = null;
    else {
      listener = event -> if (event.storageArea == backend) emit(event.key, event.oldValue, event.newValue, event.url);
      addEventListener('storage', listener);
    }
  }

  /** Gets the keys of this storage. **/
  function get_keys(): Array<String>
    return [for (index in 0...backend.length - 1) backend.key(index)];

  /** Gets the number of entries in this storage. **/
  function get_length(): Int
    return backend.length;

  /** Removes all entries from this storage. **/
  public function clear(): Void {
    backend.clear();
    emit(null, null, null);
  }

  /** Cancels the subscription to the storage events. **/
  public function destroy(): Void
    if (listener != null) removeEventListener('storage', listener);

  /**
    Gets the value associated to the specified `key`.
    Returns the `defaultValue` if the item does not exist.
  **/
  @:arrayAccess public function get(key: String, ?defaultValue: String): Null<String> {
    final value = backend.getItem(key);
    return value != null ? value : defaultValue;
  }

  /**
    Gets the deserialized value associated to the specified `key`.
    Returns the `defaultValue` if the item does not exist.
  **/
  public function getObject(key: String, ?defaultValue: Any): Null<Dynamic> {
    try {
      final value = backend.getItem(key);
      return value != null ? Json.parse(value) : defaultValue;
    }

    catch (e: Any) {
      return defaultValue;
    }
  }

  /** Gets a value indicating whether this storage contains the specified `key`. **/
  public function has(key: String): Bool
    return keys.indexOf(key) >= 0;

  /** Returns a new iterator that allows iterating the entries of this storage. **/
  public function keyValueIterator(): KeyValueIterator<String, String>
    for (key in keys) @yield return {key: key, value: get(key)}

  /**
    Looks up the value of the specified `key`, or add a new value if it isn't there.

    Returns the value associated to `key`, if there is one.
    Otherwise calls `ifAbsent` to get a new value, associates `key` to that value, and then returns the new value.
  **/
  public function putIfAbsent(key: String, ifAbsent: () -> String): String {
    if (!has(key)) set(key, ifAbsent());
    return get(key);
  }

  /**
    Looks up the value of the specified `key`, or add a new value if it isn't there.

    Returns the deserialized value associated to `key`, if there is one.
    Otherwise calls `ifAbsent` to get a new value, serializes and associates `key` to that value, and then returns the new value.
  **/
  public function putObjectIfAbsent(key: String, ifAbsent: () -> Any): Dynamic {
    if (!has(key)) setObject(key, ifAbsent());
    return getObject(key);
  }

  /**
    Removes the value associated to the specified `key`.
    Returns the value associated with the `key` before it was removed.
  **/
  public function remove(key: String): Null<String> {
    final oldValue = get(key);
    backend.removeItem(key);
    emit(key, oldValue, null);
    return oldValue;
  }

  /**
    Associates a given `value` to the specified `key`.
    Returns this instance.
  **/
  @:arrayAccess public function set(key: String, value: String): WebStorage {
    final oldValue = get(key);
    backend.setItem(key, value);
    emit(key, oldValue, value);
    return this;
  }

  /**
    Serializes and associates a given `value` to the specified `key`.
    Returns this instance.
  **/
  public function setObject(key: String, value: Any): WebStorage
    return set(key, Json.stringify(value));

  /** Converts this object to a map in JSON format. **/
  public function toJSON() {
    final map: DynamicAccess<String> = {};
    for (key => value in this) map[key] = value;
    return map;
  }

  /** Emits a new storage event. **/
  private function emit(key: Null<String>, oldValue: Null<String>, newValue: Null<String>, ?url: String): Void
    dispatchEvent(new StorageEvent(eventChange, {
      key: key,
      newValue: newValue,
      oldValue: oldValue,
      storageArea: backend,
      url: url != null ? url : Browser.location.href
    }));
  
  /** Initializes the class prototype. **/
  private static function __init__(): Void {
    var proto = Syntax.field(WebStorage, 'prototype');
    Object.defineProperty(proto, Syntax.field(Symbol, 'iterator'), {
      value: Syntax.code('function *() { for (const key of this.keys) yield [key, this.get(key)]; }')
    });

    Object.defineProperties(proto, {
      keys: {get: proto.get_keys},
      length: {get: proto.get_length}
    });
  }
}

/** Defines the options of a `WebStorage` instance. **/
typedef WebStorageOptions = {

  /** Value indicating whether to listen to the global storage events. **/
  var listenToStorageEvents: Bool;
}
