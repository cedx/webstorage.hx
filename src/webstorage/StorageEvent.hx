package webstorage;

/** An event triggered when the storage has been changed. **/
final class StorageEvent {

	/** The changed key. **/
	public final key: Option<String>;

	/** The new value. **/
	public final newValue: Option<String>;

	/** The original value. **/
	public final oldValue: Option<String>;

	/** Creates a new storage event. **/
	public function new(key: Option<String>, oldValue: Option<String> = None, newValue: Option<String> = None) {
		this.key = key;
		this.newValue = newValue;
		this.oldValue = oldValue;
	}
}
