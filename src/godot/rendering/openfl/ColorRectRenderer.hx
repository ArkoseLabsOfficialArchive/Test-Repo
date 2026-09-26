package godot.rendering.openfl;

import godot.ColorRect;
import godot.DirtyFlag;
import openfl.display.Sprite;

class ColorRectRenderer {
    var renderer:Renderer;

    public function new(renderer:Renderer) {
        this.renderer = renderer;
    }

    public function create_state(rect:ColorRect):RenderObjectState {
        var state:RenderObjectState = new RenderObjectState();
        var sprite:Sprite = new Sprite();

        state.displayObject = sprite;
        renderer.add_gui_object(sprite);

        update(rect, sprite, state);

        return state;
    }

    public function update_if_dirty(rect:ColorRect, state:RenderObjectState):Void {
        var sprite:Null<Sprite> = Std.instance(state.displayObject, Sprite);
        if (sprite == null) {
            return;
        }

        if (rect.is_dirty(DirtyFlag.Visual) || rect.is_dirty(DirtyFlag.Layout)) {
            update(rect, sprite, state);
            rect.clear_dirty(DirtyFlag.Visual);
            rect.clear_dirty(DirtyFlag.Layout);
        }
    }

    function update(rect:ColorRect, sprite:Sprite, state:RenderObjectState):Void {
        sprite.graphics.clear();
        sprite.graphics.beginFill(rect.color.to_argb32() & 0xFFFFFF, rect.color.a);
        sprite.graphics.drawRect(0, 0, rect.rectSize.x, rect.rectSize.y);
        sprite.graphics.endFill();
    }
}