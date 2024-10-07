import js.Syntax;
import tink.testrunner.Reporter.AnsiFormatter;
import tink.testrunner.Reporter.BasicReporter;
import tink.testrunner.Runner;
import tink.unit.TestBatch;

/** Runs the test suite. **/
function main() {
	ANSI.stripIfUnavailable = false;
	Runner
		.run(TestBatch.make([new webstorage.StorageTest()]), new BasicReporter(new AnsiFormatter()))
		.handle(outcome -> Syntax.code("exit({0})", outcome.summary().failures.length));
}
