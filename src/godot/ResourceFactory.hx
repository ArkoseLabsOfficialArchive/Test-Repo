package godot;

import godot.core.EngineError;
import godot.core.Log;
import godot.tscn.TscnExternalResource;
import godot.tscn.TscnSubResource;
import godot.tscn.TscnValue;
import godot.tres.TresDocument;
import godot.tres.TresHeader;

typedef ResourceDocument = {
	function get_ext_resource(id:String):Null<TscnExternalResource>;
	function get_sub_resource(id:String):Null<TscnSubResource>;
}

class ResourceFactory {
	public static function create_resource_from_value(value:Null<TscnValue>, doc:ResourceDocument):Null<Resource> {
		if (value == null) {
			return null;
		}

		if (value.type == TscnValueType.TExtResource && value.resourceRef != null) {
			var ext:Null<TscnExternalResource> = doc.get_ext_resource(value.resourceRef);
			if (ext == null) {
				Log.fatal(new EngineError("Resource", "ResourceFactory", "create_resource_from_value", "Missing ext_resource id: " + value.resourceRef));
			}

			return ResourceLoader.load(ext.path, ext.type);
		}

		if (value.type == TscnValueType.TSubResource && value.resourceRef != null) {
			var sub:Null<TscnSubResource> = doc.get_sub_resource(value.resourceRef);
			if (sub == null) {
				Log.fatal(new EngineError("Resource", "ResourceFactory", "create_resource_from_value", "Missing sub_resource id: " + value.resourceRef));
			}

			return create_sub_resource(sub, doc);
		}

		return null;
	}

	public static function create_sub_resource(sub:TscnSubResource, doc:ResourceDocument):Resource {
		switch (sub.type) {
			case "RectangleShape2D":
				return create_rectangle_shape(sub);

			case "CircleShape2D":
				return create_circle_shape(sub);

			case "CapsuleShape2D":
				return create_capsule_shape(sub);

			case "AtlasTexture":
				return create_atlas_texture(sub, doc);

			case "SpriteFrames":
				return create_sprite_frames_from_animations_value(sub.properties.get("animations"), doc);

			case "Gradient":
				return create_gradient_from_props(sub.properties);

			case "Curve":
				return create_curve_from_props(sub.properties);

			case "ImageTexture":
				return create_image_texture_from_props(sub.properties);

			case "StreamTexture":
				return create_stream_texture_from_props(sub.properties);

			case "GradientTexture":
				return create_gradient_texture_from_props(sub.properties, doc);

			case "GradientTexture2D":
				return create_gradient_texture_2d_from_props(sub.properties, doc);

			case "CurveTexture":
				return create_curve_texture_from_props(sub.properties, doc);

			case "AnimatedTexture":
				return create_animated_texture_from_props(sub.properties, doc);

			case "Theme":
				return create_theme_from_props(sub.properties, doc);

			case "DynamicFont":
				return create_dynamic_font_from_props(sub.properties, doc);

			case "StyleBoxFlat":
				return create_style_box_flat_from_props(sub.properties);

			default:
				Log.fatal(new EngineError("Resource", "ResourceFactory", "create_sub_resource", "Unsupported sub_resource type: " + sub.type));
		}

		return new Resource();
	}

	static function create_theme_from_props(props:Map<String, TscnValue>, doc:ResourceDocument):Theme {
		var theme:Theme = Theme.create_default();

		var fontSizeValue:Null<TscnValue> = props.get("default_font_size");
		if (fontSizeValue != null) {
			if (fontSizeValue.intValue != null) {
				theme.defaultFontSize = fontSizeValue.intValue;
			} else if (fontSizeValue.floatValue != null) {
				theme.defaultFontSize = Math.round(fontSizeValue.floatValue);
			}
		}

		var fontValue:Null<TscnValue> = props.get("default_font");
		var fontResource:Null<Resource> = create_resource_from_value(fontValue, doc);
		var font:Null<Font> = Std.instance(fontResource, Font);

		if (font != null) {
			theme.defaultFont = font;
		}

		var colorsValue:Null<TscnValue> = props.get("colors");
		if (colorsValue != null && colorsValue.dictionaryValue != null) {
			for (key in colorsValue.dictionaryValue.keys()) {
				var colorValue:Null<TscnValue> = colorsValue.dictionaryValue.get(key);
				if (colorValue != null && colorValue.colorValue != null) {
					theme.set_color(key, colorValue.colorValue);
				}
			}
		}

		for (key in props.keys()) {
			var value:Null<TscnValue> = props.get(key);
			if (value != null && value.colorValue != null) {
				theme.set_color(key, value.colorValue);
			}
		}

		return theme;
	}

	static function create_gradient_from_props(props:Map<String, TscnValue>):Gradient {
		var gradient:Gradient = new Gradient();

		var offsetsValue:Null<TscnValue> = props.get("offsets");
		var colorsValue:Null<TscnValue> = props.get("colors");

		var offsets:Array<Float> = get_float_array_from_value(offsetsValue);
		var colors:Array<Color> = get_color_array_from_value(colorsValue);

		if (offsets.length > 0 && colors.length > 0) {
			gradient.set_data(offsets, colors);
		}

		return gradient;
	}

	static function create_curve_from_props(props:Map<String, TscnValue>):Curve {
		var curve:Curve = new Curve();

		var pointsValue:Null<TscnValue> = props.get("points");
		if (pointsValue == null) {
			return curve;
		}

		if (pointsValue.poolVector2ArrayValue != null) {
			curve.set_points(pointsValue.poolVector2ArrayValue);
		} else if (pointsValue.arrayValue != null) {
			var points:Array<Vector2> = [];

			for (entry in pointsValue.arrayValue) {
				if (entry.vector2Value != null) {
					points.push(entry.vector2Value);
				}
			}

			curve.set_points(points);
		}

		return curve;
	}

	static function create_image_texture_from_props(props:Map<String, TscnValue>):ImageTexture {
		var texture:ImageTexture = new ImageTexture();

		var width:Int = get_int_from_value(props.get("width"), 16);
		var height:Int = get_int_from_value(props.get("height"), 16);
		var color:Color = get_color_from_value(props.get("color"), Color.white());

		texture.create(width, height, color);

		return texture;
	}

	static function create_stream_texture_from_props(props:Map<String, TscnValue>):Resource {
		var pathValue:Null<TscnValue> = props.get("path");

		if (pathValue == null || pathValue.stringValue == null) {
			Log.fatal(new EngineError("Resource", "ResourceFactory", "create_stream_texture_from_props", "StreamTexture subresource has no path"));
		}

		return ResourceLoader.load(pathValue.stringValue, "Texture");
	}

	static function create_gradient_texture_from_props(props:Map<String, TscnValue>, doc:ResourceDocument):GradientTexture {
		var texture:GradientTexture = new GradientTexture();

		var widthValue:Null<TscnValue> = props.get("width");
		texture.resolution = get_int_from_value(widthValue, 256);

		var gradientResource:Null<Resource> = create_resource_from_value(props.get("gradient"), doc);
		var gradient:Null<Gradient> = Std.instance(gradientResource, Gradient);

		if (gradient != null) {
			texture.gradient = gradient;
		}

		texture.mark_dirty();

		return texture;
	}

	static function create_gradient_texture_2d_from_props(props:Map<String, TscnValue>, doc:ResourceDocument):GradientTexture2D {
		var texture:GradientTexture2D = new GradientTexture2D();

		texture.width = get_int_from_value(props.get("width"), 256);
		texture.height = get_int_from_value(props.get("height"), 256);

		var fromValue:Null<TscnValue> = props.get("fill_from");
		var toValue:Null<TscnValue> = props.get("fill_to");

		if (fromValue != null && fromValue.vector2Value != null) {
			texture.fillFrom = fromValue.vector2Value;
		}

		if (toValue != null && toValue.vector2Value != null) {
			texture.fillTo = toValue.vector2Value;
		}

		var gradientResource:Null<Resource> = create_resource_from_value(props.get("gradient"), doc);
		var gradient:Null<Gradient> = Std.instance(gradientResource, Gradient);

		if (gradient != null) {
			texture.gradient = gradient;
		}

		texture.mark_dirty();

		return texture;
	}

	static function create_curve_texture_from_props(props:Map<String, TscnValue>, doc:ResourceDocument):CurveTexture {
		var texture:CurveTexture = new CurveTexture();

		texture.resolution = get_int_from_value(props.get("width"), 256);

		var curveResource:Null<Resource> = create_resource_from_value(props.get("curve"), doc);
		var curve:Null<Curve> = Std.instance(curveResource, Curve);

		if (curve != null) {
			texture.curve = curve;
		}

		texture.mark_dirty();

		return texture;
	}

	static function create_animated_texture_from_props(props:Map<String, TscnValue>, doc:ResourceDocument):AnimatedTexture {
		var texture:AnimatedTexture = new AnimatedTexture();

		var fpsValue:Null<TscnValue> = props.get("fps");
		if (fpsValue != null && fpsValue.floatValue != null) {
			texture.fps = fpsValue.floatValue;
		}

		var framesCountValue:Null<TscnValue> = props.get("frames");
		var framesCount:Int = 0;
		if (framesCountValue != null && framesCountValue.intValue != null) {
			framesCount = framesCountValue.intValue;
		}

		// Godot 3 stores frames as frame_X/texture and frame_X/delay_sec
		for (i in 0...framesCount) {
			var texValue:Null<TscnValue> = props.get("frame_" + i + "/texture");
			var delayValue:Null<TscnValue> = props.get("frame_" + i + "/delay_sec");

			var frameTexture:Null<Texture> = null;
			if (texValue != null) {
				var res:Null<Resource> = create_resource_from_value(texValue, doc);
				frameTexture = Std.instance(res, Texture);
			}

			var delay:Float = 1.0;
			if (delayValue != null && delayValue.floatValue != null) {
				delay = delayValue.floatValue;
			} else if (texture.fps > 0) {
				delay = 1.0 / texture.fps;
			}

			texture.add_frame(frameTexture, delay);
		}

		return texture;
	}

	static function create_dynamic_font_from_props(props:Map<String, TscnValue>, doc:ResourceDocument):DynamicFont {
		var font:DynamicFont = new DynamicFont();

		var fontDataValue:Null<TscnValue> = props.get("font_data");
		if (fontDataValue != null) {
			var resource:Null<Resource> = create_resource_from_value(fontDataValue, doc);
			var data:Null<DynamicFontData> = Std.instance(resource, DynamicFontData);

			if (data != null) {
				font.fontData = data;
				font.load_from_file(data.fontPath);
			}
		}

		var sizeValue:Null<TscnValue> = props.get("size");
		if (sizeValue != null) {
			if (sizeValue.intValue != null)
				font.size = sizeValue.intValue;
			else if (sizeValue.floatValue != null)
				font.size = Math.round(sizeValue.floatValue);
		}

		var outlineSizeValue:Null<TscnValue> = props.get("outline_size");
		if (outlineSizeValue != null) {
			if (outlineSizeValue.intValue != null)
				font.outlineSize = outlineSizeValue.intValue;
			else if (outlineSizeValue.floatValue != null)
				font.outlineSize = Math.round(outlineSizeValue.floatValue);
		}

		var outlineColorValue:Null<TscnValue> = props.get("outline_color");
		if (outlineColorValue != null && outlineColorValue.colorValue != null) {
			font.outlineColor = outlineColorValue.colorValue;
		}

		font.defaultFontSize = font.size;
		return font;
	}

	static function get_int_from_value(value:Null<TscnValue>, fallback:Int):Int {
		if (value == null) {
			return fallback;
		}

		if (value.intValue != null) {
			return value.intValue;
		}

		if (value.floatValue != null) {
			return Math.round(value.floatValue);
		}

		return fallback;
	}

	static function get_float_from_value(value:Null<TscnValue>, fallback:Float):Float {
		if (value == null) {
			return fallback;
		}

		if (value.floatValue != null) {
			return value.floatValue;
		}

		if (value.intValue != null) {
			return value.intValue;
		}

		return fallback;
	}

	static function get_bool_from_value(value:Null<TscnValue>, fallback:Bool):Bool {
		if (value == null || value.boolValue == null) {
			return fallback;
		}

		return value.boolValue;
	}

	static function get_color_from_value(value:Null<TscnValue>, fallback:Color):Color {
		if (value == null || value.colorValue == null) {
			return fallback;
		}

		return value.colorValue;
	}

	static function get_float_array_from_value(value:Null<TscnValue>):Array<Float> {
		if (value == null) {
			return [];
		}

		if (value.poolRealArrayValue != null) {
			return value.poolRealArrayValue;
		}

		if (value.arrayValue != null) {
			var out:Array<Float> = [];

			for (entry in value.arrayValue) {
				if (entry.floatValue != null) {
					out.push(entry.floatValue);
				} else if (entry.intValue != null) {
					out.push(entry.intValue);
				}
			}

			return out;
		}

		return [];
	}

	static function get_color_array_from_value(value:Null<TscnValue>):Array<Color> {
		if (value == null) {
			return [];
		}

		if (value.poolColorArrayValue != null) {
			return value.poolColorArrayValue;
		}

		if (value.arrayValue != null) {
			var out:Array<Color> = [];

			for (entry in value.arrayValue) {
				if (entry.colorValue != null) {
					out.push(entry.colorValue);
				}
			}

			return out;
		}

		return [];
	}

	public static function create_tres_resource(doc:TresDocument):Resource {
		if (doc.header == null) {
			Log.fatal(new EngineError("Resource", "ResourceFactory", "create_tres_resource", "TresDocument has no header"));
		}

		var header:TresHeader = doc.header;

		switch (header.type) {
			case "TileSet":
				return create_tile_set_from_tres(doc);

			case "SpriteFrames":
				return create_sprite_frames_from_animations_value(doc.properties.get("animations"), doc);

			case "Gradient":
				return create_gradient_from_props(doc.properties);

			case "Curve":
				return create_curve_from_props(doc.properties);

			case "ImageTexture":
				return create_image_texture_from_props(doc.properties);

			case "StreamTexture":
				return create_stream_texture_from_props(doc.properties);

			case "GradientTexture":
				return create_gradient_texture_from_props(doc.properties, doc);

			case "GradientTexture2D":
				return create_gradient_texture_2d_from_props(doc.properties, doc);

			case "CurveTexture":
				return create_curve_texture_from_props(doc.properties, doc);

			case "AnimatedTexture":
				return create_animated_texture_from_props(doc.properties, doc);

			case "Theme":
				return create_theme_from_props(doc.properties, doc);

			case "DynamicFont":
				return create_dynamic_font_from_props(doc.properties, doc);

			case "StyleBoxFlat":
				return create_style_box_flat_from_props(doc.properties);

			default:
				Log.fatal(new EngineError("Resource", "ResourceFactory", "create_tres_resource", "Unsupported .tres resource type: " + header.type));
		}

		return new Resource();
	}

	static function create_style_box_flat_from_props(props:Map<String, TscnValue>):StyleBoxFlat {
		var style:StyleBoxFlat = new StyleBoxFlat();

		var bgColorValue:Null<TscnValue> = props.get("bg_color");
		if (bgColorValue != null && bgColorValue.colorValue != null) {
			style.bgColor = bgColorValue.colorValue;
		}

		var borderColorValue:Null<TscnValue> = props.get("border_color");
		if (borderColorValue != null && borderColorValue.colorValue != null) {
			style.borderColor = borderColorValue.colorValue;
		}

		var borderWidthValue:Null<TscnValue> = props.get("border_width_left");
		if (borderWidthValue != null) {
			if (borderWidthValue.floatValue != null) {
				style.borderWidth = borderWidthValue.floatValue;
			} else if (borderWidthValue.intValue != null) {
				style.borderWidth = borderWidthValue.intValue;
			}
		}

		var cornerRadiusValue:Null<TscnValue> = props.get("corner_radius_top_left");
		if (cornerRadiusValue != null) {
			if (cornerRadiusValue.floatValue != null) {
				style.cornerRadius = cornerRadiusValue.floatValue;
			} else if (cornerRadiusValue.intValue != null) {
				style.cornerRadius = cornerRadiusValue.intValue;
			}
		}

		return style;
	}

	static function create_rectangle_shape(sub:TscnSubResource):RectangleShape2D {
		var sizeValue:Null<TscnValue> = sub.properties.get("size");
		var size:Vector2 = new Vector2(10, 10);

		if (sizeValue != null && sizeValue.vector2Value != null) {
			size = sizeValue.vector2Value;
		}

		return new RectangleShape2D(size);
	}

	static function create_circle_shape(sub:TscnSubResource):CircleShape2D {
		var radiusValue:Null<TscnValue> = sub.properties.get("radius");
		var radius:Float = 10.0;

		if (radiusValue != null && radiusValue.floatValue != null) {
			radius = radiusValue.floatValue;
		}

		return new CircleShape2D(radius);
	}

	static function create_capsule_shape(sub:TscnSubResource):CapsuleShape2D {
		var radiusValue:Null<TscnValue> = sub.properties.get("radius");
		var heightValue:Null<TscnValue> = sub.properties.get("height");

		var radius:Float = 10.0;
		var height:Float = 20.0;

		if (radiusValue != null && radiusValue.floatValue != null) {
			radius = radiusValue.floatValue;
		}

		if (heightValue != null && heightValue.floatValue != null) {
			height = heightValue.floatValue;
		}

		return new CapsuleShape2D(radius, height);
	}

	static function create_atlas_texture(sub:TscnSubResource, doc:ResourceDocument):AtlasTexture {
		var atlasValue:Null<TscnValue> = sub.properties.get("atlas");
		var regionValue:Null<TscnValue> = sub.properties.get("region");

		var atlasResource:Null<Resource> = create_resource_from_value(atlasValue, doc);
		var atlasTexture:Null<Texture> = Std.instance(atlasResource, Texture);

		if (atlasTexture == null) {
			Log.fatal(new EngineError("Resource", "ResourceFactory", "create_atlas_texture", "AtlasTexture has no valid atlas texture"));
		}

		var region:Rect2 = Rect2.from_xywh(0, 0, 0, 0);

		if (regionValue != null && regionValue.rect2Value != null) {
			region = regionValue.rect2Value;
		}

		var atlas:AtlasTexture = new AtlasTexture();
		atlas.setup(atlasTexture, region);

		return atlas;
	}

	static function create_sprite_frames_from_animations_value(animationsValue:Null<TscnValue>, doc:ResourceDocument):SpriteFrames {
		var frames:SpriteFrames = new SpriteFrames();

		if (animationsValue == null || animationsValue.arrayValue == null) {
			return frames;
		}

		for (entryValue in animationsValue.arrayValue) {
			if (entryValue.dictionaryValue == null) {
				continue;
			}

			var dict:Map<String, TscnValue> = entryValue.dictionaryValue;

			var nameValue:Null<TscnValue> = dict.get("name");
			var speedValue:Null<TscnValue> = dict.get("speed");
			var loopValue:Null<TscnValue> = dict.get("loop");
			var framesValue:Null<TscnValue> = dict.get("frames");

			var animationName:String = "default";
			if (nameValue != null && nameValue.stringValue != null) {
				animationName = nameValue.stringValue;
			}

			var speed:Float = 5.0;
			if (speedValue != null && speedValue.floatValue != null) {
				speed = speedValue.floatValue;
			}

			var loop:Bool = true;
			if (loopValue != null && loopValue.boolValue != null) {
				loop = loopValue.boolValue;
			}

			frames.add_animation(animationName, speed, loop);

			if (framesValue != null && framesValue.arrayValue != null) {
				for (frameValue in framesValue.arrayValue) {
					var frameResource:Null<Resource> = create_resource_from_value(frameValue, doc);
					var frameTexture:Null<Texture> = Std.instance(frameResource, Texture);

					if (frameTexture != null) {
						frames.add_frame(animationName, frameTexture);
					}
				}
			}
		}

		return frames;
	}

	static function create_tile_set_from_tres(doc:TresDocument):TileSet {
		var tileSet:TileSet = new TileSet();
		tileSet.cellSize = new Vector2(32, 32);

		var ids:Map<Int, Bool> = new Map<Int, Bool>();

		for (key in doc.properties.keys()) {
			var parts:Array<String> = key.split("/");
			if (parts.length < 2)
				continue;

			var idValue:Null<Int> = Std.parseInt(parts[0]);
			if (idValue != null) {
				ids.set(idValue, true);
			}
		}

		for (id in ids.keys()) {
			var nameValue:Null<TscnValue> = doc.properties.get(id + "/name");
			var textureValue:Null<TscnValue> = doc.properties.get(id + "/texture");
			var regionValue:Null<TscnValue> = doc.properties.get(id + "/region");
			var texOffsetValue:Null<TscnValue> = doc.properties.get(id + "/tex_offset");
			var shapesValue:Null<TscnValue> = doc.properties.get(id + "/shapes");
			var shapeValue:Null<TscnValue> = doc.properties.get(id + "/shape");

			var tileModeValue:Null<TscnValue> = doc.properties.get(id + "/tile_mode");
			var tileSizeValue:Null<TscnValue> = doc.properties.get(id + "/autotile/tile_size");

			var textureResource:Null<Resource> = create_resource_from_value(textureValue, doc);
			var texture:Null<Texture> = Std.instance(textureResource, Texture);

			if (texture == null) {
				var tileName:String = nameValue != null && nameValue.stringValue != null ? nameValue.stringValue : "";
				Log.warning("Resource", "TileSet tile " + id + " ('" + tileName + "') has no valid texture and was skipped");
				continue;
			}

			var region:Rect2;
			if (regionValue != null && regionValue.rect2Value != null) {
				region = regionValue.rect2Value;
			} else {
				region = Rect2.from_xywh(0, 0, texture.width, texture.height);
			}

			var offset:Vector2 = new Vector2(0, 0);
			if (texOffsetValue != null && texOffsetValue.vector2Value != null) {
				offset = texOffsetValue.vector2Value;
			}

			var collides:Bool = false;
			if (shapesValue != null && shapesValue.arrayValue != null && shapesValue.arrayValue.length > 0) {
				collides = true;
			} else if (shapeValue != null && shapeValue.type != TscnValueType.TNull) {
				collides = true;
			}

			var tileMode:Int = 0;
			if (tileModeValue != null && tileModeValue.intValue != null) {
				tileMode = tileModeValue.intValue;
			}

			var autotileTileSize:Vector2 = new Vector2(32, 32);
			if (tileSizeValue != null && tileSizeValue.vector2Value != null) {
				autotileTileSize = tileSizeValue.vector2Value;
			}

			tileSet.create_tile(id, texture, region, offset, collides, tileMode, autotileTileSize);
		}

		return tileSet;
	}
}
