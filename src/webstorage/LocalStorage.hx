package webstorage;

import js.Browser;

/** Provides access to the local storage. **/
@:expose class LocalStorage extends WebStorage {
  
  /** Creates a new local storage service. **/
  public function new(?options: StorageOptions)
    super(Browser.window.localStorage, options);
}
