package godot;

import godot.core.EngineError;
import godot.core.Log;
import godot.tscn.TscnDocument;
import godot.tscn.TscnNode;
import godot.tscn.TscnProperty;
import godot.tscn.TscnValue;
import godot.tscn.TscnExternalResource;

class PackedScene extends Resource {
	public var document:Null<TscnDocument>;

	public function new() {
		super();
		document = null;
	}

	public function build_from_document(doc:TscnDocument):Void {
		document = doc;
	}

	public function instance():Node {
		if (document == null) {
			Log.fatal(new EngineError("Scene", "PackedScene", "instance", "PackedScene has no document"));
		}

		var doc:TscnDocument = document;
		var source:String = doc.sourcePath.length > 0 ? doc.sourcePath : "unknown .tscn";

		var nodesByPath:Map<String, Node> = new Map<String, Node>();
		var root:Null<Node> = null;

		for (tscnNode in doc.nodes) {
			var node:Node = create_node(tscnNode, doc);

			node.set_name(tscnNode.name);
			apply_properties(node, tscnNode, doc);

			if (tscnNode.parent == "." || tscnNode.parent == "") {
				if (root == null) {
					root = node;
					nodesByPath.set(".", node);
					nodesByPath.set(node.name, node);
				} else {
					root.add_child(node);
					nodesByPath.set(tscnNode.name, node);
				}
			} else {
				var parent:Null<Node> = nodesByPath.get(tscnNode.parent);

				if (parent == null) {
					Log.fatal(new EngineError("Scene", "PackedScene", "instance",
						"Invalid parent path: '"
						+ tscnNode.parent
						+ "' for node '"
						+ tscnNode.name
						+ "' in "
						+ source
						+ ":"
						+ tscnNode.sourceLine));
				}

				parent.add_child(node);
				nodesByPath.set(tscnNode.parent + "/" + tscnNode.name, node);
			}
		}

		if (root == null) {
			Log.fatal(new EngineError("Scene", "PackedScene", "instance", "Scene has no root node in " + source));
		}

		apply_connections(doc, nodesByPath);

		return root;
	}

	public function instantiate():Node {
		return instance();
	}

	public function pack(node:Node):Void {
		Log.warning("Scene", "PackedScene.pack() runtime packing is intentionally limited in this build");
	}

	function create_node(tscnNode:TscnNode, doc:TscnDocument):Node {
		var source:String = doc.sourcePath.length > 0 ? doc.sourcePath : "unknown .tscn";

		if (tscnNode.instanceResource != null) {
			var resourceId:String = extract_resource_id(tscnNode.instanceResource);

			var ext:Null<TscnExternalResource> = doc.get_ext_resource(resourceId);
			if (ext == null) {
				Log.fatal(new EngineError("Scene", "PackedScene", "create_node",
					"Missing instance ext_resource id: '"
					+ resourceId
					+ "' for node '"
					+ tscnNode.name
					+ "' in "
					+ source
					+ ":"
					+ tscnNode.sourceLine));
			}

			var resource:Resource = ResourceLoader.load(ext.path, "PackedScene");
			var packedScene:Null<PackedScene> = Std.instance(resource, PackedScene);

			if (packedScene == null) {
				Log.fatal(new EngineError("Scene", "PackedScene", "create_node",
					"Instanced resource is not a PackedScene: "
					+ ext.path
					+ " for node '"
					+ tscnNode.name
					+ "' in "
					+ source
					+ ":"
					+ tscnNode.sourceLine,
					null, ext.path));
			}

			return packedScene.instance();
		}

		return NodeFactory.create(tscnNode.type);
	}

	function extract_resource_id(text:String):String {
		var start:Int = text.indexOf("(");
		var end:Int = text.lastIndexOf(")");

		if (start < 0 || end < 0) {
			return StringTools.replace(text, "\"", "");
		}

		var inner:String = text.substr(start + 1, end - start - 1);
		return StringTools.replace(inner, "\"", "");
	}

	function apply_properties(node:Node, tscnNode:TscnNode, doc:TscnDocument):Void {
		for (prop in tscnNode.properties) {
			apply_property(node, tscnNode, prop, doc);
		}
	}

	function apply_property(node:Node, tscnNode:TscnNode, prop:TscnProperty, doc:TscnDocument):Void {
		if (prop.name == "__meta__") {
			return;
		}

		var source:String = doc.sourcePath.length > 0 ? doc.sourcePath : "unknown .tscn";
		var line:Int = prop.line;

		if (is_control_only_property(prop.name)) {
			var controlCheck:Null<Control> = Std.instance(node, Control);
			if (controlCheck == null) {
				Log.warningSource("Scene",
					"Control-only property '"
					+ prop.name
					+ "' ignored on non-Control node type '"
					+ tscnNode.type
					+ "' named '"
					+ tscnNode.name
					+ "'",
					source, line);

				return;
			}
		}

		var node2D:Null<Node2D> = Std.instance(node, Node2D);
		var canvas:Null<CanvasItem> = Std.instance(node, CanvasItem);

		switch (prop.name) {
			case "position":
				if (node2D != null && prop.value.vector2Value != null) {
					node2D.set_position(prop.value.vector2Value);
					return;
				}

			case "rotation":
				if (node2D != null) {
					var rotation:Null<Float> = get_float_value(prop.value);
					if (rotation != null) {
						node2D.set_rotation(rotation);
						return;
					}
				}

			case "rotation_degrees":
				if (node2D != null) {
					var degrees:Null<Float> = get_float_value(prop.value);
					if (degrees != null) {
						node2D.set_rotation(degrees * Math.PI / 180.0);
						return;
					}
				}

			case "scale":
				if (node2D != null && prop.value.vector2Value != null) {
					node2D.set_scale(prop.value.vector2Value);
					return;
				}

			case "global_position":
				if (node2D != null && prop.value.vector2Value != null) {
					node2D.set_global_position(prop.value.vector2Value);
					return;
				}

			case "visible":
				if (canvas != null && prop.value.boolValue != null) {
					canvas.set_visible(prop.value.boolValue);
					return;
				}

			case "z_index":
				if (canvas != null) {
					var z:Null<Int> = get_int_value(prop.value);
					if (z != null) {
						canvas.set_z_index(z);
						return;
					}
				}

			case "modulate":
				if (canvas != null && prop.value.colorValue != null) {
					canvas.set_modulate(prop.value.colorValue);
					return;
				}

			case "self_modulate":
				if (canvas != null && prop.value.colorValue != null) {
					canvas.selfModulate = prop.value.colorValue;
					canvas.mark_dirty(DirtyFlag.Visual);
					return;
				}
		}

		var handled:Bool = node.set_property(prop.name, prop.value, doc);

		if (!handled) {
			Log.debugSource("Scene", "Unhandled property: " + prop.name + " on " + node.className + " node '" + node.name + "'", source, line);
		}
	}

	function is_control_only_property(name:String):Bool {
		return switch (name) {
			case "anchor_left": true;
			case "anchor_top": true;
			case "anchor_right": true;
			case "anchor_bottom": true;
			case "margin_left": true;
			case "margin_top": true;
			case "margin_right": true;
			case "margin_bottom": true;
			case "rect_min_size": true;
			case "custom_minimum_size": true;
			case "mouse_filter": true;
			case "focus_mode": true;
			case "theme": true;
			default: false;
		}
	}

	function apply_connections(doc:TscnDocument, nodesByPath:Map<String, Node>):Void {
		var source:String = doc.sourcePath.length > 0 ? doc.sourcePath : "unknown .tscn";

		for (connection in doc.connections) {
			var sourceNode:Null<Node> = nodesByPath.get(connection.from);
			var targetNode:Null<Node> = nodesByPath.get(connection.to);

			if (sourceNode == null) {
				Log.warning("Scene", "Connection source not found: '" + connection.from + "' in " + source);

				continue;
			}

			if (targetNode == null) {
				Log.warning("Scene", "Connection target not found: '" + connection.to + "' in " + source);

				continue;
			}

			if (!sourceNode.has_signal(connection.signal)) {
				sourceNode.add_user_signal(connection.signal);
			}

			sourceNode.connect(connection.signal, targetNode, function(args:Array<Dynamic>):Void {
				targetNode.call_method(connection.method, args);
			});
		}
	}

	function get_float_value(value:TscnValue):Null<Float> {
		if (value.floatValue != null) {
			return value.floatValue;
		}

		if (value.intValue != null) {
			return value.intValue;
		}

		return null;
	}

	function get_int_value(value:TscnValue):Null<Int> {
		if (value.intValue != null) {
			return value.intValue;
		}

		if (value.floatValue != null) {
			return Math.round(value.floatValue);
		}

		return null;
	}
}
