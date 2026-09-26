package godot.rendering.openfl;

import godot.LineEdit;
import godot.Engine;
import godot.DirtyFlag;

import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;

class LineEditRenderState extends RenderObjectState {
    public var background:Sprite;
    public var textField:TextField;

    public var lastText:String;
    public var lastFocused:Bool;

    public function new() {
        super();

        background = new Sprite();
        textField = new TextField();

        lastText = "";
        lastFocused = false;

        textField.selectable = false;
        textField.mouseEnabled = false;
    }
}

class LineEditRenderer {
    var renderer:Renderer;

    public function new(renderer:Renderer) {
        this.renderer = renderer;
    }

    public function create_state(lineEdit:LineEdit):RenderObjectState {
        var state:LineEditRenderState = new LineEditRenderState();
        var container:Sprite = new Sprite();

        container.addChild(state.background);
        container.addChild(state.textField);

        state.displayObject = container;
        renderer.add_gui_object(container);

        return state;
    }

    public function update_if_dirty(lineEdit:LineEdit, state:RenderObjectState):Void {
        var lineEditState:Null<LineEditRenderState> = Std.instance(state, LineEditRenderState);
        if (lineEditState == null) {
            return;
        }

        var focused:Bool =
            Engine.mainSceneTree != null &&
            Engine.mainSceneTree.guiState.focused == lineEdit;

        var displayText:String = lineEdit.get_display_text_with_caret(focused);

        var needsUpdate:Bool =
            lineEditState.lastText != displayText ||
            lineEditState.lastFocused != focused ||
            state.lastWidth != lineEdit.rectSize.x ||
            state.lastHeight != lineEdit.rectSize.y ||
            lineEdit.is_dirty(DirtyFlag.Text) ||
            lineEdit.is_dirty(DirtyFlag.Layout);

        if (!needsUpdate) {
            return;
        }

        var width:Float = state.lastWidth;
        var height:Float = state.lastHeight;

        if (Math.isNaN(width)) width = 0.0;
        if (Math.isNaN(height)) height = 0.0;

        var backgroundColor:Int = focused ? 0x333344 : 0x222222;

        lineEditState.background.graphics.clear();
        lineEditState.background.graphics.beginFill(backgroundColor, 1.0);
        lineEditState.background.graphics.drawRect(0.0, 0.0, width, height);
        lineEditState.background.graphics.endFill();

        lineEditState.textField.text = displayText;
        lineEditState.textField.width = width;
        lineEditState.textField.height = height;

        var textColor:Int = 0xFFFFFF;

        if (lineEdit.text.length == 0 && lineEdit.placeholderText.length > 0) {
            textColor = 0x888888;
        }

        var format:TextFormat = new TextFormat("Arial", 16, textColor);

        lineEditState.textField.defaultTextFormat = format;
        lineEditState.textField.setTextFormat(format);

        lineEditState.lastText = displayText;
        lineEditState.lastFocused = focused;

        lineEdit.clear_dirty(DirtyFlag.Text);
        lineEdit.clear_dirty(DirtyFlag.Layout);
    }
}