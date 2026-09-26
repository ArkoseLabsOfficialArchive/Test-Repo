package godot;

import godot.Input;

class InputMap {
	public static function initialize_from_project_settings():Void {
		var actions:Array<String> = ProjectSettings.get_section_keys("input");

		for (action in actions) {
			var value:Null<String> = ProjectSettings.get_setting("input/" + action);
			if (value == null) {
				continue;
			}

			var keyCode:Null<Int> = key_name_to_code(value);
			if (keyCode != null) {
				Input.instance.add_action_binding(new InputActionBinding(action, keyCode));
			}
		}
	}

	public static function key_name_to_code(name:String):Null<Int> {
		var upper:String = name.toUpperCase();

		if (upper.length == 1) {
			var code:Int = upper.charCodeAt(0);

			if (code >= 65 && code <= 90) {
				return code;
			}

			if (code >= 48 && code <= 57) {
				return code;
			}
		}

		return switch (upper) {
			case "ESCAPE": 27;
			case "ENTER", "RETURN": 13;
			case "SPACE": 32;
			case "SHIFT": 16;
			case "CTRL", "CONTROL": 17;
			case "ALT": 18;
			case "LEFT": 37;
			case "UP": 38;
			case "RIGHT": 39;
			case "DOWN": 40;
			default: null;
		}
	}
}
