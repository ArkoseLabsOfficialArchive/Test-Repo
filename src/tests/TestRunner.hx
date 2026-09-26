package tests;

class TestRunner {
    static var failures:Int = 0;
    static var passed:Int = 0;

    public static function assert(condition:Bool, message:String):Void {
        if (condition) {
            trace("TEST PASSED: " + message);
            passed++;
        } else {
            failures++;
            trace("TEST FAILED: " + message);
        }
    }

    public static function summary():Void {
        trace("Passed: " + passed + ", Failed: " + failures);
    }
}