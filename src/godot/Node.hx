package godot;

import godot.core.EngineError;
import godot.core.Log;

enum abstract ProcessMode(Int) {
	var Inherit = 0;
	var Always = 1;
	var Disabled = 2;
}

class Node extends Object {
	public var parent:Null<Node>;
	public var tree:Null<SceneTree>;
	public var owner:Null<Node>;

	public var processEnabled:Bool;
	public var physicsProcessEnabled:Bool;
	public var inputEnabled:Bool;
	public var unhandledInputEnabled:Bool;

	public var isInsideTree:Bool;
	public var isQueuedForDeletion:Bool;

	var children:Array<Node>;
	var childrenByName:Map<String, Node>;

	public function new() {
		super();
		parent = null;
		tree = null;
		owner = null;
		processEnabled = false;
		physicsProcessEnabled = false;
		inputEnabled = false;
		unhandledInputEnabled = false;
		isInsideTree = false;
		isQueuedForDeletion = false;
		children = [];
		childrenByName = new Map<String, Node>();
	}

	public function get_name():String {
		return name;
	}

	public function set_name(value:String):Void {
		if (value.length == 0) {
			Log.fatal(new EngineError("Scene", "Node", "set_name", "Node name must not be empty"));
		}

		if (parent != null) {
			var existing:Null<Node> = parent.childrenByName.get(value);
			if (existing != null && existing != this) {
				Log.fatal(new EngineError("Scene", "Node", "set_name", "Duplicate child name: " + value, get_path()));
			}
		}

		if (parent != null && name.length > 0) {
			parent.childrenByName.remove(name);
		}

		name = value;

		if (parent != null) {
			parent.childrenByName.set(name, this);
		}
	}

	public function add_child(child:Node):Void {
		if (child.parent != null) {
			Log.fatal(new EngineError("Scene", "Node", "add_child", "Child already has a parent", child.get_path()));
		}

		if (childrenByName.exists(child.name)) {
			Log.fatal(new EngineError("Scene", "Node", "add_child", "Duplicate child name: " + child.name, get_path()));
		}

		children.push(child);
		childrenByName.set(child.name, child);
		child.parent = this;

		if (child.owner == null) {
			child.owner = this.owner != null ? this.owner : this;
		}

		if (isInsideTree && tree != null) {
			child.propagate_enter_tree(tree);
		}
	}

	public function remove_child(child:Node):Void {
		if (child.parent != this) {
			Log.fatal(new EngineError("Scene", "Node", "remove_child", "Child does not belong to this parent", child.get_path()));
		}

		children.remove(child);
		childrenByName.remove(child.name);
		child.propagate_exit_tree();
		child.parent = null;
		child.tree = null;
		child.isInsideTree = false;
	}

	public function get_child_count():Int {
		return children.length;
	}

	public function get_child(index:Int):Null<Node> {
		if (index < 0 || index >= children.length) {
			return null;
		}
		return children[index];
	}

	public function get_children():Array<Node> {
		return children.copy();
	}

	public function get_parent():Null<Node> {
		return parent;
	}

	public function has_node(path:String):Bool {
		return get_node_or_null(path) != null;
	}

	public function get_node<T:Node>(path:String):T {
		var result:Null<Node> = get_node_or_null(path);
		if (result == null) {
			Log.fatal(new EngineError("Scene", "Node", "get_node", "Node not found: " + path, get_path()));
		}
		return cast result;
	}

	public function get_node_or_null(path:String):Null<Node> {
		var nodePath:NodePath = new NodePath(path);

		if (nodePath.is_absolute()) {
			var root:Null<Node> = get_tree_root();
			if (root == null) {
				return null;
			}
			return root.resolve_relative(nodePath, 0);
		}

		return resolve_relative(nodePath, 0);
	}

	function get_tree_root():Null<Node> {
		if (tree == null) {
			return null;
		}
		return tree.root;
	}

	function resolve_relative(path:NodePath, startIndex:Int):Null<Node> {
		var current:Null<Node> = this;

		var i:Int = startIndex;
		while (i < path.get_part_count()) {
			var part:Null<String> = path.get_part(i);
			if (part == null) {
				return null;
			}

			if (current == null) {
				return null;
			}

			if (part == ".") {
				i++;
				continue;
			}

			if (part == "..") {
				current = current.parent;
				i++;
				continue;
			}

			current = current.childrenByName.get(part);
			i++;
		}

		return current;
	}

	public function get_path():String {
		if (parent == null) {
			return "/" + name;
		}

		var parentPath:String = parent.get_path();
		if (parentPath == "/") {
			return "/" + name;
		}

		return parentPath + "/" + name;
	}

	public function queue_free():Void {
		if (isQueuedForDeletion) {
			return;
		}

		isQueuedForDeletion = true;

		if (tree != null) {
			tree.queue_delete(this);
		}
	}

	public function propagate_enter_tree(newTree:SceneTree):Void {
		tree = newTree;
		isInsideTree = true;
		newTree.register_node(this);
		_enter_tree();

		for (child in children) {
			child.propagate_enter_tree(newTree);
		}

		if (!readyCalled) {
			readyCalled = true;
			_ready();
		}
	}

	public function propagate_exit_tree():Void {
		for (child in children) {
			child.propagate_exit_tree();
		}

		_exit_tree();

		if (tree != null) {
			tree.unregister_node(this);
		}

		isInsideTree = false;
	}

	var readyCalled:Bool = false;

	public function _enter_tree():Void {}

	public function _ready():Void {}

	public function _exit_tree():Void {}

	public function _process(delta:Float):Void {}

	public function _physics_process(delta:Float):Void {}

	public function _input(event:InputEvent):Void {}

	public function _unhandled_input(event:InputEvent):Void {}

	public function set_process(enabled:Bool):Void {
		processEnabled = enabled;
		if (tree != null) {
			if (enabled) {
				tree.add_process_node(this);
			} else {
				tree.remove_process_node(this);
			}
		}
	}

	public function set_physics_process(enabled:Bool):Void {
		physicsProcessEnabled = enabled;
		if (tree != null) {
			if (enabled) {
				tree.add_physics_process_node(this);
			} else {
				tree.remove_physics_process_node(this);
			}
		}
	}

	public function set_input_enabled(enabled:Bool):Void {
		inputEnabled = enabled;
	}

	public function set_property(name:String, value:godot.tscn.TscnValue, doc:godot.tscn.TscnDocument):Bool {
		return false;
	}

	public function set_unhandled_input_enabled(enabled:Bool):Void {
		unhandledInputEnabled = enabled;
	}
}
