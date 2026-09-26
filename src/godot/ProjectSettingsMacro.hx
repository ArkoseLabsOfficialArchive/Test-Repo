package godot;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;

class ProjectSettingsMacro {
    public static function build(projectFile:String = "project.godot"):Expr {
        var values:Map<String, String> = new Map<String, String>();

        try {
            var text:String = sys.io.File.getContent(projectFile);
            var lines:Array<String> = text.split("\n");

            var section:String = "";

            for (rawLine in lines) {
                var line:String = StringTools.trim(rawLine);

                if (line.length == 0 || StringTools.startsWith(line, ";")) {
                    continue;
                }

                if (StringTools.startsWith(line, "[") && StringTools.endsWith(line, "]")) {
                    section = line.substr(1, line.length - 2);
                    continue;
                }

                var eq:Int = line.indexOf("=");
                if (eq < 0) {
                    continue;
                }

                var key:String = StringTools.trim(line.substr(0, eq));
                var value:String = StringTools.trim(line.substr(eq + 1));

                value = StringTools.replace(value, "\"", "");

                var fullKey:String = section.length > 0 ? (section + "/" + key) : key;
                values.set(fullKey, value);
            }
        } catch (e:Dynamic) {
            Context.warning("Could not read project settings: " + Std.string(e), Context.currentPos());
        }

        var arrayExprs:Array<Expr> = [];

        for (key in values.keys()) {
            var value:Null<String> = values.get(key);
            arrayExprs.push(macro {
                key: $v{key},
                value: $v{value}
            });
        }

        return macro $a{arrayExprs};
    }
}
#end