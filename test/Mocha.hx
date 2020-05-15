import haxe.extern.EitherType;
import js.lib.Error;

/** The Mocha test runner. **/
@:native('')
@:require(js)
extern class Mocha {

  /** Method invoked once after the last test. **/
  @:overload(function(description: String, callback: Callback): Void {})
  public static function after(callback: Callback): Void;
  
  /** Method invoked after each test. **/
  @:overload(function(description: String, callback: Callback): Void {})
  public static function afterEach(callback: Callback): Void;

  /** Method invoked once before the first test. **/
  @:overload(function(description: String, callback: Callback): Void {})
  public static function before(callback: Callback): Void;
  
  /** Method invoked before each test. **/
  @:overload(function(description: String, callback: Callback): Void {})
  public static function beforeEach(callback: Callback): Void;

  /** Defines a test suite. **/
  public static function describe(description: String, callback: VoidCallback): Void;

  /** Defines an exclusive test suite. **/
  @:native('describe.only')
  public static function describeOnly(description: String, callback: VoidCallback): Void;

  /** Defines a skipped test suite. **/
  @:native('describe.skip')
  public static function describeSkip(description: String, callback: VoidCallback): Void;

  /** Defines a test case. **/
  @:overload(function(specification: String): Void {})
  public static function it(specification: String, callback: Callback): Void;

  /** Defines an exclusive test case. **/
  @:native('it.only')
  public static function itOnly(specification: String, callback: Callback): Void;

  /** Defines a skipped test case. **/
  @:native('it.skip')
  public static function itSkip(specification: String, callback: Callback): Void;
}

/** Callback function used for tests and hooks. **/
typedef Callback = EitherType<DoneCallback, VoidCallback>;

/** An error-first callback function. **/
typedef DoneCallback = EitherType<() -> Void, Error -> Void> -> Void;

/** A callback function. **/
typedef VoidCallback = () -> Void;
