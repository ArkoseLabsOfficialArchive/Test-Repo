package godot;

class TextureRect extends Control {
	public var texture:Null<Texture>;
	public var expand:Bool;
	public var stretchMode:Int;
	public var flipH:Bool;
	public var flipV:Bool;

	public function new() {
		super();

		texture = null;
		expand = false;
		stretchMode = 0;
		flipH = false;
		flipV = false;
	}

	public function set_texture(value:Null<Texture>):Void {
		texture = value;
		mark_dirty(DirtyFlag.Texture);
		mark_dirty(DirtyFlag.Layout);
		mark_parent_layout_dirty();
	}

	public function set_expand(value:Bool):Void {
		if (expand != value) {
			expand = value;
			mark_dirty(DirtyFlag.Texture);
			mark_dirty(DirtyFlag.Layout);
		}
	}

	override public function get_combined_minimum_size():Vector2 {
		var custom:Vector2 = customMinimumSize.copy();

		if (expand || texture == null) {
			return custom;
		}

		var textureSize:Vector2 = texture.get_size();

		if (custom.x > textureSize.x)
			textureSize.x = custom.x;
		if (custom.y > textureSize.y)
			textureSize.y = custom.y;

		return textureSize;
	}

	override public function set_property(name:String, value:godot.tscn.TscnValue, doc:godot.tscn.TscnDocument):Bool {
		switch (name) {
			case "texture":
				var resource:Null<Resource> = ResourceFactory.create_resource_from_value(value, doc);
				var loadedTexture:Null<Texture> = Std.instance(resource, Texture);

				set_texture(loadedTexture);
				return true;

			case "expand":
				if (value.boolValue != null) {
					set_expand(value.boolValue);
					return true;
				}

			case "stretch_mode":
				if (value.intValue != null) {
					stretchMode = value.intValue;
					mark_dirty(DirtyFlag.Texture);
					mark_dirty(DirtyFlag.Layout);
					return true;
				}

			case "flip_h":
				if (value.boolValue != null) {
					flipH = value.boolValue;
					mark_dirty(DirtyFlag.Texture);
					return true;
				}

			case "flip_v":
				if (value.boolValue != null) {
					flipV = value.boolValue;
					mark_dirty(DirtyFlag.Texture);
					return true;
				}
		}

		return super.set_property(name, value, doc);
	}
}
