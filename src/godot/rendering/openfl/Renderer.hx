package godot.rendering.openfl;

import godot.core.EngineError;
import godot.core.Log;
import openfl.display.DisplayObject;
import godot.CanvasItem;
import godot.Button;
import godot.Label;
import godot.ColorRect;
import godot.Panel;
import godot.TextureRect;
import godot.ProgressBar;
import godot.Control;
import godot.AnimatedSprite;
import godot.Sprite;
import godot.TileMap;
import godot.CPUParticles2D;
import godot.Node2D;
import godot.YSort;
import godot.Camera2D;
import godot.SceneTree;
import godot.Engine;
import godot.Transform2D;
import godot.Vector2;
import godot.DirtyFlag;
import godot.VisualServer;
import godot.LineEdit;
import godot.TextEdit;
import godot.EngineTime;
import godot.TextureButton;
import godot.HSlider;
import godot.VSlider;
import godot.RichTextLabel;
import godot.TextureProgress;
import godot.NinePatchRect;

class Renderer extends VisualServer {
	public var rootSprite:openfl.display.Sprite;
	public var worldSprite:openfl.display.Sprite;
	public var guiSprite:openfl.display.Sprite;

	var states:Map<Int, RenderObjectState>;

	var nodeRenderer:Node2DRenderer;
	var spriteRenderer:SpriteRenderer;
	var animatedSpriteRenderer:AnimatedSpriteRenderer;
	var tileMapRenderer:TileMapRenderer;
	var particlesRenderer:Particles2DRenderer;

	var controlRenderer:ControlRenderer;
	var labelRenderer:LabelRenderer;
	var colorRectRenderer:ColorRectRenderer;
	var panelRenderer:PanelRenderer;
	var buttonRenderer:ButtonRenderer;
	var textureRectRenderer:TextureRectRenderer;
	var progressBarRenderer:ProgressBarRenderer;
	var lineEditRenderer:LineEditRenderer;
	var textEditRenderer:TextEditRenderer;
	var textureButtonRenderer:TextureButtonRenderer;
	var hSliderRenderer:HSliderRenderer;
	var vSliderRenderer:VSliderRenderer;
	var richTextLabelRenderer:RichTextLabelRenderer;
	var textureProgressRenderer:TextureProgressRenderer;
	var ninePatchRectRenderer:NinePatchRectRenderer;

	public function new() {
		super();

		rootSprite = new openfl.display.Sprite();
		worldSprite = new openfl.display.Sprite();
		guiSprite = new openfl.display.Sprite();

		rootSprite.addChild(worldSprite);
		rootSprite.addChild(guiSprite);

		states = new Map<Int, RenderObjectState>();

		nodeRenderer = new Node2DRenderer(this);
		spriteRenderer = new SpriteRenderer(this);
		animatedSpriteRenderer = new AnimatedSpriteRenderer(this);
		tileMapRenderer = new TileMapRenderer(this);
		particlesRenderer = new Particles2DRenderer(this);

		controlRenderer = new ControlRenderer(this);
		labelRenderer = new LabelRenderer(this);
		colorRectRenderer = new ColorRectRenderer(this);
		panelRenderer = new PanelRenderer(this);
		buttonRenderer = new ButtonRenderer(this);
		textureRectRenderer = new TextureRectRenderer(this);
		progressBarRenderer = new ProgressBarRenderer(this);
		lineEditRenderer = new LineEditRenderer(this);
		textEditRenderer = new TextEditRenderer(this);
		textureButtonRenderer = new TextureButtonRenderer(this);
		hSliderRenderer = new HSliderRenderer(this);
		vSliderRenderer = new VSliderRenderer(this);
		richTextLabelRenderer = new RichTextLabelRenderer(this);
		textureProgressRenderer = new TextureProgressRenderer(this);
		ninePatchRectRenderer = new NinePatchRectRenderer(this);
	}

	public function add_world_object(display:DisplayObject):Void {
		worldSprite.addChild(display);
	}

	public function add_gui_object(display:DisplayObject):Void {
		guiSprite.addChild(display);
	}

	override public function register_canvas_item(item:CanvasItem):Void {
		if (states.exists(item.instanceId)) {
			return;
		}

		var state:RenderObjectState = create_state(item);
		states.set(item.instanceId, state);
	}

	override public function unregister_canvas_item(item:CanvasItem):Void {
		var state:Null<RenderObjectState> = states.get(item.instanceId);
		if (state == null) {
			return;
		}

		if (state.displayObject != null && state.displayObject.parent != null) {
			state.displayObject.parent.removeChild(state.displayObject);
		}

		states.remove(item.instanceId);
	}

	function create_state(item:CanvasItem):RenderObjectState {
		var button:Null<Button> = Std.instance(item, Button);
		if (button != null) {
			return buttonRenderer.create_state(button);
		}

		var label:Null<Label> = Std.instance(item, Label);
		if (label != null) {
			return labelRenderer.create_state(label);
		}

		var colorRect:Null<ColorRect> = Std.instance(item, ColorRect);
		if (colorRect != null) {
			return colorRectRenderer.create_state(colorRect);
		}

		var panel:Null<Panel> = Std.instance(item, Panel);
		if (panel != null) {
			return panelRenderer.create_state(panel);
		}

		var textureRect:Null<TextureRect> = Std.instance(item, TextureRect);
		if (textureRect != null) {
			return textureRectRenderer.create_state(textureRect);
		}

		var progressBar:Null<ProgressBar> = Std.instance(item, ProgressBar);
		if (progressBar != null) {
			return progressBarRenderer.create_state(progressBar);
		}

		var lineEdit:Null<LineEdit> = Std.instance(item, LineEdit);
		if (lineEdit != null) {
			return lineEditRenderer.create_state(lineEdit);
		}

		var textEdit:Null<TextEdit> = Std.instance(item, TextEdit);
		if (textEdit != null) {
			return textEditRenderer.create_state(textEdit);
		}

		var textureButton:Null<TextureButton> = Std.instance(item, TextureButton);
		if (textureButton != null) {
			return textureButtonRenderer.create_state(textureButton);
		}

		var hSlider:Null<HSlider> = Std.instance(item, HSlider);
		if (hSlider != null) {
			return hSliderRenderer.create_state(hSlider);
		}

		var vSlider:Null<VSlider> = Std.instance(item, VSlider);
		if (vSlider != null) {
			return vSliderRenderer.create_state(vSlider);
		}

		var richTextLabel:Null<RichTextLabel> = Std.instance(item, RichTextLabel);
		if (richTextLabel != null) {
			return richTextLabelRenderer.create_state(richTextLabel);
		}

		var textureProgress:Null<TextureProgress> = Std.instance(item, TextureProgress);
		if (textureProgress != null) {
			return textureProgressRenderer.create_state(textureProgress);
		}

		var ninePatchRect:Null<NinePatchRect> = Std.instance(item, NinePatchRect);
		if (ninePatchRect != null) {
			return ninePatchRectRenderer.create_state(ninePatchRect);
		}

		var control:Null<Control> = Std.instance(item, Control);
		if (control != null) {
			return controlRenderer.create_state(control);
		}

		var animatedSprite:Null<AnimatedSprite> = Std.instance(item, AnimatedSprite);
		if (animatedSprite != null) {
			return animatedSpriteRenderer.create_state(animatedSprite);
		}

		var sprite:Null<Sprite> = Std.instance(item, Sprite);
		if (sprite != null) {
			return spriteRenderer.create_state(sprite);
		}

		var tileMap:Null<TileMap> = Std.instance(item, TileMap);
		if (tileMap != null) {
			return tileMapRenderer.create_state(tileMap);
		}

		var particles:Null<CPUParticles2D> = Std.instance(item, CPUParticles2D);
		if (particles != null) {
			return particlesRenderer.create_state(particles);
		}

		var node2D:Null<Node2D> = Std.instance(item, Node2D);
		if (node2D != null) {
			return nodeRenderer.create_state(node2D);
		}

		Log.fatal(new EngineError("Renderer", "Renderer", "create_state", "Unsupported canvas item type", item.get_path()));

		return new RenderObjectState();
	}

	override public function synchronize():Void {
		var tree:Null<SceneTree> = Engine.mainSceneTree;
		if (tree == null) {
			return;
		}

		apply_camera_transform(tree);
		synchronize_node(tree.root);
	}

	function apply_camera_transform(tree:SceneTree):Void {
		var camera:Null<Camera2D> = Camera2D.currentCamera;

		if (camera != null && camera.isInsideTree) {
			var viewportSize:Vector2 = tree.root.size;
			var transform:Transform2D = camera.get_camera_transform(viewportSize);

			if (worldSprite.x != transform.origin.x)
				worldSprite.x = transform.origin.x;
			if (worldSprite.y != transform.origin.y)
				worldSprite.y = transform.origin.y;
			if (worldSprite.scaleX != transform.x.x)
				worldSprite.scaleX = transform.x.x;
			if (worldSprite.scaleY != transform.y.y)
				worldSprite.scaleY = transform.y.y;
		} else {
			if (worldSprite.x != 0.0)
				worldSprite.x = 0.0;
			if (worldSprite.y != 0.0)
				worldSprite.y = 0.0;
			if (worldSprite.scaleX != 1.0)
				worldSprite.scaleX = 1.0;
			if (worldSprite.scaleY != 1.0)
				worldSprite.scaleY = 1.0;
		}
	}

	function synchronize_node(node:godot.Node):Void {
		var canvas:Null<CanvasItem> = Std.instance(node, CanvasItem);
		if (canvas != null) {
			synchronize_canvas_item(canvas);
		}

		for (child in node.get_children()) {
			synchronize_node(child);
		}

		var ySort:Null<YSort> = Std.instance(node, YSort);
		var needsSort:Bool = ySort != null && ySort.enabled;

		if (!needsSort) {
			for (child in node.get_children()) {
				var childCanvas:Null<CanvasItem> = Std.instance(child, CanvasItem);
				if (childCanvas != null && childCanvas.zIndex != 0) {
					needsSort = true;
					break;
				}
			}
		}

		if (needsSort) {
			sort_display_children(node);
		}
	}

	function synchronize_canvas_item(item:CanvasItem):Void {
		var state:Null<RenderObjectState> = states.get(item.instanceId);
		if (state == null) {
			register_canvas_item(item);
			state = states.get(item.instanceId);
		}

		if (state == null || state.displayObject == null) {
			return;
		}

		var control:Null<Control> = Std.instance(item, Control);
		if (control != null) {
			controlRenderer.update_transform(control, state);
		}

		var node2D:Null<Node2D> = Std.instance(item, Node2D);
		if (node2D != null) {
			nodeRenderer.update_transform(node2D, state);
		}

		if (item.is_dirty(DirtyFlag.Visibility)) {
			update_visibility(item, state);
			item.clear_dirty(DirtyFlag.Visibility);
		}

		if (item.is_dirty(DirtyFlag.Visual)) {
			update_modulate(item, state);
		}

		var button:Null<Button> = Std.instance(item, Button);
		if (button != null) {
			buttonRenderer.update_if_dirty(button, state);
			return;
		}

		var label:Null<Label> = Std.instance(item, Label);
		if (label != null) {
			labelRenderer.update_if_dirty(label, state);
			return;
		}

		var colorRect:Null<ColorRect> = Std.instance(item, ColorRect);
		if (colorRect != null) {
			colorRectRenderer.update_if_dirty(colorRect, state);
			return;
		}

		var panel:Null<Panel> = Std.instance(item, Panel);
		if (panel != null) {
			panelRenderer.update_if_dirty(panel, state);
			return;
		}

		var textureRect:Null<TextureRect> = Std.instance(item, TextureRect);
		if (textureRect != null) {
			textureRectRenderer.update_if_dirty(textureRect, state);
			return;
		}

		var progressBar:Null<ProgressBar> = Std.instance(item, ProgressBar);
		if (progressBar != null) {
			progressBarRenderer.update_if_dirty(progressBar, state);
			return;
		}

		var lineEdit:Null<LineEdit> = Std.instance(item, LineEdit);
		if (lineEdit != null) {
			lineEditRenderer.update_if_dirty(lineEdit, state);
			return;
		}

		var textEdit:Null<TextEdit> = Std.instance(item, TextEdit);
		if (textEdit != null) {
			textEditRenderer.update_if_dirty(textEdit, state);
			return;
		}

		var richTextLabel:Null<RichTextLabel> = Std.instance(item, RichTextLabel);
		if (richTextLabel != null) {
			richTextLabelRenderer.update_if_dirty(richTextLabel, state);
			return;
		}

		var textureProgress:Null<TextureProgress> = Std.instance(item, TextureProgress);
		if (textureProgress != null) {
			textureProgressRenderer.update_if_dirty(textureProgress, state);
			return;
		}

		var ninePatchRect:Null<NinePatchRect> = Std.instance(item, NinePatchRect);
		if (ninePatchRect != null) {
			ninePatchRectRenderer.update_if_dirty(ninePatchRect, state);
			return;
		}

		var sprite:Null<Sprite> = Std.instance(item, Sprite);
		if (sprite != null) {
			spriteRenderer.update_if_dirty(sprite, state);
			return;
		}

		var animatedSprite:Null<AnimatedSprite> = Std.instance(item, AnimatedSprite);
		if (animatedSprite != null) {
			animatedSpriteRenderer.update_if_dirty(animatedSprite, state);
			return;
		}

		var tileMap:Null<TileMap> = Std.instance(item, TileMap);
		if (tileMap != null) {
			tileMapRenderer.update_if_dirty(tileMap, state);
			return;
		}

		var particles:Null<CPUParticles2D> = Std.instance(item, CPUParticles2D);
		if (particles != null) {
			particlesRenderer.update_if_dirty(particles, state);
			return;
		}

		var spriteForAnimation:Null<Sprite> = Std.instance(item, Sprite);
		if (spriteForAnimation != null) {
			update_animated_texture(spriteForAnimation.texture, item);
		}

		var textureRectForAnimation:Null<TextureRect> = Std.instance(item, TextureRect);
		if (textureRectForAnimation != null) {
			update_animated_texture(textureRectForAnimation.texture, item);
		}

		var textureButton:Null<TextureButton> = Std.instance(item, TextureButton);
		if (textureButton != null) {
			textureButtonRenderer.update_if_dirty(textureButton, state);
			return;
		}

		var hSlider:Null<HSlider> = Std.instance(item, HSlider);
		if (hSlider != null) {
			hSliderRenderer.update_if_dirty(hSlider, state);
			return;
		}

		var vSlider:Null<VSlider> = Std.instance(item, VSlider);
		if (vSlider != null) {
			vSliderRenderer.update_if_dirty(vSlider, state);
			return;
		}
	}

	function update_animated_texture(texture:Null<godot.Texture>, item:CanvasItem):Void {
		var animated:Null<godot.AnimatedTexture> = Std.instance(texture, godot.AnimatedTexture);
		if (animated == null) {
			return;
		}

		if (animated.update(EngineTime.delta)) {
			item.mark_dirty(DirtyFlag.Texture);
		}
	}

	function update_visibility(item:CanvasItem, state:RenderObjectState):Void {
		if (state.lastVisible != item.visible && state.displayObject != null) {
			state.displayObject.visible = item.visible;
			state.lastVisible = item.visible;
		}
	}

	function update_modulate(item:CanvasItem, state:RenderObjectState):Void {
		var alpha:Float = item.modulate.a * item.selfModulate.a;

		if (state.lastAlpha != alpha && state.displayObject != null) {
			state.displayObject.alpha = alpha;
			state.lastAlpha = alpha;
		}
	}

	function sort_display_children(node:godot.Node):Void {
		var state:Null<RenderObjectState> = states.get(node.instanceId);
		if (state == null || state.displayObject == null) {
			return;
		}

		var container:Null<openfl.display.Sprite> = Std.instance(state.displayObject, openfl.display.Sprite);
		if (container == null) {
			return;
		}

		var entries:Array<RenderSortEntry> = [];

		for (child in node.get_children()) {
			var childCanvas:Null<CanvasItem> = Std.instance(child, CanvasItem);
			var childState:Null<RenderObjectState> = states.get(child.instanceId);

			if (childCanvas != null && childState != null && childState.displayObject != null) {
				var child2D:Null<Node2D> = Std.instance(child, Node2D);
				var yValue:Float = child2D != null ? child2D.get_global_position().y : 0.0;

				entries.push(new RenderSortEntry(yValue, childCanvas.zIndex, childState.displayObject));
			}
		}

		var ySort:Null<YSort> = Std.instance(node, YSort);

		entries.sort(function(a:RenderSortEntry, b:RenderSortEntry):Int {
			if (a.z != b.z) {
				return a.z - b.z;
			}

			if (ySort != null && ySort.enabled) {
				if (a.y < b.y)
					return -1;
				if (a.y > b.y)
					return 1;
			}

			return 0;
		});

		for (i in 0...entries.length) {
			var display:DisplayObject = entries[i].display;

			if (container.getChildIndex(display) != i) {
				container.setChildIndex(display, i);
			}
		}
	}
}
