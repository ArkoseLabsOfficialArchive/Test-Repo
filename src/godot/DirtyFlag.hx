package godot;

enum abstract DirtyFlag(Int) from Int to Int {
	var None = 0;
	var Transform = 1;
	var Visual = 2;
	var Texture = 3;
	var Frame = 4;
	var Visibility = 5;
	var ZIndex = 6;
	var Material = 7;
	var Layout = 8;
	var Text = 9;
	var ChildrenOrder = 10;
}