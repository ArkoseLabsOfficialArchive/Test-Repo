package godot.tscn;

import godot.core.EngineError;
import godot.core.Log;

private class PropertyValueReadResult {
	public var text:String;
	public var nextIndex:Int;

	public function new(text:String, nextIndex:Int) {
		this.text = text;
		this.nextIndex = nextIndex;
	}
}

class TscnParser {
	var sourcePath:String;
	var currentLine:Int;

	public function new() {
		sourcePath = "";
		currentLine = 0;
	}

	public function parse(text:String, sourcePath:String = ""):TscnDocument {
		this.sourcePath = sourcePath;

		// Normalize line endings to prevent \r issues
		text = StringTools.replace(text, "\r\n", "\n");
		text = StringTools.replace(text, "\r", "\n");

		var doc:TscnDocument = new TscnDocument();
		doc.sourcePath = sourcePath;
		var lines:Array<String> = text.split("\n");

		var currentSubResource:Null<TscnSubResource> = null;
		var currentNode:Null<TscnNode> = null;

		var i:Int = 0;
		while (i < lines.length) {
			currentLine = i + 1;
			var rawLine:String = lines[i];
			var line:String = StringTools.trim(rawLine);

			if (line.length == 0) {
				i++;
				continue;
			}

			if (StringTools.startsWith(line, "[")) {
				currentSubResource = null;
				currentNode = null;

				if (StringTools.startsWith(line, "[gd_scene"))
					doc.header = parse_header(line);
				else if (StringTools.startsWith(line, "[ext_resource"))
					doc.extResources.push(parse_ext_resource(line));
				else if (StringTools.startsWith(line, "[sub_resource")) {
					var sub:TscnSubResource = parse_sub_resource(line);
					doc.subResources.push(sub);
					currentSubResource = sub;
				} else if (StringTools.startsWith(line, "[node")) {
					var node:TscnNode = parse_node(line);
					node.sourceLine = currentLine;
					doc.nodes.push(node);
					currentNode = node;
				} else if (StringTools.startsWith(line, "[connection"))
					doc.connections.push(parse_connection(line));

				i++;
				continue;
			}

			var eq:Int = rawLine.indexOf("=");
			if (eq < 0) {
				i++;
				continue;
			}

			var key:String = StringTools.trim(rawLine.substr(0, eq));
			var firstValue:String = rawLine.substr(eq + 1);

			var startLine:Int = currentLine;
			var collected:PropertyValueReadResult = collect_property_value(lines, i, firstValue);
			var valueText:String = collected.text;
			i = collected.nextIndex;

			var value:TscnValue = new TscnValueParser(valueText, sourcePath, startLine).parse();

			if (currentSubResource != null)
				currentSubResource.properties.set(key, value);
			else if (currentNode != null)
				currentNode.properties.push(new TscnProperty(key, value, startLine));

			i++;
		}

		validate(doc);
		return doc;
	}

	function collect_property_value(lines:Array<String>, index:Int, first:String):PropertyValueReadResult {
		var value:String = first;
		while (!is_value_balanced(value) && index + 1 < lines.length) {
			index++;
			value += "\n" + lines[index]; // Preserve exact formatting/newlines inside strings
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
				if (!escaped)
					inString = !inString;
			} else if (!inString) {
				if (c == "[")
					square++;
				if (c == "]")
					square--;
				if (c == "{")
					curly++;
				if (c == "}")
					curly--;
				if (c == "(")
					paren++;
				if (c == ")")
					paren--;
			}
			i++;
		}

		// FIX: Must also ensure we are not inside an unclosed string!
		return square == 0 && curly == 0 && paren == 0 && !inString;
	}

	function validate(doc:TscnDocument):Void {
		if (doc.header == null)
			fatal("Missing [gd_scene] header");
		var header:TscnHeader = doc.header;
		if (header.format != 2)
			Log.warning("TSCN", "Parser expects format=2; found format=" + header.format + " in " + sourcePath);
		if (doc.nodes.length == 0)
			fatal("Scene contains no nodes");
	}

	function parse_header(line:String):TscnHeader {
		var attrs = parse_attributes(line);
		var loadSteps:Int = attrs.exists("load_steps") ? Std.parseInt(attrs.get("load_steps")) : 0;
		var format:Int = attrs.exists("format") ? Std.parseInt(attrs.get("format")) : 2;
		return new TscnHeader(loadSteps, format);
	}

	function parse_ext_resource(line:String):TscnExternalResource {
		var attrs = parse_attributes(line);
		return new TscnExternalResource(clean_string(attrs.get("id")), clean_string(attrs.get("path")), clean_string(attrs.get("type")));
	}

	function parse_sub_resource(line:String):TscnSubResource {
		var attrs = parse_attributes(line);
		return new TscnSubResource(clean_string(attrs.get("id")), clean_string(attrs.get("type")));
	}

	function parse_node(line:String):TscnNode {
		var attrs = parse_attributes(line);
		var name:String = clean_string(attrs.get("name"));
		var type:String = clean_string(attrs.get("type"));
		var parent:String = attrs.exists("parent") ? clean_string(attrs.get("parent")) : ".";
		var node:TscnNode = new TscnNode(name, type, parent);
		if (attrs.exists("instance"))
			node.instanceResource = attrs.get("instance");
		return node;
	}

	function parse_connection(line:String):TscnConnection {
		var attrs = parse_attributes(line);
		return new TscnConnection(clean_string(attrs.get("from")), clean_string(attrs.get("to")), clean_string(attrs.get("signal")),
			clean_string(attrs.get("method")));
	}

	function parse_attributes(line:String):Map<String, String> {
		var result:Map<String, String> = new Map<String, String>();
		var start:Int = line.indexOf(" ");
		var end:Int = line.lastIndexOf("]");
		if (start < 0 || end < 0 || end <= start)
			return result;

		var body:String = line.substr(start + 1, end - start - 1);
		var i:Int = 0;
		while (i < body.length) {
			i = skip_spaces(body, i);
			if (i >= body.length)
				break;
			var keyStart:Int = i;
			while (i < body.length && body.charAt(i) != "=" && body.charAt(i) != " ")
				i++;
			var key:String = StringTools.trim(body.substring(keyStart, i));
			i = skip_spaces(body, i);
			if (i >= body.length || body.charAt(i) != "=") {
				if (key.length > 0)
					result.set(key, "");
				continue;
			}
			i++;
			i = skip_spaces(body, i);
			var valueRead = read_attribute_value(body, i);
			result.set(key, valueRead.value);
			i = valueRead.nextIndex;
		}
		return result;
	}

	function read_attribute_value(body:String, startIndex:Int):AttributeValueReadResult {
		var i:Int = startIndex;
		if (i >= body.length)
			return new AttributeValueReadResult("", i);
		var first:String = body.charAt(i);
		if (first == "\"") {
			var out:StringBuf = new StringBuf();
			out.add("\"");
			i++;
			while (i < body.length) {
				var c:String = body.charAt(i);
				out.add(c);
				if (c == "\\") {
					i++;
					if (i < body.length)
						out.add(body.charAt(i));
					i++;
					continue;
				}
				if (c == "\"") {
					i++;
					return new AttributeValueReadResult(out.toString(), i);
				}
				i++;
			}
			fatal("Unterminated quoted attribute value");
		}
		var value:StringBuf = new StringBuf();
		var parenDepth:Int = 0;
		var inQuote:Bool = false;
		while (i < body.length) {
			var c:String = body.charAt(i);
			if (c == "\"")
				inQuote = !inQuote;
			if (!inQuote) {
				if (c == "(")
					parenDepth++;
				if (c == ")")
					parenDepth--;
				if (c == " " && parenDepth == 0)
					break;
			}
			value.add(c);
			i++;
		}
		return new AttributeValueReadResult(value.toString(), i);
	}

	function skip_spaces(body:String, index:Int):Int {
		while (index < body.length && body.charAt(index) == " ")
			index++;
		return index;
	}

	function clean_string(value:Null<String>):String {
		return value == null ? "" : StringTools.replace(value, "\"", "");
	}

	function fatal(message:String):Void {
		Log.fatal(new EngineError("TSCN", "TscnParser", "parse",
			message
			+ " in "
			+ (sourcePath.length > 0 ? sourcePath : "unknown scene")
			+ " at line "
			+ currentLine));
	}
}

private class AttributeValueReadResult {
	public var value:String;
	public var nextIndex:Int;

	public function new(value:String, nextIndex:Int) {
		this.value = value;
		this.nextIndex = nextIndex;
	}
}
