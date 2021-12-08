package webstorage;

import js.Browser.window;

/** Provides access to the session storage. **/
final class SessionStorage extends Storage {

	/** Creates a new session storage service. **/
	public function new(?options: Storage.StorageOptions)
		super(window.sessionStorage, options);
}
