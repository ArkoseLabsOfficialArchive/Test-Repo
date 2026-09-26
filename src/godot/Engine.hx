package godot;

import godot.rendering.openfl.Renderer;

class Engine {
	public static var mainSceneTree:Null<SceneTree> = null;
	public static var renderer:Null<Renderer> = null;

	public static var physicsHz:Int = 60;
	public static var physicsAccumulator:Float = 0.0;

	public static function initialize(openflStage:openfl.display.Stage):Void {
		ProjectSettings.initialize();
		InputMap.initialize_from_project_settings();

		mainSceneTree = new SceneTree();
		renderer = new Renderer();
		VisualServer.instance = renderer;

		var width:Int = ProjectSettings.get_int("display/window/size/width", 1280);
		var height:Int = ProjectSettings.get_int("display/window/size/height", 720);

		mainSceneTree.root.size = new Vector2(width, height);

		openflStage.addEventListener(openfl.events.Event.ENTER_FRAME, on_frame);
		openflStage.addEventListener(openfl.events.KeyboardEvent.KEY_DOWN, on_key_down);
		openflStage.addEventListener(openfl.events.KeyboardEvent.KEY_UP, on_key_up);
		openflStage.addEventListener(openfl.events.MouseEvent.MOUSE_DOWN, on_mouse_down);
		openflStage.addEventListener(openfl.events.MouseEvent.MOUSE_UP, on_mouse_up);
		openflStage.addEventListener(openfl.events.MouseEvent.MOUSE_MOVE, on_mouse_move);

		openflStage.addChild(renderer.rootSprite);
	}

	public static function load_main_scene(path:String):Void {
		var res:Resource = ResourceLoader.load(path, "PackedScene");
		var scene:Null<PackedScene> = Std.instance(res, PackedScene);

		if (scene != null && mainSceneTree != null) {
			mainSceneTree.change_scene_to(scene);
		}
	}

	static function on_frame(event:openfl.events.Event):Void {
		var delta:Float = 1.0 / openfl.Lib.current.stage.frameRate;

		EngineTime.update(delta);

		if (mainSceneTree == null) {
			return;
		}

		physicsAccumulator += delta;
		var physicsStep:Float = 1.0 / physicsHz;

		while (physicsAccumulator >= physicsStep) {
			EngineTime.physics_delta = physicsStep;
			mainSceneTree._physics_process(physicsStep);
			physicsAccumulator -= physicsStep;
		}

		mainSceneTree._process(delta);
		mainSceneTree.update_layout();

		if (renderer != null) {
			renderer.synchronize();
		}

		Input.instance.end_frame();
	}

	static function on_key_down(event:openfl.events.KeyboardEvent):Void {
		var keyEvent:InputEventKey = new InputEventKey(event.keyCode, true, false, Std.int(event.charCode));

		Input.instance.parse_event(keyEvent);

		if (mainSceneTree != null) {
			mainSceneTree.dispatch_input(keyEvent);
		}
	}

	static function on_key_up(event:openfl.events.KeyboardEvent):Void {
		var keyEvent:InputEventKey = new InputEventKey(event.keyCode, false, false, 0);

		Input.instance.parse_event(keyEvent);

		if (mainSceneTree != null) {
			mainSceneTree.dispatch_input(keyEvent);
		}
	}

	static function on_mouse_down(event:openfl.events.MouseEvent):Void {
		var mouseEvent:InputEventMouseButton = new InputEventMouseButton(1, true);
		mouseEvent.position = new Vector2(event.stageX, event.stageY);

		Input.instance.parse_event(mouseEvent);

		if (mainSceneTree != null) {
			mainSceneTree.dispatch_input(mouseEvent);
		}
	}

	static function on_mouse_up(event:openfl.events.MouseEvent):Void {
		var mouseEvent:InputEventMouseButton = new InputEventMouseButton(1, false);
		mouseEvent.position = new Vector2(event.stageX, event.stageY);

		Input.instance.parse_event(mouseEvent);

		if (mainSceneTree != null) {
			mainSceneTree.dispatch_input(mouseEvent);
		}
	}

	static function on_mouse_move(event:openfl.events.MouseEvent):Void {
		var motion:InputEventMouseMotion = new InputEventMouseMotion();
		motion.position = new Vector2(event.stageX, event.stageY);

		Input.instance.parse_event(motion);

		if (mainSceneTree != null) {
			mainSceneTree.dispatch_input(motion);
		}
	}
}
