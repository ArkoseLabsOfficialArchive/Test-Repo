package godot;

class HXScript extends Script {
    public var attachedNode:Null<Node>;

    public function new() {
        super();
        attachedNode = null;
    }

    public function attach(node:Node):Void {
        attachedNode = node;
    }
}