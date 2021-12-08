import js.Syntax;
import tink.testrunner.Runner;
import tink.unit.TestBatch;

/** Runs the test suite. **/
function main() {
	final tests = TestBatch.make([new webstorage.StorageTest()]);
	Runner.run(tests).handle(result -> Syntax.code("exit({0})", result.summary().failures.length));
}
