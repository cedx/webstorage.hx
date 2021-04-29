package webstorage;

import js.Browser.window;

/** Provides access to the session storage. **/
class SessionStorage extends WebStorage {

	/** Creates a new session storage service. **/
	public function new(?options: WebStorage.WebStorageOptions)
		super(window.sessionStorage, options);
}
