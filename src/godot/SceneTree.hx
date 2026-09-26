package godot;

import godot.core.EngineError;
import godot.core.Log;

class SceneTree extends MainLoop {
	public var root:Viewport;
	public var currentScene:Null<Node>;

	public var frameCount:Int;
	public var physicsFrameCount:Int;

	public var guiState:ControlGuiState;

	var allNodes:Array<Node>;
	var processNodes:Array<Node>;
	var physicsProcessNodes:Array<Node>;
	var deletionQueue:Array<Node>;

	public function new() {
		super();

		root = new Viewport();
		root.name = "Root";
		root.tree = this;
		root.isInsideTree = true;

		currentScene = null;
		frameCount = 0;
		physicsFrameCount = 0;
		guiState = new ControlGuiState();

		allNodes = [];
		processNodes = [];
		physicsProcessNodes = [];
		deletionQueue = [];
	}

	public function register_node(node:Node):Void {
		allNodes.push(node);

		if (node.processEnabled) {
			add_process_node(node);
		}

		if (node.physicsProcessEnabled) {
			add_physics_process_node(node);
		}
	}

	public function unregister_node(node:Node):Void {
		allNodes.remove(node);
		processNodes.remove(node);
		physicsProcessNodes.remove(node);

		if (guiState.hovered == node)
			guiState.hovered = null;
		if (guiState.pressed == node)
			guiState.pressed = null;
		if (guiState.focused == node)
			guiState.focused = null;
	}

	public function add_process_node(node:Node):Void {
		if (processNodes.indexOf(node) < 0) {
			processNodes.push(node);
		}
	}

	public function remove_process_node(node:Node):Void {
		processNodes.remove(node);
	}

	public function add_physics_process_node(node:Node):Void {
		if (physicsProcessNodes.indexOf(node) < 0) {
			physicsProcessNodes.push(node);
		}
	}

	public function remove_physics_process_node(node:Node):Void {
		physicsProcessNodes.remove(node);
	}

	public function queue_delete(node:Node):Void {
		if (deletionQueue.indexOf(node) < 0) {
			deletionQueue.push(node);
		}
	}

	public function change_scene_to(scene:PackedScene):Void {
		if (currentScene != null) {
			root.remove_child(currentScene);
			currentScene.free();
			currentScene = null;
		}

		guiState.clear();

		var instance:Node = scene.instance();
		currentScene = instance;
		root.add_child(instance);
	}

	public function dispatch_input(event:InputEvent):Void {
		for (node in allNodes) {
			if (!node.inputEnabled || !node.isInsideTree || node.isQueuedForDeletion) {
				continue;
			}

			node._input(event);

			if (event.handled) {
				return;
			}
		}

		process_gui_input(event);

		if (event.handled) {
			return;
		}

		for (node in allNodes) {
			if (!node.unhandledInputEnabled || !node.isInsideTree || node.isQueuedForDeletion) {
				continue;
			}

			node._unhandled_input(event);

			if (event.handled) {
				return;
			}
		}
	}

	public function process_gui_input(event:InputEvent):Void {
		var mouseMotion:Null<InputEventMouseMotion> = event.as_mouse_motion();
		if (mouseMotion != null) {
			update_gui_hover(mouseMotion.position);

			var target:Null<Control> = guiState.pressed != null ? guiState.pressed : guiState.hovered;
			if (target != null && target.visible && !target.isQueuedForDeletion) {
				target.gui_input(event);
			}

			return;
		}

		var mouseButton:Null<InputEventMouseButton> = event.as_mouse_button();
		if (mouseButton != null) {
			update_gui_hover(mouseButton.position);

			if (mouseButton.pressed) {
				var target:Null<Control> = find_control_at(root, mouseButton.position);
				if (target != null) {
					if (target.focusMode != FocusMode.None) {
						guiState.focused = target;
					}

					guiState.pressed = target;
					target.gui_input(event);
				}
			} else {
				if (guiState.pressed != null) {
					guiState.pressed.gui_input(event);
					guiState.pressed = null;
				} else {
					var releasedTarget:Null<Control> = find_control_at(root, mouseButton.position);
					if (releasedTarget != null) {
						releasedTarget.gui_input(event);
					}
				}
			}

			return;
		}

		var key:Null<InputEventKey> = event.as_key();
		if (key != null) {
			if (guiState.focused != null) {
				guiState.focused.gui_input(event);
			}
			return;
		}
	}

	function update_gui_hover(position:Vector2):Void {
		var target:Null<Control> = find_control_at(root, position);

		if (guiState.hovered != target) {
			var oldButton:Null<Button> = Std.instance(guiState.hovered, Button);
			if (oldButton != null) {
				oldButton.hovered = false;
			}

			var newButton:Null<Button> = Std.instance(target, Button);
			if (newButton != null) {
				newButton.hovered = true;
			}

			guiState.hovered = target;
		}
	}

	function find_control_at(node:Node, point:Vector2):Null<Control> {
		var children:Array<Node> = node.get_children();

		var i:Int = children.length - 1;
		while (i >= 0) {
			var found:Null<Control> = find_control_at(children[i], point);
			if (found != null) {
				return found;
			}
			i--;
		}

		var control:Null<Control> = Std.instance(node, Control);
		if (control != null
			&& control.visible
			&& !control.isQueuedForDeletion
			&& control.mouseFilter != MouseFilter.Ignore
			&& control.has_global_point(point)) {
			return control;
		}

		return null;
	}

	public function update_layout():Void {
		update_layout_node(root);
	}

	function update_layout_node(node:Node):Void {
		var control:Null<Control> = Std.instance(node, Control);
		if (control != null) {
			control.update_layout();
		}

		for (child in node.get_children()) {
			update_layout_node(child);
		}
	}

	public function call_group_process(delta:Float):Void {
		for (node in processNodes) {
			if (node.isInsideTree && !node.isQueuedForDeletion) {
				node._process(delta);
			}
		}
	}

	public function call_group_physics_process(delta:Float):Void {
		for (node in physicsProcessNodes) {
			if (node.isInsideTree && !node.isQueuedForDeletion) {
				node._physics_process(delta);
			}
		}
	}

	public function flush_deleted():Void {
		for (node in deletionQueue) {
			if (node.parent != null) {
				node.parent.remove_child(node);
			}

			node.free();
		}

		deletionQueue = [];
	}

	override public function _process(delta:Float):Bool {
		frameCount++;
		call_group_process(delta);
		flush_deleted();
		return false;
	}

	override public function _physics_process(delta:Float):Bool {
		physicsFrameCount++;
		call_group_physics_process(delta);
		return false;
	}
}
