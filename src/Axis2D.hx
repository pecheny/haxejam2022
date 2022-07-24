package ;
@:enum abstract Axis2D(Int) to Int{
    public static var keys = [ horizontal, vertical,];
    var horizontal = 0;
    var vertical = 1;
    inline private static var HORIZONTAL_STRING:String = "horizontal";
    inline private static var VERTIVAL_STRING:String = "vertical";

    @:to public function toString():String {
        return
            if (this == horizontal)
                HORIZONTAL_STRING
            else
                VERTIVAL_STRING;
    }

    @:from static inline function fromString(s:String) {
        return switch s {
            case HORIZONTAL_STRING : horizontal;
            case VERTIVAL_STRING : vertical;
            case s : throw "Cant parse axis ";
        }
    }

    public static inline function fromInt(v:Int) {
        #if debug
        if(v!=0 &&v!=1)
            throw 'wrong axis $v';
        #end
        return cast v;
    }

    public inline function athwart() {
        return this == horizontal ? vertical : horizontal;
    }

    public inline function toInt():Int return this;
}

abstract AxisCollection2D<T>(haxe.ds.Vector<T>) {
    public inline function new(defaultValue:T) {
        this = new haxe.ds.Vector(2);
        this[0] = defaultValue;
        this[1] = defaultValue;
    }

    @:arrayAccess public inline function get(k:Axis2D) {
        return this[k.toInt()];
    }

    @:arrayAccess public inline function set(k:Axis2D, v:T) {
        return this[k.toInt()] = v;
    }
}

