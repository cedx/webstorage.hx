package webstorage;

import js.Browser.window;

/** Provides access to the local storage. **/
#if tink_json
@:jsonStringify(storage -> [for (key => value in storage) key => value])
#end
final class LocalStorage extends Storage {

	/** Creates a new local storage service. **/
	public function new(?options: Storage.StorageOptions)
		super(window.localStorage, options);
}
