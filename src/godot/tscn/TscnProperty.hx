package godot.tscn;

class TscnProperty {
	public var name:String;
	public var value:TscnValue;
	public var line:Int;

	public function new(name:String, value:TscnValue, line:Int = 0) {
		this.name = name;
		this.value = value;
		this.line = line;
	}
}
