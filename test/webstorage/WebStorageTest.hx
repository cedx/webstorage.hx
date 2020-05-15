package webstorage;

import js.Browser;
import js.html.Storage;
import utest.Assert;

/** Tests the features of the `WebStorage` class. **/
class WebStorageTest {

  /** The native session storage. **/
  private var sessionStorage: Storage;

  /** Creates a new test suite. **/
  public function new()
    sessionStorage = Browser.window.sessionStorage;

  /** Runs the tests. **/
  public function run(): Void {
    Mocha.beforeEach(() -> sessionStorage.clear());
    Mocha.describe('.keys', testKeys);
    Mocha.describe('.length', testLength);
    Mocha.describe('.addEventListener("change")', testAddEventListener);
    Mocha.describe('.clear()', testLength);
    Mocha.describe('.get()', testGet);
    Mocha.describe('.getObject()', testGetObject);
    Mocha.describe('.has()', testHas);
    Mocha.describe('.keyValueIterator()', testKeyValueIterator);
    Mocha.describe('.putIfAbsent()', testPutIfAbsent);
    Mocha.describe('.putObjectIfAbsent()', testPutObjectIfAbsent);
    Mocha.describe('.remove()', testRemove);
    Mocha.describe('.set()', testSet);
    Mocha.describe('.setObject()', testSetObject);
    Mocha.describe('.toJSON()', testToJSON);
  }

  /** Tests the `keys` property. **/
  function testKeys(): Void {
    Mocha.it('should return an empty array for an empty storage', () -> {
      Assert.equals(0, new SessionStorage().keys);
    });

    Mocha.it('should return the list of keys for a non-empty storage', () -> {
      sessionStorage.setItem('foo', 'bar');
      sessionStorage.setItem('bar', 'baz');
  
      final keys = new SessionStorage().keys;
      Assert.equals(2, keys.length);
      Assert.equals('foo', keys[0]);
      Assert.equals('bar', keys[1]);
    });
  }

  /** Tests the `length` property. **/
  function testLength(): Void {
    Mocha.it('should return zero for an empty storage', () -> {
      Assert.equals(0, new SessionStorage().length);
    });

    Mocha.it('should return the number of entries for a non-empty storage', () -> {
      sessionStorage.setItem('foo', 'bar');
      sessionStorage.setItem('bar', 'baz');
      Assert.equals(2, new SessionStorage().length);
    });
  }

  /** Tests the `addEventListener("change")` method. **/
  function testAddEventListener(): Void {
    Mocha.it('should trigger an event when a value is added', done -> {
      final listener = event -> {
        Assert.equals('foo', event.key);
        Assert.isNull(event.oldValue);
        Assert.equals('bar', event.newValue);
        done();
      };

      final service = new SessionStorage();
      service.addEventListener('change', listener);
      service.set('foo', 'bar');
      service.removeEventListener('change', listener);
    });

    Mocha.it('should trigger an event when a value is updated', done -> {
      sessionStorage.setItem('foo', 'bar');

      final listener = event -> {
        Assert.equals('foo', event.key);
        Assert.equals('bar', event.oldValue);
        Assert.equals('baz', event.newValue);
        done();
      };

      final service = new SessionStorage();
      service.addEventListener('change', listener);
      service.set('foo', 'baz');
      service.removeEventListener('change', listener);
    });

    Mocha.it('should trigger an event when a value is removed', done -> {
      sessionStorage.setItem('foo', 'bar');

      final listener = event -> {
        Assert.equals('foo', event.key);
        Assert.equals('bar', event.oldValue);
        Assert.isNull(event.newValue);
        done();
      };

      final service = new SessionStorage();
      service.addEventListener('change', listener);
      service.remove('foo');
      service.removeEventListener('change', listener);
    });

    Mocha.it('should trigger an event when the storage is cleared', done -> {
      sessionStorage.setItem('foo', 'bar');
      sessionStorage.setItem('bar', 'baz');

      final listener = event -> {
        Assert.isNull(event.key);
        Assert.isNull(event.oldValue);
        Assert.isNull(event.newValue);
        done();
      };

      final service = new SessionStorage();
      service.addEventListener('change', listener);
      service.clear();
      service.removeEventListener('change', listener);
    });
  }

  /** Tests the `clear()` method. **/
  function testClear(): Void {
    Mocha.it('should remove all storage entries', () -> {
      sessionStorage.setItem('foo', 'bar');
      sessionStorage.setItem('bar', 'baz');

      final service = new SessionStorage();
      Assert.equals(2, service.length);
      service.clear();
      Assert.equals(0, service.length);
    });
  }

  /** Tests the `get()` method. **/
  function testGet(): Void {
    Mocha.it('should properly get the storage entries', () -> {
      final service = new SessionStorage();
      Assert.isNull(service.get('foo'));

      sessionStorage.setItem('foo', 'bar');
      Assert.equals('bar', service.get('foo'));

      sessionStorage.setItem('foo', '123');
      Assert.equals('123', service.get('foo'));
    });

    Mocha.it('should return the given default value if the key is not found', () -> {
      Assert.equals('123', new SessionStorage().get('bar', '123'));
    });
  }

  /** Tests the `getObject()` method. **/
  function testGetObject(): Void {
    Mocha.it('should properly get the deserialized storage entries', () -> {
      final service = new SessionStorage();
      Assert.isNull(service.getObject('foo'));

      sessionStorage.setItem('foo', '123');
      Assert.equals(123, service.getObject('foo'));

      sessionStorage.setItem('foo', '"bar"');
      Assert.equals('bar', service.getObject('foo'));

      sessionStorage.setItem('foo', '{"key": "value"}');
      Assert.same({key: 'value'}, service.getObject('foo'));
    });

    Mocha.it('should return the default value if the value can\'t be deserialized', () -> {
      sessionStorage.setItem('foo', 'bar');
      Assert.equals('defaultValue', new SessionStorage().getObject('foo', 'defaultValue'));
    });
  }

  /** Tests the `has()` method. **/
  function testHas(): Void {
    Mocha.it('should return `false` if the specified key is not contained', () -> {
      Assert.isFalse(new SessionStorage().has('foo'));
    });

    Mocha.it('should return `true` if the specified key is contained', () -> {
      final service = new SessionStorage();
      sessionStorage.setItem('foo', 'bar');
      Assert.isTrue(service.has('foo'));
      Assert.isFalse(service.has('bar'));
    });
  }

  /** Tests the `keyValueIterator()` method. **/
  function testKeyValueIterator(): Void {
    Mocha.it('should end iteration immediately if storage is empty', () -> {
      final iterator = new SessionStorage().keyValueIterator();
      Assert.isFalse(iterator.hasNext());
    });

    Mocha.it('should iterate over the values if storage is not empty', () -> {
      sessionStorage.setItem('foo', 'bar');
      sessionStorage.setItem('bar', 'baz');

      final iterator = new SessionStorage().keyValueIterator();
      Assert.isTrue(iterator.hasNext());
      Assert.same({key: 'foo', value: 'bar'}, iterator.next());
      Assert.isTrue(iterator.hasNext());
      Assert.same({key: 'bar', value: 'baz'}, iterator.next());
      Assert.isFalse(iterator.hasNext());
    });
  }

  /** Tests the `putIfAbsent()` method. **/
  function testPutIfAbsent(): Void {
    Mocha.it('should add a new entry if it does not exist', () -> {
      final service = new SessionStorage();
      Assert.isNull(sessionStorage.getItem('foo'));
      Assert.equals('bar', service.putIfAbsent('foo', () -> 'bar'));
      Assert.equals('bar', sessionStorage.getItem('foo'));
    });

    Mocha.it('should not add a new entry if it already exists', () -> {
      final service = new SessionStorage();
      sessionStorage.setItem('foo', 'bar');
      Assert.equals('bar', service.putIfAbsent('foo', () -> 'qux'));
      Assert.equals('bar', sessionStorage.getItem('foo'));
    });
  }

  /** Tests the `putObjectIfAbsent()` method. **/
  function testPutObjectIfAbsent(): Void {
    Mocha.it('should add a new entry if it does not exist', () -> {
      final service = new SessionStorage();
      Assert.isNull(sessionStorage.getItem('foo'));
      Assert.equals(123, service.putObjectIfAbsent('foo', () -> 123));
      Assert.equals('123', sessionStorage.getItem('foo'));
    });

    Mocha.it('should not add a new entry if it already exists', () -> {
      final service = new SessionStorage();
      sessionStorage.setItem('foo', '123');
      Assert.equals(123, service.putObjectIfAbsent('foo', () -> 456));
      Assert.equals('123', sessionStorage.getItem('foo'));
    });
  }

  /** Tests the `remove()` method. **/
  function testRemove(): Void {
    Mocha.it('should properly remove the storage entries', () -> {
      final service = new SessionStorage();
      sessionStorage.setItem('foo', 'bar');
      sessionStorage.setItem('bar', 'baz');
      Assert.equals('bar', sessionStorage.getItem('foo'));

      service.remove('foo');
      Assert.isNull(sessionStorage.getItem('foo'));
      Assert.equals('baz', sessionStorage.getItem('bar'));

      service.remove('bar');
      Assert.isNull(sessionStorage.getItem('bar'));
    });
  }

  /** Tests the `set()` method. **/
  function testSet(): Void {
    Mocha.it('should properly set the storage entries', () -> {
      final service = new SessionStorage();
      Assert.isNull(sessionStorage.getItem('foo'));
      service.set('foo', 'bar');
      Assert.equals('bar', sessionStorage.getItem('foo'));
      service.set('foo', '123');
      Assert.equals('123', sessionStorage.getItem('foo'));
    });
  }

  /** Tests the `setObject()` method. **/
  function testSetObject(): Void {
    Mocha.it('should properly serialize and set the storage entries', () -> {
      final service = new SessionStorage();
      Assert.isNull(sessionStorage.getItem('foo'));
      service.setObject('foo', 123);
      Assert.equals('123', sessionStorage.getItem('foo'));
      service.setObject('foo', 'bar');
      Assert.equals('"bar"', sessionStorage.getItem('foo'));
      service.setObject('foo', {key: 'value'});
      Assert.equals('{"key":"value"}', sessionStorage.getItem('foo'));
    });
  }

  /** Tests the `toJSON()` method. **/
  function testToJSON(): Void {
    Mocha.it('should return an empty map for an empty storage', () -> {
      Assert.same({}, new SessionStorage().toJSON());
    });

    Mocha.it('should return a non-empty map for a non-empty storage', () -> {
      final service = new SessionStorage();
      service.set('foo', 'bar').set('baz', 'qux');
      Assert.same({baz: 'qux', foo: 'bar'}, service.toJSON());
    });
  }
}
