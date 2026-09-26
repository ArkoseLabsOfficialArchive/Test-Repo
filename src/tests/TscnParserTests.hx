package tests;

import godot.tscn.TscnParser;
import godot.tscn.TscnDocument;

class TscnParserTests {
    public static function run():Void {
        var text:String = '[gd_scene load_steps=3 format=2]

[ext_resource path="res://player.png" type="Texture" id="1_abc"]

[sub_resource type="RectangleShape2D" id="RectangleShape2D_x"]
size = Vector2(24, 32)

[node name="Player" type="KinematicBody2D"]
position = Vector2(10, 20)

[node name="Sprite" type="Sprite" parent="."]
centered = true
';

        var parser:TscnParser = new TscnParser();
        var doc:TscnDocument = parser.parse(text);

        TestRunner.assert(doc.header != null, "TSCN header parsed");
        TestRunner.assert(doc.header.loadSteps == 3, "TSCN load_steps");
        TestRunner.assert(doc.header.format == 2, "TSCN format");
        TestRunner.assert(doc.extResources.length == 1, "TSCN ext_resource count");
        TestRunner.assert(doc.subResources.length == 1, "TSCN sub_resource count");
        TestRunner.assert(doc.nodes.length == 2, "TSCN node count");
    }
}