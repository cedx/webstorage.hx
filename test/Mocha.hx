import haxe.ds.Either;
import js.lib.Error;
import js.lib.Promise;

/** The Mocha test runner. **/
@:native('')
extern class Mocha {

  /** Method invoked before each test. **/
  public static function beforeEach(callback: Callback): Void;

  /** TODO **/
  public static function describe(description: String, callback: Callback): Void;

  /** TODO **/
  @:overload(function(specification: String, callback: AsyncCallback): Void {})
  @:overload(function(specification: String, callback: PromiseCallback): Void {})
  public static function it(specification: String, callback: Callback): Void;
}

/** TODO **/
typedef AsyncCallback = (Either<Void, Error> -> Void) -> Void;

/** TODO **/
typedef Callback = () -> Void;

/** Defines a function returning a `Promise`. **/
typedef PromiseCallback = () -> Promise<Any>;
