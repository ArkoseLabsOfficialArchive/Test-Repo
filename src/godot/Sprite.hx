package godot;

class Sprite extends Node2D {
	public var texture:Null<Texture>;
	public var centered:Bool;
	public var offset:Vector2;

	public var flipH:Bool;
	public var flipV:Bool;

	public var regionEnabled:Bool;
	public var regionRect:Rect2;

	public var hframes:Int;
	public var vframes:Int;
	public var frame:Int;

	public function new() {
		super();

		texture = null;
		centered = true;
		offset = new Vector2(0, 0);

		flipH = false;
		flipV = false;

		regionEnabled = false;
		regionRect = Rect2.from_xywh(0, 0, 0, 0);

		hframes = 1;
		vframes = 1;
		frame = 0;
	}

	public function set_texture(value:Null<Texture>):Void {
		texture = value;
		mark_dirty(DirtyFlag.Texture);
		mark_dirty(DirtyFlag.Frame);
	}

	public function set_centered(value:Bool):Void {
		if (centered != value) {
			centered = value;
			mark_dirty(DirtyFlag.Visual);
		}
	}

	public function set_offset(value:Vector2):Void {
		offset = value;
		mark_dirty(DirtyFlag.Visual);
	}

	public function set_flip_h(value:Bool):Void {
		if (flipH != value) {
			flipH = value;
			mark_dirty(DirtyFlag.Visual);
		}
	}

	public function set_flip_v(value:Bool):Void {
		if (flipV != value) {
			flipV = value;
			mark_dirty(DirtyFlag.Visual);
		}
	}

	public function set_hframes(value:Int):Void {
		var clamped:Int = value < 1 ? 1 : value;

		if (hframes != clamped) {
			hframes = clamped;
			clamp_frame();
			mark_dirty(DirtyFlag.Frame);
		}
	}

	public function set_vframes(value:Int):Void {
		var clamped:Int = value < 1 ? 1 : value;

		if (vframes != clamped) {
			vframes = clamped;
			clamp_frame();
			mark_dirty(DirtyFlag.Frame);
		}
	}

	public function set_frame(value:Int):Void {
		var maxFrame:Int = hframes * vframes - 1;
		if (maxFrame < 0) {
			maxFrame = 0;
		}

		var clamped:Int = value;

		if (clamped < 0)
			clamped = 0;
		if (clamped > maxFrame)
			clamped = maxFrame;

		if (frame != clamped) {
			frame = clamped;
			mark_dirty(DirtyFlag.Frame);
		}
	}

	public function get_frame_coords():Vector2 {
		var columns:Int = hframes < 1 ? 1 : hframes;

		var x:Int = frame % columns;
		var y:Int = Math.floor(frame / columns);

		return new Vector2(x, y);
	}

	function clamp_frame():Void {
		var maxFrame:Int = hframes * vframes - 1;
		if (maxFrame < 0) {
			maxFrame = 0;
		}

		if (frame < 0)
			frame = 0;
		if (frame > maxFrame)
			frame = maxFrame;
	}

	override public function set_property(name:String, value:godot.tscn.TscnValue, doc:godot.tscn.TscnDocument):Bool {
		switch (name) {
			case "texture":
				var resource:Null<Resource> = ResourceFactory.create_resource_from_value(value, doc);
				set_texture(Std.instance(resource, Texture));
				return true;

			case "centered":
				if (value.boolValue != null) {
					set_centered(value.boolValue);
					return true;
				}

			case "offset":
				if (value.vector2Value != null) {
					set_offset(value.vector2Value);
					return true;
				}

			case "flip_h":
				if (value.boolValue != null) {
					set_flip_h(value.boolValue);
					return true;
				}

			case "flip_v":
				if (value.boolValue != null) {
					set_flip_v(value.boolValue);
					return true;
				}

			case "region_enabled":
				if (value.boolValue != null) {
					regionEnabled = value.boolValue;
					mark_dirty(DirtyFlag.Texture);
					return true;
				}

			case "region_rect":
				if (value.rect2Value != null) {
					regionRect = value.rect2Value;
					mark_dirty(DirtyFlag.Texture);
					return true;
				}

			case "hframes":
				if (value.intValue != null) {
					set_hframes(value.intValue);
					return true;
				}

			case "vframes":
				if (value.intValue != null) {
					set_vframes(value.intValue);
					return true;
				}

			case "frame":
				if (value.intValue != null) {
					set_frame(value.intValue);
					return true;
				}
		}

		return super.set_property(name, value, doc);
	}
}
