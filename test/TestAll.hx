import haxe.ds.List;
import js.mocha.Mocha;
import utest.Assert;
import webstorage.*;

/** Runs the test suite. **/
class TestAll {

	/** The test cases. **/
	static final tests = [
		"WebStorage" => new WebStorageTest().run
	];

	/** Application entry point. **/
	static function main() {
		Assert.results = new List();
		for (description => callback in tests) Mocha.describe(description, callback);
	}
}
