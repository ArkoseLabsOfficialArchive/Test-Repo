package godot.tscn;

import godot.core.EngineError;
import godot.core.Log;

class TscnValueParser {
	var text:String;
	var pos:Int;
	var length:Int;

	var sourcePath:String;
	var lineNumber:Int;

	public function new(text:String, sourcePath:String = "", lineNumber:Int = 0) {
		this.text = text;
		this.sourcePath = sourcePath;
		this.lineNumber = lineNumber;
		this.pos = 0;
		this.length = text.length;
	}

	public function parse():TscnValue {
		skip_whitespace();

		if (pos >= length) {
			return TscnValue.make_null();
		}

		return parse_value();
	}

	function parse_value():TscnValue {
		skip_whitespace();

		if (pos >= length) {
			return TscnValue.make_null();
		}

		var c:String = text.charAt(pos);

		if (c == "[") {
			return parse_array();
		}

		if (c == "{") {
			return parse_dictionary();
		}

		if (c == "\"") {
			return TscnValue.make_string(parse_string());
		}

		if (is_number_start(c)) {
			return parse_number();
		}

		return parse_identifier_or_constructor();
	}

	function parse_array():TscnValue {
		expect("[");

		var values:Array<TscnValue> = [];

		skip_whitespace();

		if (peek() == "]") {
			pos++;
			return TscnValue.make_array(values);
		}

		while (pos < length) {
			var value:TscnValue = parse_value();
			values.push(value);

			skip_whitespace();

			if (peek() == ",") {
				pos++;
				skip_whitespace();
				continue;
			}

			if (peek() == "]") {
				pos++;
				return TscnValue.make_array(values);
			}

			fatal("Malformed array");
		}

		fatal("Unterminated array");
		return TscnValue.make_array([]);
	}

	function parse_dictionary():TscnValue {
		expect("{");

		var values:Map<String, TscnValue> = new Map<String, TscnValue>();

		skip_whitespace();

		if (peek() == "}") {
			pos++;
			return TscnValue.make_dictionary(values);
		}

		while (pos < length) {
			skip_whitespace();

			var key:String;

			if (peek() == "\"") {
				key = parse_string();
			} else {
				key = parse_identifier();
			}

			skip_whitespace();
			expect(":");

			var value:TscnValue = parse_value();
			values.set(key, value);

			skip_whitespace();

			if (peek() == ",") {
				pos++;
				continue;
			}

			if (peek() == "}") {
				pos++;
				return TscnValue.make_dictionary(values);
			}

			fatal("Malformed dictionary");
		}

		fatal("Unterminated dictionary");
		return TscnValue.make_dictionary(new Map<String, TscnValue>());
	}

	function parse_string():String {
		expect("\"");

		var out:StringBuf = new StringBuf();

		while (pos < length) {
			var c:String = text.charAt(pos);

			if (c == "\\") {
				pos++;

				if (pos >= length) {
					fatal("Unterminated escape sequence in string");
				}

				var escaped:String = text.charAt(pos);

				if (escaped == "n") {
					out.add("\n");
				} else if (escaped == "t") {
					out.add("\t");
				} else if (escaped == "r") {
					out.add("\r");
				} else {
					out.add(escaped);
				}

				pos++;
				continue;
			}

			if (c == "\"") {
				pos++;
				return out.toString();
			}

			out.add(c);
			pos++;
		}

		fatal("Unterminated string");
		return "";
	}

	function parse_number():TscnValue {
		var start:Int = pos;

		while (pos < length) {
			var c:String = text.charAt(pos);

			if ((c >= "0" && c <= "9") || c == "." || c == "-" || c == "+" || c == "e" || c == "E") {
				pos++;
			} else {
				break;
			}
		}

		var token:String = text.substr(start, pos - start);

		if (token.indexOf(".") < 0 && token.indexOf("e") < 0 && token.indexOf("E") < 0) {
			var intValue:Null<Int> = Std.parseInt(token);
			if (intValue != null) {
				return TscnValue.make_int(intValue);
			}
		}

		var floatValue:Float = Std.parseFloat(token);
		if (!Math.isNaN(floatValue)) {
			return TscnValue.make_float(floatValue);
		}

		return TscnValue.make_string(token);
	}

	function parse_identifier_or_constructor():TscnValue {
		var identifier:String = parse_identifier();

		skip_whitespace();

		if (peek() != "(") {
			if (identifier == "true") {
				return TscnValue.make_bool(true);
			}

			if (identifier == "false") {
				return TscnValue.make_bool(false);
			}

			if (identifier == "null") {
				return TscnValue.make_null();
			}

			return TscnValue.make_string(identifier);
		}

		expect("(");

		var args:Array<TscnValue> = [];

		skip_whitespace();

		if (peek() == ")") {
			pos++;
			return make_constructor_value(identifier, args);
		}

		while (pos < length) {
			var arg:TscnValue = parse_value();
			args.push(arg);

			skip_whitespace();

			if (peek() == ",") {
				pos++;
				skip_whitespace();
				continue;
			}

			if (peek() == ")") {
				pos++;
				return make_constructor_value(identifier, args);
			}

			fatal("Malformed constructor arguments");
		}

		fatal("Unterminated constructor");
		return TscnValue.make_null();
	}

	function make_constructor_value(name:String, args:Array<TscnValue>):TscnValue {
		switch (name) {
			case "Vector2":
				return TscnValue.make_vector2(new godot.Vector2(get_float(args, 0), get_float(args, 1)));

			case "Vector3":
				return TscnValue.make_vector3(new godot.Vector3(get_float(args, 0), get_float(args, 1), get_float(args, 2)));

			case "Rect2":
				return TscnValue.make_rect2(godot.Rect2.from_xywh(get_float(args, 0), get_float(args, 1), get_float(args, 2), get_float(args, 3)));

			case "Color":
				return TscnValue.make_color(new godot.Color(get_float(args, 0), get_float(args, 1), get_float(args, 2),
					args.length > 3 ? get_float(args, 3) : 1.0));

			case "NodePath":
				return TscnValue.make_node_path(new godot.NodePath(get_string(args, 0)));

			case "ExtResource":
				return TscnValue.make_ext_resource(get_string(args, 0));

			case "SubResource":
				return TscnValue.make_sub_resource(get_string(args, 0));

			case "PoolByteArray":
				return TscnValue.make_pool_byte_array(args_to_ints(args));

			case "PoolIntArray":
				return TscnValue.make_pool_int_array(args_to_ints(args));

			case "PoolRealArray":
				return TscnValue.make_pool_real_array(args_to_floats(args));

			case "PoolStringArray":
				return TscnValue.make_pool_string_array(args_to_strings(args));

			case "PoolVector2Array":
				return TscnValue.make_pool_vector2_array(args_to_vector2s(args));

			case "PoolVector3Array":
				return TscnValue.make_pool_vector3_array(args_to_vector3s(args));

			case "PoolColorArray":
				return TscnValue.make_pool_color_array(args_to_colors(args));

			default:
				return TscnValue.make_string(name);
		}
	}

	function parse_identifier():String {
		var start:Int = pos;

		while (pos < length) {
			var code:Int = text.charCodeAt(pos);

			var valid:Bool = (code >= 65 && code <= 90) || (code >= 97 && code <= 122) || (code >= 48 && code <= 57) || code == 95;

			if (!valid) {
				break;
			}

			pos++;
		}

		return text.substr(start, pos - start);
	}

	function args_to_floats(args:Array<TscnValue>):Array<Float> {
		var out:Array<Float> = [];

		for (arg in args) {
			out.push(value_to_float(arg));
		}

		return out;
	}

	function args_to_ints(args:Array<TscnValue>):Array<Int> {
		var out:Array<Int> = [];

		for (arg in args) {
			out.push(Math.round(value_to_float(arg)));
		}

		return out;
	}

	function args_to_strings(args:Array<TscnValue>):Array<String> {
		var out:Array<String> = [];

		for (arg in args) {
			out.push(value_to_string(arg));
		}

		return out;
	}

	function args_to_vector2s(args:Array<TscnValue>):Array<godot.Vector2> {
		var out:Array<godot.Vector2> = [];

		var i:Int = 0;
		while (i + 1 < args.length) {
			out.push(new godot.Vector2(value_to_float(args[i]), value_to_float(args[i + 1])));

			i += 2;
		}

		return out;
	}

	function args_to_vector3s(args:Array<TscnValue>):Array<godot.Vector3> {
		var out:Array<godot.Vector3> = [];

		var i:Int = 0;
		while (i + 2 < args.length) {
			out.push(new godot.Vector3(value_to_float(args[i]), value_to_float(args[i + 1]), value_to_float(args[i + 2])));

			i += 3;
		}

		return out;
	}

	function args_to_colors(args:Array<TscnValue>):Array<godot.Color> {
		var out:Array<godot.Color> = [];

		var i:Int = 0;
		while (i + 3 < args.length) {
			out.push(new godot.Color(value_to_float(args[i]), value_to_float(args[i + 1]), value_to_float(args[i + 2]), value_to_float(args[i + 3])));

			i += 4;
		}

		return out;
	}

	function get_float(args:Array<TscnValue>, index:Int):Float {
		if (index < 0 || index >= args.length) {
			return 0.0;
		}

		return value_to_float(args[index]);
	}

	function get_string(args:Array<TscnValue>, index:Int):String {
		if (index < 0 || index >= args.length) {
			return "";
		}

		return value_to_string(args[index]);
	}

	function value_to_float(value:TscnValue):Float {
		if (value.intValue != null) {
			return value.intValue;
		}

		if (value.floatValue != null) {
			return value.floatValue;
		}

		if (value.stringValue != null) {
			var parsed:Float = Std.parseFloat(value.stringValue);
			if (!Math.isNaN(parsed)) {
				return parsed;
			}
		}

		return 0.0;
	}

	function value_to_string(value:TscnValue):String {
		if (value.stringValue != null) {
			return value.stringValue;
		}

		if (value.intValue != null) {
			return Std.string(value.intValue);
		}

		if (value.floatValue != null) {
			return Std.string(value.floatValue);
		}

		return "";
	}

	function skip_whitespace():Void {
		while (pos < length) {
			var c:String = text.charAt(pos);

			if (c == " " || c == "\n" || c == "\r" || c == "\t") {
				pos++;
			} else {
				break;
			}
		}
	}

	function peek():String {
		if (pos >= length) {
			return "";
		}

		return text.charAt(pos);
	}

	function expect(character:String):Void {
		if (pos >= length || text.charAt(pos) != character) {
			fatal("Expected '" + character + "'");
		}

		pos++;
	}

	function is_number_start(c:String):Bool {
		return (c >= "0" && c <= "9") || c == "-" || c == "+" || c == ".";
	}

	function fatal(message:String):Void {
		var where:String = sourcePath.length > 0 ? sourcePath : "unknown resource";

		Log.fatal(new EngineError("TSCN", "TscnValueParser", "parse", message + " in " + where + " at approx line " + lineNumber));
	}
}
