package godot;

class StaticRectCollider {
	public var key:String;
	public var rect:Rect2;
	public var layer:Int;

	public function new(key:String, rect:Rect2, layer:Int) {
		this.key = key;
		this.rect = rect;
		this.layer = layer;
	}
}
