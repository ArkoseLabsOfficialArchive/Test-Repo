package godot;

enum abstract MouseFilter(Int) from Int to Int {
    var Stop = 0;
    var Pass = 1;
    var Ignore = 2;
}