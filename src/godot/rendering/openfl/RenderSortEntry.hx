package godot.rendering.openfl;

import openfl.display.DisplayObject;

class RenderSortEntry {
	public var y:Float;
	public var z:Int;
	public var display:DisplayObject;

	public function new(y:Float, z:Int, display:DisplayObject) {
		this.y = y;
		this.z = z;
		this.display = display;
	}
}
