package godot.tscn;

class TscnNode {
	public var name:String;
	public var type:String;
	public var parent:String;
	public var instanceResource:Null<String>;
	public var properties:Array<TscnProperty>;
	public var sourceLine:Int;

	public function new(name:String, type:String, parent:String) {
		this.name = name;
		this.type = type;
		this.parent = parent;
		this.instanceResource = null;
		this.properties = [];
		this.sourceLine = 0;
	}
}
