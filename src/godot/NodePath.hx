package godot;

class NodePath {
	public var raw:String;
	public var parts:Array<String>;
	public var absolute:Bool;

	public function new(path:String) {
		this.raw = path;
		this.parts = [];
		this.absolute = false;
		parse(path);
	}

	function parse(path:String):Void {
		if (path.length == 0) {
			return;
		}

		if (path.charAt(0) == "/") {
			absolute = true;
		}

		var normalized:String = StringTools.replace(path, "\\", "/");
		var chunks:Array<String> = normalized.split("/");

		for (chunk in chunks) {
			if (chunk.length == 0)
				continue;
			parts.push(chunk);
		}
	}

	public function is_absolute():Bool {
		return absolute;
	}

	public function get_part_count():Int {
		return parts.length;
	}

	public function get_part(index:Int):Null<String> {
		if (index < 0 || index >= parts.length) {
			return null;
		}
		return parts[index];
	}

	public function copy():NodePath {
		return new NodePath(raw);
	}

	public function toString():String {
		return raw;
	}
}
