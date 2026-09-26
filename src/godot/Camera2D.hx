package godot;

class Camera2D extends Node2D {
	public static var currentCamera:Null<Camera2D> = null;

	public var current:Bool;
	public var zoom:Vector2;
	public var offset:Vector2;

	public var limitLeft:Float;
	public var limitTop:Float;
	public var limitRight:Float;
	public var limitBottom:Float;

	public function new() {
		super();

		current = false;
		zoom = new Vector2(1, 1);
		offset = new Vector2(0, 0);

		limitLeft = -10000000.0;
		limitTop = -10000000.0;
		limitRight = 10000000.0;
		limitBottom = 10000000.0;
	}

	override public function _enter_tree():Void {
		super._enter_tree();

		if (current) {
			currentCamera = this;
		}
	}

	override public function _exit_tree():Void {
		super._exit_tree();

		if (currentCamera == this) {
			currentCamera = null;
		}
	}

	public function make_current():Void {
		current = true;
		currentCamera = this;
	}

	public function clear_current():Void {
		if (currentCamera == this) {
			current = false;
			currentCamera = null;
		}
	}

	public function get_camera_transform(viewportSize:Vector2):Transform2D {
		var globalPos:Vector2 = get_global_position();

		var centerX:Float = clamp(globalPos.x + offset.x, limitLeft + viewportSize.x * 0.5, limitRight - viewportSize.x * 0.5);
		var centerY:Float = clamp(globalPos.y + offset.y, limitTop + viewportSize.y * 0.5, limitBottom - viewportSize.y * 0.5);

		var scaleX:Float = 1.0 / zoom.x;
		var scaleY:Float = 1.0 / zoom.y;

		var translation:Vector2 = new Vector2(viewportSize.x * 0.5 - centerX * scaleX, viewportSize.y * 0.5 - centerY * scaleY);

		return new Transform2D(new Vector2(scaleX, 0.0), new Vector2(0.0, scaleY), translation);
	}

	public function get_viewport_world_rect(viewportSize:Vector2):Rect2 {
		var cameraTransform:Transform2D = get_camera_transform(viewportSize);
		var inverse:Transform2D = cameraTransform.affine_inverse();

		var p0:Vector2 = inverse.xform(new Vector2(0.0, 0.0));
		var p1:Vector2 = inverse.xform(new Vector2(viewportSize.x, 0.0));
		var p2:Vector2 = inverse.xform(new Vector2(0.0, viewportSize.y));
		var p3:Vector2 = inverse.xform(new Vector2(viewportSize.x, viewportSize.y));

		var minX:Float = Math.min(Math.min(p0.x, p1.x), Math.min(p2.x, p3.x));
		var minY:Float = Math.min(Math.min(p0.y, p1.y), Math.min(p2.y, p3.y));
		var maxX:Float = Math.max(Math.max(p0.x, p1.x), Math.max(p2.x, p3.x));
		var maxY:Float = Math.max(Math.max(p0.y, p1.y), Math.max(p2.y, p3.y));

		return Rect2.from_xywh(minX, minY, maxX - minX, maxY - minY);
	}

	function clamp(value:Float, min:Float, max:Float):Float {
		if (value < min)
			return min;
		if (value > max)
			return max;
		return value;
	}

	override public function set_property(name:String, value:godot.tscn.TscnValue, doc:godot.tscn.TscnDocument):Bool {
		switch (name) {
			case "current":
				if (value.boolValue != null) {
					current = value.boolValue;
					if (current) {
						currentCamera = this;
					}
					return true;
				}

			case "zoom":
				if (value.vector2Value != null) {
					zoom = value.vector2Value;
					return true;
				}

			case "offset":
				if (value.vector2Value != null) {
					offset = value.vector2Value;
					return true;
				}

			case "limit_left":
				if (value.floatValue != null) {
					limitLeft = value.floatValue;
					return true;
				}

			case "limit_top":
				if (value.floatValue != null) {
					limitTop = value.floatValue;
					return true;
				}

			case "limit_right":
				if (value.floatValue != null) {
					limitRight = value.floatValue;
					return true;
				}

			case "limit_bottom":
				if (value.floatValue != null) {
					limitBottom = value.floatValue;
					return true;
				}
		}

		return super.set_property(name, value, doc);
	}
}
