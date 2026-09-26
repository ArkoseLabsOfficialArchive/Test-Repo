package godot;

class InputEventKey extends InputEvent {
	public var keyCode:Int;
	public var pressed:Bool;
	public var echo:Bool;
	public var unicode:Int;

	public function new(keyCode:Int = 0, pressed:Bool = false, echo:Bool = false, unicode:Int = 0) {
		super();

		this.keyCode = keyCode;
		this.pressed = pressed;
		this.echo = echo;
		this.unicode = unicode;
	}
}
