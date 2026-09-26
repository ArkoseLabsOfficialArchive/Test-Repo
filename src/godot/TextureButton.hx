package godot;

class TextureButton extends Control {
	public var textureNormal:Null<Texture>;
	public var texturePressed:Null<Texture>;
	public var textureHover:Null<Texture>;
	public var textureDisabled:Null<Texture>;

	public var pressed:Bool;
	public var hovered:Bool;
	public var disabled:Bool;

	public function new() {
		super();

		textureNormal = null;
		texturePressed = null;
		textureHover = null;
		textureDisabled = null;

		pressed = false;
		hovered = false;
		disabled = false;

		mouseFilter = MouseFilter.Stop;
		focusMode = FocusMode.Click;

		add_user_signal("pressed");
	}

	override public function gui_input(event:InputEvent):Void {
		if (disabled) {
			return;
		}

		var mouse:Null<InputEventMouseButton> = event.as_mouse_button();
		if (mouse == null || mouse.buttonIndex != 1) {
			return;
		}

		if (mouse.pressed) {
			if (has_global_point(mouse.position)) {
				pressed = true;
				mark_dirty(DirtyFlag.Visual);
				event.set_handled();
			}
		} else {
			if (pressed) {
				pressed = false;
				mark_dirty(DirtyFlag.Visual);

				if (has_global_point(mouse.position)) {
					emit_signal("pressed", []);
				}

				event.set_handled();
			}
		}
	}

	public function get_current_texture():Null<Texture> {
		if (disabled && textureDisabled != null) {
			return textureDisabled;
		}

		if (pressed && texturePressed != null) {
			return texturePressed;
		}

		if (hovered && textureHover != null) {
			return textureHover;
		}

		return textureNormal;
	}

	override public function set_property(name:String, value:godot.tscn.TscnValue, doc:godot.tscn.TscnDocument):Bool {
		switch (name) {
			case "texture_normal":
				var res:Null<Resource> = ResourceFactory.create_resource_from_value(value, doc);
				textureNormal = Std.instance(res, Texture);
				mark_dirty(DirtyFlag.Texture);
				return true;

			case "texture_pressed":
				var res:Null<Resource> = ResourceFactory.create_resource_from_value(value, doc);
				texturePressed = Std.instance(res, Texture);
				mark_dirty(DirtyFlag.Texture);
				return true;

			case "texture_hover":
				var res:Null<Resource> = ResourceFactory.create_resource_from_value(value, doc);
				textureHover = Std.instance(res, Texture);
				mark_dirty(DirtyFlag.Texture);
				return true;

			case "texture_disabled":
				var res:Null<Resource> = ResourceFactory.create_resource_from_value(value, doc);
				textureDisabled = Std.instance(res, Texture);
				mark_dirty(DirtyFlag.Texture);
				return true;

			case "disabled":
				if (value.boolValue != null) {
					disabled = value.boolValue;
					mark_dirty(DirtyFlag.Visual);
					return true;
				}
		}

		return super.set_property(name, value, doc);
	}
}
