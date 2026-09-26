package godot;

class Control extends CanvasItem {
	public var position:Vector2;
	public var rectSize:Vector2;
	public var customMinimumSize:Vector2;

	public var anchorLeft:Float;
	public var anchorTop:Float;
	public var anchorRight:Float;
	public var anchorBottom:Float;

	public var marginLeft:Float;
	public var marginTop:Float;
	public var marginRight:Float;
	public var marginBottom:Float;

	public var mouseFilter:MouseFilter;
	public var focusMode:FocusMode;

	public var layoutDirty:Bool;

	var lastResolvedWidth:Float;
	var lastResolvedHeight:Float;

	public var customStyles:Map<String, StyleBox>;

	public var theme:Null<Theme>;

	public function new() {
		super();

		position = new Vector2(0, 0);
		rectSize = new Vector2(0, 0);
		customMinimumSize = new Vector2(0, 0);

		anchorLeft = 0.0;
		anchorTop = 0.0;
		anchorRight = 0.0;
		anchorBottom = 0.0;

		marginLeft = 0.0;
		marginTop = 0.0;
		marginRight = 0.0;
		marginBottom = 0.0;

		mouseFilter = MouseFilter.Stop;
		focusMode = FocusMode.None;

		layoutDirty = true;
		lastResolvedWidth = -1.0;
		lastResolvedHeight = -1.0;
		theme = null;
		customStyles = new Map<String, StyleBox>();
	}

	public function get_stylebox(styleName:String):Null<StyleBox> {
		return customStyles.get(styleName);
	}

	public function set_position(value:Vector2):Void {
		if (!position.equals(value)) {
			position = value.copy();
			mark_dirty(DirtyFlag.Layout);
			mark_parent_layout_dirty();
		}
	}

	public function get_effective_theme():Null<Theme> {
		if (theme != null) {
			return theme;
		}

		var current:Null<Node> = parent;

		while (current != null) {
			var control:Null<Control> = Std.instance(current, Control);
			if (control != null && control.theme != null) {
				return control.theme;
			}

			current = current.parent;
		}

		return Theme.defaultTheme;
	}

	public function set_position_no_propagate(value:Vector2):Void {
		position = value.copy();
		mark_dirty(DirtyFlag.Layout);
	}

	public function set_size(value:Vector2):Void {
		if (!rectSize.equals(value)) {
			rectSize = value.copy();
			mark_dirty(DirtyFlag.Layout);
			mark_parent_layout_dirty();
		}
	}

	public function set_size_no_propagate(value:Vector2):Void {
		rectSize = value.copy();
		mark_dirty(DirtyFlag.Layout);
	}

	public function set_anchors(left:Float, top:Float, right:Float, bottom:Float):Void {
		if (anchorLeft != left || anchorTop != top || anchorRight != right || anchorBottom != bottom) {
			anchorLeft = left;
			anchorTop = top;
			anchorRight = right;
			anchorBottom = bottom;

			layoutDirty = true;
			mark_dirty(DirtyFlag.Layout);
			mark_parent_layout_dirty();
		}
	}

	public function set_margins(left:Float, top:Float, right:Float, bottom:Float):Void {
		if (marginLeft != left || marginTop != top || marginRight != right || marginBottom != bottom) {
			marginLeft = left;
			marginTop = top;
			marginRight = right;
			marginBottom = bottom;

			layoutDirty = true;
			mark_dirty(DirtyFlag.Layout);
			mark_parent_layout_dirty();
		}
	}

	public function get_size():Vector2 {
		return rectSize.copy();
	}

	public function get_rect():Rect2 {
		return new Rect2(position.copy(), rectSize.copy());
	}

	public function get_global_position():Vector2 {
		var parentControl:Null<Control> = Std.instance(parent, Control);
		if (parentControl != null) {
			return parentControl.get_global_position().add(position);
		}

		var parent2D:Null<Node2D> = Std.instance(parent, Node2D);
		if (parent2D != null) {
			return parent2D.get_global_position().add(position);
		}

		return position.copy();
	}

	public function get_global_rect():Rect2 {
		return new Rect2(get_global_position(), rectSize.copy());
	}

	public function has_global_point(point:Vector2):Bool {
		return get_global_rect().has_point(point);
	}

	public function get_combined_minimum_size():Vector2 {
		return customMinimumSize.copy();
	}

	public function update_layout():Void {
		if (!layoutDirty) {
			return;
		}

		var parentSize:Vector2 = new Vector2(1280, 720);

		var parentControl:Null<Control> = Std.instance(parent, Control);
		if (parentControl != null) {
			parentSize = parentControl.rectSize;
		} else if (tree != null && tree.root != null) {
			parentSize = tree.root.size;
		}

		var left:Float = parentSize.x * anchorLeft + marginLeft;
		var top:Float = parentSize.y * anchorTop + marginTop;
		var right:Float = parentSize.x * anchorRight - marginRight;
		var bottom:Float = parentSize.y * anchorBottom - marginBottom;

		if (anchorLeft == anchorRight) {
			right = left + rectSize.x;
		}

		if (anchorTop == anchorBottom) {
			bottom = top + rectSize.y;
		}

		var newWidth:Float = right - left;
		var newHeight:Float = bottom - top;
		var minimumSize:Vector2 = get_combined_minimum_size();

		if (newWidth < minimumSize.x) {
			newWidth = minimumSize.x;
		}

		if (newHeight < minimumSize.y) {
			newHeight = minimumSize.y;
		}

		if (newWidth < 0.0)
			newWidth = 0.0;
		if (newHeight < 0.0)
			newHeight = 0.0;

		position.set(left, top);
		rectSize.set(newWidth, newHeight);

		if (rectSize.x != lastResolvedWidth || rectSize.y != lastResolvedHeight) {
			mark_children_layout_dirty();
		}

		lastResolvedWidth = rectSize.x;
		lastResolvedHeight = rectSize.y;

		layoutDirty = false;
		mark_dirty(DirtyFlag.Layout);

		arrange_children();
	}

	public function arrange_children():Void {
		// Base Control has no arrangement behavior.
	}

	public function gui_input(event:InputEvent):Void {
		// Virtual GUI input handler.
	}

	function mark_parent_layout_dirty():Void {
		var current:Null<Node> = parent;

		while (current != null) {
			var control:Null<Control> = Std.instance(current, Control);
			if (control != null) {
				control.layoutDirty = true;
			}

			current = current.parent;
		}
	}

	function mark_children_layout_dirty():Void {
		for (child in get_children()) {
			var control:Null<Control> = Std.instance(child, Control);
			if (control != null) {
				control.layoutDirty = true;
			}
		}
	}

	override public function set_property(name:String, value:godot.tscn.TscnValue, doc:godot.tscn.TscnDocument):Bool {
		if (StringTools.startsWith(name, "custom_styles/")) {
			var styleName:String = name.substr("custom_styles/".length);

			var resource:Null<Resource> = ResourceFactory.create_resource_from_value(value, doc);
			var styleBox:Null<StyleBox> = Std.instance(resource, StyleBox);

			if (styleBox != null) {
				customStyles.set(styleName, styleBox);
				mark_dirty(DirtyFlag.Visual);
			} else {
				customStyles.remove(styleName);
			}

			return true;
		}
		switch (name) {
			case "anchor_left":
				if (value.floatValue != null) {
					anchorLeft = value.floatValue;
					layoutDirty = true;
					return true;
				}

			case "anchor_top":
				if (value.floatValue != null) {
					anchorTop = value.floatValue;
					layoutDirty = true;
					return true;
				}

			case "anchor_right":
				if (value.floatValue != null) {
					anchorRight = value.floatValue;
					layoutDirty = true;
					return true;
				}

			case "anchor_bottom":
				if (value.floatValue != null) {
					anchorBottom = value.floatValue;
					layoutDirty = true;
					return true;
				}

			case "margin_left":
				if (value.floatValue != null) {
					marginLeft = value.floatValue;
					layoutDirty = true;
					return true;
				}

			case "margin_top":
				if (value.floatValue != null) {
					marginTop = value.floatValue;
					layoutDirty = true;
					return true;
				}

			case "margin_right":
				if (value.floatValue != null) {
					marginRight = value.floatValue;
					layoutDirty = true;
					return true;
				}

			case "margin_bottom":
				if (value.floatValue != null) {
					marginBottom = value.floatValue;
					layoutDirty = true;
					return true;
				}

			case "rect_size":
				if (value.vector2Value != null) {
					rectSize = value.vector2Value;
					layoutDirty = true;
					return true;
				}

			case "mouse_filter":
				if (value.intValue != null) {
					mouseFilter = value.intValue;
					return true;
				}

			case "focus_mode":
				if (value.intValue != null) {
					focusMode = value.intValue;
					return true;
				}

			case "rect_min_size":
				if (value.vector2Value != null) {
					customMinimumSize = value.vector2Value;
					layoutDirty = true;
					mark_dirty(DirtyFlag.Layout);
					return true;
				}

			case "custom_minimum_size":
				if (value.vector2Value != null) {
					customMinimumSize = value.vector2Value;
					layoutDirty = true;
					mark_dirty(DirtyFlag.Layout);
					return true;
				}

			case "rect_position":
				if (value.vector2Value != null) {
					position = value.vector2Value;
					layoutDirty = true;
					mark_dirty(DirtyFlag.Layout);
					return true;
				}

			case "theme":
				var resource:Null<Resource> = ResourceFactory.create_resource_from_value(value, doc);
				var loadedTheme:Null<Theme> = Std.instance(resource, Theme);

				if (loadedTheme != null) {
					theme = loadedTheme;
					mark_dirty(DirtyFlag.Visual);
					mark_dirty(DirtyFlag.Layout);
				}

				return true;
		}

		return super.set_property(name, value, doc);
	}
}
