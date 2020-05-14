import haxe.ds.List;
import utest.Assert;
import webstorage.*;

/** Runs the test suites. **/
class TestAll {

  /** Application entry point. **/
  public static function main(): Void {
    Assert.results = new List();
    Mocha.describe('WebStorage', new WebStorageTest().run);
  }
}
