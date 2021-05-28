import js.Syntax;
import tink.testrunner.Reporter.AnsiFormatter;
import tink.testrunner.Reporter.BasicReporter;
import tink.testrunner.Runner;
import tink.unit.TestBatch;
import webstorage.*;

/** Runs the test suite. **/
function main() {
	ANSI.stripIfUnavailable = false;
	Runner
		.run(TestBatch.make([new WebStorageTest()]), new BasicReporter(new AnsiFormatter()))
		.handle(result -> Syntax.code("exit({0})", result.summary().failures.length));
}
