package godot;

import godot.core.EngineError;
import godot.core.Log;
import godot.tscn.TscnParser;
import godot.tscn.TscnDocument;
import godot.tres.TresParser;
import godot.tres.TresDocument;

class ResourceLoader {
	public static var projectRoot:String = "assets";

	public static function load(path:String, expectedType:String = "Resource", ?consumer:String):Resource {
		var normalized:String = ResourcePath.normalize(path);

		var cached:Null<Resource> = ResourceCache.get(normalized);
		if (cached != null) {
			return cached;
		}

		var extension:String = ResourcePath.get_extension(normalized);

		var result:Null<Resource> = null;

		switch (extension) {
			case "tscn":
				result = load_scene(normalized);

			case "tres":
				result = load_tres(normalized);

			case "png", "jpg", "jpeg":
				result = load_texture(normalized);

			case "ogg", "mp3", "wav":
				result = load_audio(normalized);

			case "ttf", "otf":
				result = load_font_data(normalized);

			default:
				Log.fatal(new EngineError("Resource", "ResourceLoader", "load", "Unsupported resource extension: " + extension, null, normalized, null));
		}

		if (result == null) {
			Log.fatal(new EngineError("Resource", "ResourceLoader", "load", "Failed to load resource", null, normalized, null));
		}

		var finalResult:Resource = result;
		finalResult.loaded = true;
		ResourceCache.put(normalized, finalResult);

		return finalResult;
	}

	static function load_scene(path:String):PackedScene {
		var systemPath:String = ResourcePath.to_system_path(path, projectRoot);
		var text:String = sys.io.File.getContent(systemPath);

		var parser:TscnParser = new TscnParser();
		var doc:TscnDocument = parser.parse(text, path);

		var scene:PackedScene = new PackedScene();
		scene.build_from_document(doc);
		scene.set_path(path);

		return scene;
	}

	static function load_font_data(path:String):DynamicFontData {
		var data:DynamicFontData = new DynamicFontData();
		data.fontPath = ResourcePath.to_system_path(path, projectRoot);
		data.set_path(path);
		return data;
	}

	static function load_tres(path:String):Resource {
		var systemPath:String = ResourcePath.to_system_path(path, projectRoot);
		var text:String = sys.io.File.getContent(systemPath);

		var parser:TresParser = new TresParser();
		var doc:TresDocument = parser.parse(text);

		var resource:Resource = ResourceFactory.create_tres_resource(doc);
		resource.set_path(path);

		return resource;
	}

	static function load_texture(path:String):StreamTexture {
		var systemPath:String = ResourcePath.to_system_path(path, projectRoot);

		var tex:StreamTexture = new StreamTexture();
		tex.load_from_file(systemPath);
		tex.set_path(path);

		return tex;
	}

	static function load_audio(path:String):AudioStream {
		var extension:String = ResourcePath.get_extension(path);
		var systemPath:String = ResourcePath.to_system_path(path, projectRoot);

		var stream:AudioStream = switch (extension) {
			case "ogg": new AudioStreamOGGVorbis();
			case "mp3": new AudioStreamMP3();
			default: new AudioStream();
		}

		stream.load_from_file(systemPath);
		stream.set_path(path);

		return stream;
	}

	static function load_font(path:String):DynamicFont {
		var font:DynamicFont = new DynamicFont();
		font.load_from_file(ResourcePath.to_system_path(path, projectRoot));
		font.set_path(path);

		return font;
	}
}
