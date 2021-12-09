package webstorage;

import js.Browser.window;

/** Provides access to the session storage. **/
#if tink_json
@:jsonStringify(storage -> [for (key => value in storage) key => value])
#end
final class SessionStorage extends Storage {

	/** Creates a new session storage service. **/
	public function new(?options: Storage.StorageOptions)
		super(window.sessionStorage, options);
}
