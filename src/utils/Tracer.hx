package utils;
import haxe.CallStack;
class Tracer {
    public function new() {
    }

    var masks:Array<String>;
    var paths:Array<String>;
    var hiddenStack:Array<String> = ["openfl", "lime", "Export", "minject"];
    var hiddenMethods:Array<String> = ["lime", "flash"];
    var sysTrace = haxe.Log.trace;

    public function init(masks = null, paths = null) {
        this.masks = masks;
        this.paths = paths;
        haxe.Log.trace = trace;
    }

    function checkPath(path:String) {
        if (paths == null)
            return true;
        for (p in paths) {
            if (path.indexOf(p) > -1)
                return true;
        }
        return false;
    }

    function isStackVisible(path:String) {
//        return false;
        for (p in hiddenStack)
            if (path.indexOf(p) > -1) {
                return false;
            }
        return true;
    }

    function isMethodVisible(path:String) {
        for (p in hiddenMethods)
            if (path.indexOf(p) > -1) {
                return false;
            }
        return true;
    }

    public function trace(val, ?pos) {
        var check = false;
        var stack = "";

        function checkItem(cs, path = "") {
            switch cs {
                case FilePos(scs, fn, _, _) :
//                    trace(fn);
                    if (checkPath(fn)) {
                        check = true;
                    }
                    if (scs != null)
                        checkItem(scs, fn);
                case Method(cl, mt) if (isStackVisible(path) && isMethodVisible(cl)): stack += "          [" + cl + "." + mt + "] "
//                + path
                + "\n" ;
                case _:
            }
        }
        for (cs in CallStack.callStack()) {
            checkItem(cs) ;
        }
        if (check) {
//            var oc:Array<Entity->Void> = cast
            sysTrace(val + " \n" + stack, pos);
//            trace("dispatching " + getComponents()  + " " +  getChildren().length + onContext +  "\n" + stack  + " " );
        }
    }
}
