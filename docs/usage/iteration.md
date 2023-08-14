# Iteration
The [`Storage`](usage/api.md) class is iterable: it implements the [`KeyValueIterable<String, String>`](https://api.haxe.org/KeyValueIterable.html) protocol.
You can go through all key/value pairs contained using a `for` loop:

```haxe
import webstorage.Storage;

function main() {
  final localStorage = Storage.local();
  localStorage.set("foo", "bar");
  localStorage.set("bar", "baz");
  localStorage.set("baz", "qux");

  for (key => value in localStorage) {
    trace('$key => $value');
    // Round 1: "foo => bar"
    // Round 2: "bar => baz"
    // Round 3: "baz => qux"
  }
}
```

> The order of keys is user-agent defined, so you should not rely on it.

If you have configured the instance to use a [key prefix](usage/key_prefix.md), the iteration will only loop over the values that have that same key prefix:

```haxe
import webstorage.Storage;

function main() {
  final sessionStorage = Storage.session();
  sessionStorage.set("foo", "bar");
  sessionStorage.set("prefix:bar", "baz");

  final prefixedStorage = Storage.session({keyPrefix: "prefix:"});
  prefixedStorage.set("baz", "qux");

  for (key => value in prefixedStorage) {
    trace('$key => $value');
    // Round 1: "bar => baz"
    // Round 2: "baz => qux"
  }
}
```

> The prefix is stripped from the keys returned by the iteration.
