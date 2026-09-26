package godot;

class StyleBoxFlat extends StyleBox {
	public var bgColor:Color;
	public var borderColor:Color;
	public var borderWidth:Float;
	public var cornerRadius:Float;

	public function new() {
		super();

		bgColor = new Color(0.1, 0.1, 0.1, 1.0);
		borderColor = new Color(0.0, 0.0, 0.0, 1.0);
		borderWidth = 0.0;
		cornerRadius = 0.0;
	}
}
