package game;

import godot.Control;
import godot.Button;
import godot.ProgressBar;

class HUDController extends Control {
    public var healthBar:Null<ProgressBar>;
    public var pauseMenu:Null<Control>;

    public function new() {
        super();
        healthBar = null;
        pauseMenu = null;
    }

    override public function _ready():Void {
        var bar:Null<ProgressBar> = Std.instance(get_node_or_null("HealthBar"), ProgressBar);
        healthBar = bar;

        var menu:Null<Control> = Std.instance(get_node_or_null("PauseMenu"), Control);
        pauseMenu = menu;

        if (pauseMenu != null) {
            pauseMenu.set_visible(false);
        }
    }

    public function set_health(value:Float):Void {
        if (healthBar != null) {
            healthBar.value = value;
        }
    }

    public function toggle_pause_menu():Void {
        if (pauseMenu == null) {
            return;
        }

        pauseMenu.set_visible(!pauseMenu.visible);
    }
}