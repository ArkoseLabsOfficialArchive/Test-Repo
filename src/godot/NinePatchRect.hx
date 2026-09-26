package godot;

class NinePatchRect extends Control {
	public var texture:Null<Texture>;

	public var patchMarginLeft:Int;
	public var patchMarginTop:Int;
	public var patchMarginRight:Int;
	public var patchMarginBottom:Int;

	public var drawCenter:Bool;

	public static var AXIS_STRETCH_STRETCH:Int = 0;
	public static var AXIS_STRETCH_TILE:Int = 1;
	public static var AXIS_STRETCH_TILE_FIT:Int = 2;

	public var axisStretchHorizontal:Int;
	public var axisStretchVertical:Int;

	public function new() {
		super();

		texture = null;

		patchMarginLeft = 0;
		patchMarginTop = 0;
		patchMarginRight = 0;
		patchMarginBottom = 0;

		drawCenter = true;
		axisStretchHorizontal = AXIS_STRETCH_STRETCH;
		axisStretchVertical = AXIS_STRETCH_STRETCH;
	}

	public function set_texture(value:Null<Texture>):Void {
		texture = value;

		mark_dirty(DirtyFlag.Texture);
		mark_dirty(DirtyFlag.Layout);
	}

	override public function set_property(name:String, value:godot.tscn.TscnValue, doc:godot.tscn.TscnDocument):Bool {
		switch (name) {
			case "texture":
				var resource:Null<Resource> = ResourceFactory.create_resource_from_value(value, doc);
				set_texture(Std.instance(resource, Texture));
				return true;

			case "patch_margin_left":
				if (value.intValue != null) {
					patchMarginLeft = value.intValue;
					mark_dirty(DirtyFlag.Layout);
					return true;
				}

			case "patch_margin_top":
				if (value.intValue != null) {
					patchMarginTop = value.intValue;
					mark_dirty(DirtyFlag.Layout);
					return true;
				}

			case "patch_margin_right":
				if (value.intValue != null) {
					patchMarginRight = value.intValue;
					mark_dirty(DirtyFlag.Layout);
					return true;
				}

			case "patch_margin_bottom":
				if (value.intValue != null) {
					patchMarginBottom = value.intValue;
					mark_dirty(DirtyFlag.Layout);
					return true;
				}

			case "draw_center":
				if (value.boolValue != null) {
					drawCenter = value.boolValue;
					mark_dirty(DirtyFlag.Visual);
					return true;
				}

			case "axis_stretch_horizontal":
				if (value.intValue != null) {
					axisStretchHorizontal = value.intValue;
					mark_dirty(DirtyFlag.Layout);
					return true;
				}

			case "axis_stretch_vertical":
				if (value.intValue != null) {
					axisStretchVertical = value.intValue;
					mark_dirty(DirtyFlag.Layout);
					return true;
				}
		}

		return super.set_property(name, value, doc);
	}
}
