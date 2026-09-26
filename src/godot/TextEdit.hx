package godot;

class TextEdit extends Control {
	public var text:String;
	public var editable:Bool;
	public var caretIndex:Int;

	public function new() {
		super();

		text = "";
		editable = true;
		caretIndex = 0;

		mouseFilter = MouseFilter.Stop;
		focusMode = FocusMode.Click;

		add_user_signal("text_changed");
	}

	public function set_text(value:String):Void {
		if (text != value) {
			text = value;
			caretIndex = text.length;
			mark_dirty(DirtyFlag.Text);
		}
	}

	public function get_display_text_with_caret(showCaret:Bool):String {
		if (!showCaret) {
			return text;
		}

		var clampedIndex:Int = caretIndex;

		if (clampedIndex < 0) {
			clampedIndex = 0;
		}

		if (clampedIndex > text.length) {
			clampedIndex = text.length;
		}

		return text.substring(0, clampedIndex) + "|" + text.substring(clampedIndex);
	}

	override public function gui_input(event:InputEvent):Void {
		if (!editable) {
			return;
		}

		var key:Null<InputEventKey> = event.as_key();
		if (key == null || !key.pressed) {
			return;
		}

		handle_key(key, event);
	}

	function handle_key(key:InputEventKey, event:InputEvent):Void {
		switch (key.keyCode) {
			case 8:
				backspace();
				event.set_handled();

			case 13:
				insert_character("\n");
				event.set_handled();

			case 37:
				if (caretIndex > 0) {
					caretIndex--;
					mark_dirty(DirtyFlag.Text);
				}

				event.set_handled();

			case 39:
				if (caretIndex < text.length) {
					caretIndex++;
					mark_dirty(DirtyFlag.Text);
				}

				event.set_handled();

			case 46:
				delete_forward();
				event.set_handled();

			default:
				if (key.unicode >= 32) {
					insert_character(String.fromCharCode(key.unicode));
					event.set_handled();
				}
		}
	}

	function insert_character(character:String):Void {
		var clampedIndex:Int = caretIndex;

		if (clampedIndex < 0) {
			clampedIndex = 0;
		}

		if (clampedIndex > text.length) {
			clampedIndex = text.length;
		}

		text = text.substring(0, clampedIndex) + character + text.substring(clampedIndex);
		caretIndex = clampedIndex + character.length;

		mark_dirty(DirtyFlag.Text);
		emit_signal("text_changed", [text]);
	}

	function backspace():Void {
		if (caretIndex <= 0 || text.length == 0) {
			return;
		}

		var clampedIndex:Int = caretIndex;

		if (clampedIndex > text.length) {
			clampedIndex = text.length;
		}

		text = text.substring(0, clampedIndex - 1) + text.substring(clampedIndex);
		caretIndex = clampedIndex - 1;

		mark_dirty(DirtyFlag.Text);
		emit_signal("text_changed", [text]);
	}

	function delete_forward():Void {
		if (caretIndex >= text.length) {
			return;
		}

		text = text.substring(0, caretIndex) + text.substring(caretIndex + 1);

		mark_dirty(DirtyFlag.Text);
		emit_signal("text_changed", [text]);
	}

	override public function set_property(name:String, value:godot.tscn.TscnValue, doc:godot.tscn.TscnDocument):Bool {
		switch (name) {
			case "text":
				if (value.stringValue != null) {
					set_text(value.stringValue);
					return true;
				}

			case "editable":
				if (value.boolValue != null) {
					editable = value.boolValue;
					return true;
				}
		}

		return super.set_property(name, value, doc);
	}
}
