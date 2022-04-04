package webstorage;

import js.Browser.window;

/** Provides access to the local storage. **/
@:jsonStringify(storage -> [for (key => value in storage) key => value])
final class LocalStorage extends Storage {

	/** Creates a new local storage service. **/
	public function new(?options: Storage.StorageOptions)
		super(window.localStorage, options);
}
