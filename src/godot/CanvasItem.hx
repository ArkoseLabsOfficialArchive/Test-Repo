package godot;

class CanvasItem extends Node {
	public var visible:Bool;
	public var modulate:Color;
	public var selfModulate:Color;
	public var zIndex:Int;
	public var zAsRelative:Bool;

	public var dirtyFlags:Int;

	public function new() {
		super();
		visible = true;
		modulate = Color.white();
		selfModulate = Color.white();
		zIndex = 0;
		zAsRelative = true;
		dirtyFlags = 0;
	}

	public function mark_dirty(flag:Int):Void {
		dirtyFlags |= (1 << flag);
	}

	public function is_dirty(flag:Int):Bool {
		return (dirtyFlags & (1 << flag)) != 0;
	}

	public function clear_dirty(flag:Int):Void {
		dirtyFlags &= ~(1 << flag);
	}

	public function clear_all_dirty():Void {
		dirtyFlags = 0;
	}

	public function show():Void {
		if (!visible) {
			visible = true;
			mark_dirty(DirtyFlag.Visibility);
		}
	}

	public function hide():Void {
		if (visible) {
			visible = false;
			mark_dirty(DirtyFlag.Visibility);
		}
	}

	public function set_visible(value:Bool):Void {
		if (visible != value) {
			visible = value;
			mark_dirty(DirtyFlag.Visibility);
		}
	}

	public function set_z_index(value:Int):Void {
		if (zIndex != value) {
			zIndex = value;
			mark_dirty(DirtyFlag.ZIndex);
		}
	}

	public function set_modulate(value:Color):Void {
		modulate = value;
		mark_dirty(DirtyFlag.Visual);
	}
}
