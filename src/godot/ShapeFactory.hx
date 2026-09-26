package godot;

import godot.tscn.TscnSubResource;
import godot.tscn.TscnValue;

class ShapeFactory {
	public static function create(sub:TscnSubResource):Null<Shape2D> {
		switch (sub.type) {
			case "RectangleShape2D":
				var sizeValue:Null<TscnValue> = sub.properties.get("size");
				var size:Vector2 = new Vector2(10, 10);
				if (sizeValue != null && sizeValue.vector2Value != null) {
					size = sizeValue.vector2Value;
				}
				return new RectangleShape2D(size);

			case "CircleShape2D":
				var radiusValue:Null<TscnValue> = sub.properties.get("radius");
				var radius:Float = 10.0;
				if (radiusValue != null && radiusValue.floatValue != null) {
					radius = radiusValue.floatValue;
				}
				return new CircleShape2D(radius);

			default:
				return null;
		}
	}
}
