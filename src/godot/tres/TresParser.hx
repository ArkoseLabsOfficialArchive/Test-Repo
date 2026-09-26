package godot.tres;

import godot.core.EngineError;
import godot.core.Log;

import godot.tscn.TscnExternalResource;
import godot.tscn.TscnSubResource;
import godot.tscn.TscnValue;
import godot.tscn.TscnValueParser;

private class PropertyValueReadResult {
    public var text:String;
    public var nextIndex:Int;

    public function new(text:String, nextIndex:Int) {
        this.text = text;
        this.nextIndex = nextIndex;
    }
}

class TresParser {
    public function new() {}

    public function parse(text:String):TresDocument {
        var doc:TresDocument = new TresDocument();

        var lines:Array<String> = text.split("\n");

        var currentSubResource:Null<TscnSubResource> = null;

        var i:Int = 0;

        while (i < lines.length) {
            var line:String = StringTools.trim(lines[i]);

            if (line.length == 0) {
                i++;
                continue;
            }

            if (StringTools.startsWith(line, "[")) {
                currentSubResource = null;

                if (StringTools.startsWith(line, "[gd_resource")) {
                    doc.header = parse_header(line);
                } else if (StringTools.startsWith(line, "[ext_resource")) {
                    doc.extResources.push(parse_ext_resource(line));
                } else if (StringTools.startsWith(line, "[sub_resource")) {
                    var sub:TscnSubResource = parse_sub_resource(line);
                    doc.subResources.push(sub);
                    currentSubResource = sub;
                } else if (StringTools.startsWith(line, "[resource")) {
                    currentSubResource = null;
                }

                i++;
                continue;
            }

            var eq:Int = line.indexOf("=");
            if (eq < 0) {
                i++;
                continue;
            }

            var key:String = StringTools.trim(line.substr(0, eq));
            var firstValue:String = StringTools.trim(line.substr(eq + 1));

            var collected:PropertyValueReadResult = collect_property_value(lines, i, firstValue);
            var valueText:String = collected.text;
            i = collected.nextIndex;

            var value:TscnValue = new TscnValueParser(valueText).parse();

            if (currentSubResource != null) {
                currentSubResource.properties.set(key, value);
            } else {
                doc.properties.set(key, value);
            }

            i++;
        }

        validate(doc);

        return doc;
    }

    function collect_property_value(lines:Array<String>, index:Int, first:String):PropertyValueReadResult {
        var value:String = first;

        while (!is_value_balanced(value) && index + 1 < lines.length) {
            index++;
            value += "\n" + StringTools.trim(lines[index]);
        }

        return new PropertyValueReadResult(value, index);
    }

    function is_value_balanced(value:String):Bool {
        var inString:Bool = false;

        var square:Int = 0;
        var curly:Int = 0;
        var paren:Int = 0;

        var i:Int = 0;

        while (i < value.length) {
            var c:String = value.charAt(i);

            if (c == "\"") {
                var backslashes:Int = 0;
                var j:Int = i - 1;

                while (j >= 0 && value.charAt(j) == "\\") {
                    backslashes++;
                    j--;
                }

                var escaped:Bool = (backslashes % 2) == 1;

                if (!escaped) {
                    inString = !inString;
                }
            } else if (!inString) {
                if (c == "[") square++;
                if (c == "]") square--;
                if (c == "{") curly++;
                if (c == "}") curly--;
                if (c == "(") paren++;
                if (c == ")") paren--;
            }

            i++;
        }

        return square == 0 && curly == 0 && paren == 0;
    }

    function validate(doc:TresDocument):Void {
        if (doc.header == null) {
            Log.fatal(new EngineError(
                "TRES",
                "TresParser",
                "validate",
                "Missing [gd_resource] header"
            ));
        }

        var header:TresHeader = doc.header;

        if (header.format != 2) {
            Log.warning("TRES", "Parser expects format=2; found format=" + header.format);
        }

        if (header.type.length == 0) {
            Log.fatal(new EngineError(
                "TRES",
                "TresParser",
                "validate",
                "Resource header has no type"
            ));
        }
    }

    function parse_header(line:String):TresHeader {
        var attrs:Map<String, String> = parse_attributes(line);

        var type:String = clean_string(attrs.get("type"));
        var loadSteps:Int = 0;
        var format:Int = 2;

        if (attrs.exists("load_steps")) {
            var parsed:Null<Int> = Std.parseInt(attrs.get("load_steps"));
            if (parsed != null) {
                loadSteps = parsed;
            }
        }

        if (attrs.exists("format")) {
            var parsed:Null<Int> = Std.parseInt(attrs.get("format"));
            if (parsed != null) {
                format = parsed;
            }
        }

        return new TresHeader(type, loadSteps, format);
    }

    function parse_ext_resource(line:String):TscnExternalResource {
        var attrs:Map<String, String> = parse_attributes(line);

        return new TscnExternalResource(
            clean_string(attrs.get("id")),
            clean_string(attrs.get("path")),
            clean_string(attrs.get("type"))
        );
    }

    function parse_sub_resource(line:String):TscnSubResource {
        var attrs:Map<String, String> = parse_attributes(line);

        return new TscnSubResource(
            clean_string(attrs.get("id")),
            clean_string(attrs.get("type"))
        );
    }

    function parse_attributes(line:String):Map<String, String> {
        var result:Map<String, String> = new Map<String, String>();

        var start:Int = line.indexOf(" ");
        var end:Int = line.lastIndexOf("]");

        if (start < 0 || end < 0 || end <= start) {
            return result;
        }

        var body:String = line.substr(start + 1, end - start - 1);

        var key:String = "";
        var value:String = "";
        var readingValue:Bool = false;
        var inString:Bool = false;

        var i:Int = 0;

        while (i < body.length) {
            var ch:String = body.charAt(i);

            if (!readingValue) {
                if (ch == "=") {
                    readingValue = true;
                    value = "";
                } else if (ch != " ") {
                    key += ch;
                }
            } else {
                if (ch == "\"") {
                    inString = !inString;
                    value += ch;
                } else if (ch == " " && !inString) {
                    result.set(StringTools.trim(key), StringTools.trim(value));
                    key = "";
                    value = "";
                    readingValue = false;
                } else {
                    value += ch;
                }
            }

            i++;
        }

        if (key.length > 0) {
            result.set(StringTools.trim(key), StringTools.trim(value));
        }

        return result;
    }

    function clean_string(value:Null<String>):String {
        if (value == null) {
            return "";
        }

        return StringTools.replace(value, "\"", "");
    }
}