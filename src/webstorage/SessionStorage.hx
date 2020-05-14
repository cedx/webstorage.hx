package webstorage;

import js.Browser;

/** Provides access to the session storage. **/
@:expose class SessionStorage extends WebStorage {
  
  /** Creates a new session storage service. **/
  public function new(?options: StorageOptions)
    super(Browser.window.sessionStorage, options);
}
