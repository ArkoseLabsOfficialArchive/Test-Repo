package godot.tres;

import godot.tscn.TscnExternalResource;
import godot.tscn.TscnSubResource;
import godot.tscn.TscnValue;

class TresDocument {
    public var header:Null<TresHeader>;
    public var extResources:Array<TscnExternalResource>;
    public var subResources:Array<TscnSubResource>;
    public var properties:Map<String, TscnValue>;

    public function new() {
        header = null;
        extResources = [];
        subResources = [];
        properties = new Map<String, TscnValue>();
    }

    public function get_ext_resource(id:String):Null<TscnExternalResource> {
        for (res in extResources) {
            if (res.id == id) {
                return res;
            }
        }

        return null;
    }

    public function get_sub_resource(id:String):Null<TscnSubResource> {
        for (res in subResources) {
            if (res.id == id) {
                return res;
            }
        }

        return null;
    }
}