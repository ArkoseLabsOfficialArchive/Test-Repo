package godot;

import godot.core.EngineError;
import godot.core.Log;

class NodeFactory {
	static var creators:Map<String, Void->Node> = null;

	public static function create(type:String):Node {
		ensure_registry();

		var creator:Null<Void->Node> = creators.get(type);
		if (creator == null) {
			Log.fatal(new EngineError("Scene", "NodeFactory", "create", "Unknown node type: " + type));
		}

		return creator();
	}

	static function ensure_registry():Void {
		if (creators != null) {
			return;
		}

		creators = new Map<String, Void->Node>();

		creators.set("Node", function():Node return new Node());
		creators.set("Viewport", function():Node return new Viewport());
		creators.set("CanvasItem", function():Node return new CanvasItem());
		creators.set("Node2D", function():Node return new Node2D());
		creators.set("Sprite", function():Node return new Sprite());
		creators.set("AnimatedSprite", function():Node return new AnimatedSprite());
		creators.set("Camera2D", function():Node return new Camera2D());
		creators.set("Position2D", function():Node return new Position2D());
		creators.set("TileMap", function():Node return new TileMap());
		creators.set("StaticBody2D", function():Node return new StaticBody2D());
		creators.set("KinematicBody2D", function():Node return new KinematicBody2D());
		creators.set("RigidBody2D", function():Node return new RigidBody2D());
		creators.set("Area2D", function():Node return new Area2D());
		creators.set("CollisionShape2D", function():Node return new CollisionShape2D());
		creators.set("CollisionPolygon2D", function():Node return new CollisionPolygon2D());
		creators.set("RayCast2D", function():Node return new RayCast2D());
		creators.set("YSort", function():Node return new YSort());
		creators.set("Path2D", function():Node return new Path2D());
		creators.set("PathFollow2D", function():Node return new PathFollow2D());
		creators.set("Particles2D", function():Node return new Particles2D());
		creators.set("CPUParticles2D", function():Node return new CPUParticles2D());
		creators.set("VisibilityNotifier2D", function():Node return new VisibilityNotifier2D());
		creators.set("Polygon2D", function():Node return new Polygon2D());
		creators.set("Line2D", function():Node return new Line2D());

		creators.set("Control", function():Node return new Control());
		creators.set("Label", function():Node return new Label());
		creators.set("TextureRect", function():Node return new TextureRect());
		creators.set("ColorRect", function():Node return new ColorRect());
		creators.set("Panel", function():Node return new Panel());
		creators.set("Button", function():Node return new Button());
		creators.set("TextureButton", function():Node return new TextureButton());
		creators.set("CheckBox", function():Node return new CheckBox());
		creators.set("CheckButton", function():Node return new CheckButton());
		creators.set("LineEdit", function():Node return new LineEdit());
		creators.set("TextEdit", function():Node return new TextEdit());
		creators.set("ProgressBar", function():Node return new ProgressBar());
		creators.set("HSlider", function():Node return new HSlider());
		creators.set("VSlider", function():Node return new VSlider());
		creators.set("HBoxContainer", function():Node return new HBoxContainer());
		creators.set("VBoxContainer", function():Node return new VBoxContainer());
		creators.set("GridContainer", function():Node return new GridContainer());

		creators.set("AudioStreamPlayer", function():Node return new AudioStreamPlayer());
		creators.set("AudioStreamPlayer2D", function():Node return new AudioStreamPlayer2D());
		creators.set("MarginContainer", function():Node return new MarginContainer());
		creators.set("CenterContainer", function():Node return new CenterContainer());
		creators.set("TextureButton", function():Node return new TextureButton());
        creators.set("NinePatchRect", function():Node return new NinePatchRect());
		creators.set("HSlider", function():Node return new HSlider());
		creators.set("VSlider", function():Node return new VSlider());
        creators.set("Light2D", function():Node return new Node());
	}
}
