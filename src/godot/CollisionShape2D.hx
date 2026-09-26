package godot;

class CollisionShape2D extends Node2D {
	public var shape:Null<Shape2D>;

	public function new() {
		super();
		shape = null;
	}

	override public function set_property(name:String, value:godot.tscn.TscnValue, doc:godot.tscn.TscnDocument):Bool {
		if (name == "shape") {
			var resource:Null<Resource> = ResourceFactory.create_resource_from_value(value, doc);
			var shapeResource:Null<Shape2D> = Std.instance(resource, Shape2D);

			if (shapeResource != null) {
				shape = shapeResource;
				return true;
			}
		}

		return super.set_property(name, value, doc);
	}
}
