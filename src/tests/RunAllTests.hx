package tests;

class RunAllTests {
    public static function main():Void {
        Vector2Tests.run();
        Rect2Tests.run();
        Transform2DTests.run();
        NodePathTests.run();
        TscnParserTests.run();
        TestRunner.summary();
    }
}