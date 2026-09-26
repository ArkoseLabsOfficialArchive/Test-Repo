package godot;

class BBCode {
	public static function to_html(text:String):String {
		var out:String = escape_html(text);

		out = StringTools.replace(out, "[b]", "<b>");
		out = StringTools.replace(out, "[/b]", "</b>");

		out = StringTools.replace(out, "[i]", "<i>");
		out = StringTools.replace(out, "[/i]", "</i>");

		out = StringTools.replace(out, "[u]", "<u>");
		out = StringTools.replace(out, "[/u]", "</u>");

		out = replace_color_tags(out);

		out = StringTools.replace(out, "\n", "<br>");

		return out;
	}

	static function escape_html(text:String):String {
		var out:String = text;

		out = StringTools.replace(out, "&", "&amp;");
		out = StringTools.replace(out, "<", "&lt;");
		out = StringTools.replace(out, ">", "&gt;");

		return out;
	}

	static function replace_color_tags(text:String):String {
		var out:String = text;
		var openTag:String = "[color=";

		while (true) {
			var startIndex:Int = out.indexOf(openTag);
			if (startIndex < 0) {
				break;
			}

			var valueStart:Int = startIndex + openTag.length;
			var endIndex:Int = out.indexOf("]", valueStart);

			if (endIndex < 0) {
				break;
			}

			var colorValue:String = out.substring(valueStart, endIndex);
			var tagLength:Int = endIndex - startIndex + 1;

			var replacement:String = "<font color=\"" + colorValue + "\">";
			out = out.substr(0, startIndex) + replacement + out.substr(startIndex + tagLength);
		}

		out = StringTools.replace(out, "[/color]", "</font>");

		return out;
	}
}
