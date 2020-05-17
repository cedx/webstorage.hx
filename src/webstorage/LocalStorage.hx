package webstorage;

import js.Browser;

/** Provides access to the local storage. **/
@:expose
@:require(js)
class LocalStorage extends WebStorage {
	
	/** Creates a new local storage service. **/
	public function new(?options: WebStorage.WebStorageOptions)
		super(Browser.window.localStorage, options);
}
