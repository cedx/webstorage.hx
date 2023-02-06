import webstorage.Storage;

/** Iterates over the key/value pairs of the local storage. **/
function main() {
	// Loop over all entries of the local storage.
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

	// Loop over entries of the session storage that use the same key prefix.
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
