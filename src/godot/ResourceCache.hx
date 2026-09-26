package godot;

class ResourceCache {
	static var cache:Map<String, Resource> = new Map<String, Resource>();

	public static function has(path:String):Bool {
		return cache.exists(ResourcePath.normalize(path));
	}

	public static function get(path:String):Null<Resource> {
		return cache.get(ResourcePath.normalize(path));
	}

	public static function put(path:String, resource:Resource):Void {
		var normalized:String = ResourcePath.normalize(path);
		resource.set_path(normalized);
		cache.set(normalized, resource);
	}

	public static function remove(path:String):Void {
		cache.remove(ResourcePath.normalize(path));
	}

	public static function clear():Void {
		cache.clear();
	}
}
