package j2022;
import openfl.display.Sprite;
import fsm.FSM;
import fsm.State;
import j2022.CloudMove;
class Cloud extends FSM<CloudStates, Cloud> {
    public var view:CloudView;
    public var x:Float = 0;
    public var y:Float = 0;
    public var r:Float = 36;

    public var offsets:Map<CloudMoveSystem, Pos> = new Map();


    public function new() {
        super();
        view = new CloudView(this);
        addState(inactive, new InactiveState());
        addState(active, new ActiveState());
        addState(disappearing, new DisappearState());
        changeState(active);
    }

    override public function update(t:Float) {
        var _x = 0.;
        var _y = 0.;
        for (k in offsets.keys()) {
            var o = offsets[k];
            _x += o.x;
            _y += o.y;
        }

        x = (x + _x) / 2;
        y = (y + _y) / 2;
        super.update(t);
    }


}

class DisappearState extends CloudState {
    var t:Float = 0;
    var dur:Float = 1;

    override public function update(dt:Float):Void {
        t += dt;
        if (t >= dur) {
            fsm.changeState(inactive);
//            fsm.forceChangeState(disappearing);
            return;
        }
        fsm.view.drawDisappear(t / dur);
    }

    override public function onEnter():Void {
        t = 0;
        var ms = fsm.offsets.keys();
        for (k in ms)
            k.remove(fsm);
    }
}
class InactiveState extends CloudState {
    override public function onExit():Void {
        fsm.view.visible = true;
    }

    override public function onEnter():Void {
        fsm.view.visible = false;
    }
}
class ActiveState extends CloudState {

    override public function update(_):Void {
        fsm.view.drawActive();
    }
}

class CloudView extends Sprite {
    var cloud:Cloud;
    var color = 0xf0c0a0;
    var angles:Array<Float>;
    var spreadRange = new Range(20, 36);
    var sizeRange = new Range(10, 5);
    var alphaRange = new Range(0.9, 0);

    public function new(c) {
        this.cloud = c;
        var total = 5;
        angles = [for (i in 0...total) Math.PI * 2 * i / total] ;
        super();
    }

    public function drawActive() {
        graphics.clear();
        graphics.beginFill(color, 1);
        graphics.drawCircle(cloud.x, cloud.y, cloud.r);
        graphics.endFill();
    }

    public function drawDisappear(t:Float) {
        graphics.clear();
        for (i in 0...angles.length) {
            var r = spreadRange.transfomrValue(t);
            var x = cloud.x + Math.cos(angles[i]) * r;
            var y = cloud.y + Math.sin(angles[i]) * r;
            graphics.beginFill(color, alphaRange.transfomrValue(t));
            graphics.drawCircle(x, y, sizeRange.transfomrValue(t));
            graphics.endFill();
        }
    }
}

class CloudState extends State<CloudStates, Cloud> {
    public function new() {}
}

@:enum abstract CloudStates (String) to String {
    var active = "active";
    var disappearing = "disappearing";
    var inactive = "inactive";
}
class Range {
    var min:Float;
    var max:Float;

    public function new(a, b) {
        min = a;
        max = b;
    }

    public function transfomrValue(t:Float) {
        var range = max - min;
        return min + t * range;
    }
}