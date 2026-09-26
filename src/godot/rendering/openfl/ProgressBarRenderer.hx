package godot.rendering.openfl;

import godot.ProgressBar;
import godot.DirtyFlag;
import openfl.display.Sprite;

class ProgressBarRenderer {
    var renderer:Renderer;
    var lastRatio:Float;

    public function new(renderer:Renderer) {
        this.renderer = renderer;
        lastRatio = Math.NaN;
    }

    public function create_state(bar:ProgressBar):RenderObjectState {
        var state:RenderObjectState = new RenderObjectState();
        var sprite:Sprite = new Sprite();
        state.displayObject = sprite;
        renderer.add_gui_object(sprite);
        return state;
    }

    public function update_if_dirty(bar:ProgressBar, state:RenderObjectState):Void {
        var sprite:Null<Sprite> = Std.instance(state.displayObject, Sprite);
        if (sprite == null) {
            return;
        }

        var ratio:Float = bar.get_ratio();

        var needsUpdate:Bool =
            bar.is_dirty(DirtyFlag.Visual) ||
            bar.is_dirty(DirtyFlag.Layout) ||
            lastRatio != ratio ||
            state.lastWidth != state.lastWidth; // NaN guard workaround

        if (!needsUpdate && !Math.isNaN(lastRatio)) {
            return;
        }

        var width:Float = state.lastWidth;
        var height:Float = state.lastHeight;

        if (Math.isNaN(width)) width = 0.0;
        if (Math.isNaN(height)) height = 0.0;

        sprite.graphics.clear();

        sprite.graphics.beginFill(0x222222, 1.0);
        sprite.graphics.drawRect(0.0, 0.0, width, height);
        sprite.graphics.endFill();

        sprite.graphics.beginFill(0x33AA33, 1.0);
        sprite.graphics.drawRect(0.0, 0.0, width * ratio, height);
        sprite.graphics.endFill();

        lastRatio = ratio;
        bar.clear_dirty(DirtyFlag.Visual);
    }
}