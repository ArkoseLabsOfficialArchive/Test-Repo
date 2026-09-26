package godot.rendering.openfl;

class RenderObjectState {
	public var displayObject:Null<openfl.display.DisplayObject>;

	public var lastX:Float;
	public var lastY:Float;
	public var lastRotation:Float;
	public var lastScaleX:Float;
	public var lastScaleY:Float;
	public var lastVisible:Bool;
	public var lastAlpha:Float;
	public var lastZIndex:Int;

	public var lastWidth:Float;
	public var lastHeight:Float;

	public var lastTextureId:Int;
	public var lastFrame:Int;

	public function new() {
		displayObject = null;

		lastX = Math.NaN;
		lastY = Math.NaN;
		lastRotation = Math.NaN;
		lastScaleX = Math.NaN;
		lastScaleY = Math.NaN;

		lastVisible = true;
		lastAlpha = Math.NaN;
		lastZIndex = 0;

		lastWidth = Math.NaN;
		lastHeight = Math.NaN;

		lastTextureId = -1;
		lastFrame = -1;
	}
}
