package j2022;
import openfl.events.Event;
import flash.display.MovieClip;
import openfl.display.Sprite;
import fsm.FSM;
import fsm.State;
import j2022.CloudMove;
import j2022.GodModel;

class Cloud extends FSM<CloudStates, Cloud> {
    public var view:CloudView;
    public var model:GodModel;
    public var pos = new Pos();
    public var distraction = 2;
    public var typeD = 2;
    public var type:DistractionType;
    public var r:Float = 36;
    public var viewId:Int = 0;

    public var offsets:Map<CloudMoveSystem, PosWithVel> = new Map();

    public function reset(type) {
        r = 36;
        this.type = type;
    }

    public function new(m) {
        super();
        this.model = m;
        view = new CloudView(this);
        addState(inactive, new InactiveState());
        addState(active, new ActiveState());
        addState(disappearing, new DisappearState());
        changeState(inactive);
    }

    override public function update(t:Float) {
        super.update(t);
    }

    public function getDistrPower() {
        return if (currentStateName == active) distraction else 0;
    }

    public function getTypeW():Float {
        return typeD;
    }

}

class DisappearState extends CloudState {
    var t:Float = 0;
    var dur:Float = 0.5;

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
        fsm.model.sounds.cloudPff();
    }

    override public function onExit():Void {
        super.onExit();
        fsm.model.cloudSpawner.inactiveClouds.push(fsm);
    }

}
class InactiveState extends CloudState {
    override public function onExit():Void {

        fsm.view.visible = true;
    }

    override public function onEnter():Void {
        var ms = fsm.offsets.keys();
        fsm.pos.x = 0;
        fsm.pos.y = 0;
        for (k in ms)
            k.remove(fsm);
        fsm.view.visible = false;
    }
}
class ActiveState extends CloudState {

    override public function update(_):Void {
        var _x = 0.;
        var _y = 0.;
        for (k in fsm.offsets.keys()) {
            var o = fsm.offsets[k];
            _x += o.x;
            _y += o.y;
        }

        fsm.pos.x = (fsm.pos.x + _x) / 2;
        fsm.pos.y = (fsm.pos.y + _y) / 2;
        fsm.view.drawActive();
    }


    override public function onEnter():Void {
        fsm.view.init(fsm.viewId);
//        fsm.view.init(Math.floor(Math.random() * 6));
    }
}

class CloudView extends Sprite {
    var cloud:Cloud;
    var color = 0xf0c0a0;
    var angles:Array<Float>;
    var spreadRange = new Range(20, 36);
    var sizeRange = new Range(10, 5);
    var alphaRange = new Range(0.9, 0);
    var asset:MovieClip;
    var icon:MovieClip;
    var assetSize = 64;

    public function new(c) {
        super();
        asset = cast new CloudAsset();
        addChild(asset);
        asset.stop();
        icon = new Icons();
        addChild(icon);
        icon.stop();
//        asset.alpha = 0.5;
//        asset.addEventListener(Event.ENTER_FRAME, e -> {if (asset.currentFrame == asset.totalFrames)asset.stop();});
        this.cloud = c;
//        var total = 5;
//        angles = [for (i in 0...total) Math.PI * 2 * i / total] ;
//        super();
    }

    function setPos() {
        x = cloud.pos.x;
        y = cloud.pos.y;
    }

    public function init(fr) {
        var scale = cloud.r * 2 / assetSize;
        asset.scaleX = asset.scaleY = scale;
        asset.gotoAndStop(1);
        icon.gotoAndStop(fr);
        setPos();
    }

    var cloud_f1 = 7;

    public function drawActive() {
        icon.visible = true;
        if (GlobalTime.tick % 10 == 0) asset.gotoAndStop(cloud_f1 + Math.ceil(Math.random() * 3));
        setPos();
//        graphics.clear();
//        graphics.beginFill(color, 1);
//        var o = cloud;
////        graphics.drawRect(o.pos.x-o.r,o.pos.y-o.r, o.r*2, o.r*2);
//        graphics.drawCircle(cloud.pos.x, cloud.pos.y, cloud.r);
//        graphics.endFill();
    }

    public function drawDisappear(t:Float) {
        icon.visible = false;
        var totalFrames = 4;
        var startFrame = 11;// 4;
        var frame = startFrame + Math.floor(t * totalFrames);
        asset.gotoAndPlay(frame);
        setPos();
//        graphics.clear();
//        for (i in 0...angles.length) {
//            var r = spreadRange.transfomrValue(t);
//            var x = cloud.pos.x + Math.cos(angles[i]) * r;
//            var y = cloud.pos.y + Math.sin(angles[i]) * r;
//            graphics.beginFill(color, alphaRange.transfomrValue(t));
//            graphics.drawCircle(x, y, sizeRange.transfomrValue(t));
//            graphics.endFill();
//        }
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