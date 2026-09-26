package godot;

class ResourcePath {
    public static function normalize(path:String):String {
        var p:String = StringTools.replace(path, "\\", "/");

        if (StringTools.startsWith(p, "res://")) {
            return p;
        }

        return "res://" + p;
    }

    public static function to_system_path(path:String, projectRoot:String):String {
        var normalized:String = normalize(path);
        var relative:String = StringTools.replace(normalized, "res://", "");
        return projectRoot + "/" + relative;
    }

    public static function get_extension(path:String):String {
        var normalized:String = normalize(path);
        var index:Int = normalized.lastIndexOf(".");
        if (index < 0) {
            return "";
        }
        return normalized.substr(index + 1).toLowerCase();
    }

    public static function get_file_name(path:String):String {
        var normalized:String = normalize(path);
        var slash:Int = normalized.lastIndexOf("/");
        if (slash < 0) {
            return normalized;
        }
        return normalized.substr(slash + 1);
    }
}