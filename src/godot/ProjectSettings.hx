package godot;

class ProjectSettings {
	static var initialized:Bool = false;
	static var settings:Map<String, String> = new Map<String, String>();

	public static function initialize():Void {
		if (initialized)
			return;

		try {
			var text:String = sys.io.File.getContent("project.godot");
			var lines:Array<String> = text.split("\n");
			var section:String = "";

			for (rawLine in lines) {
				var line:String = StringTools.trim(rawLine);
				if (line.length == 0 || StringTools.startsWith(line, ";"))
					continue;

				if (StringTools.startsWith(line, "[") && StringTools.endsWith(line, "]")) {
					section = line.substr(1, line.length - 2);
					continue;
				}

				var eq:Int = line.indexOf("=");
				if (eq < 0)
					continue;

				var key:String = StringTools.trim(line.substr(0, eq));
				var value:String = StringTools.trim(line.substr(eq + 1));
				value = StringTools.replace(value, "\"", "");

				var fullKey:String = section.length > 0 ? (section + "/" + key) : key;
				settings.set(fullKey, value);
			}
		} catch (e:Dynamic) {
			trace("Warning: Could not read project.godot: " + e);
		}

		initialized = true;
	}

	public static function get_section_keys(section:String):Array<String> {
		ensure_initialized();

		var out:Array<String> = [];
		var prefix:String = section + "/";

		for (key in settings.keys()) {
			if (StringTools.startsWith(key, prefix)) {
				out.push(key.substr(prefix.length));
			}
		}

		return out;
	}

	public static function has_setting(path:String):Bool {
		ensure_initialized();
		return settings.exists(path);
	}

	public static function get_setting(path:String):Null<String> {
		ensure_initialized();
		return settings.get(path);
	}

	public static function get_int(path:String, fallback:Int = 0):Int {
		var value = get_setting(path);
		return value != null ? Std.parseInt(value) : fallback;
	}

	public static function get_float(path:String, fallback:Float = 0.0):Float {
		var value = get_setting(path);
		return value != null ? Std.parseFloat(value) : fallback;
	}

	public static function get_bool(path:String, fallback:Bool = false):Bool {
		var value = get_setting(path);
		return value != null ? value == "true" : fallback;
	}

	static function ensure_initialized():Void {
		if (!initialized)
			initialize();
	}
}
