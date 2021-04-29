package webstorage;

import js.Browser.window;

/** Provides access to the local storage. **/
class LocalStorage extends WebStorage {

	/** Creates a new local storage service. **/
	public function new(?options: WebStorage.WebStorageOptions)
		super(window.localStorage, options);
}
