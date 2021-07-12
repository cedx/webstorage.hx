import js.Syntax;
import tink.testrunner.Runner;
import tink.unit.TestBatch;
import webstorage.*;

/** Runs the test suite. **/
function main() Runner
	.run(TestBatch.make([new WebStorageTest()]))
	.handle(result -> Syntax.code("exit({0})", result.summary().failures.length));
