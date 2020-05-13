package webstorage;

/** Represents the event parameter used for a change event. **/
class SimpleChange {

  /** The current value, or `null` if removed. **/
  public final currentValue: Null<String>;

  /** The previous value, or `null` if added. **/
  public final previousValue: Null<String>;

  /** Creates a new simple change. **/
  public function new(previousValue: Null<String>, currentValue: Null<String>) {
    this.currentValue = currentValue;
    this.previousValue = previousValue;
  }
}
