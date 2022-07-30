package j2022;
import flash.display.MovieClip;
import flash.display.DisplayObject;
import j2022.GodModel;
import openfl.display.Sprite;
import j2022.Distraction;
class GameView extends Sprite {
    public var player:PlayerView;
    public var bullet:BulletView;
    public var distraction:DistractionView;
    public var canvas = new Sprite();
    public var curtain:Sprite;
    var screen:Sprite;
    var model:GodModel;
    var face:MovieClip;

    public function setFace(f:FaceType) {
        face.gotoAndStop(f);
    }

    public function new(m:GodModel) {
        super();
        screen = new Gameplay();
        screen.x = openfl.Lib.current.stage.stageWidth / 2;
        screen.y = openfl.Lib.current.stage.stageHeight / 2;
        addChild(screen);

        curtain = cast screen.getChildByName("_curtain");

        face = cast screen.getChildByName("_face");
        face.stop();

        var _distraction = cast screen.getChildByName("_distraction");

        addChild(canvas);
        canvas.mouseEnabled = false;
        this.model = m;
        var pl = screen.getChildByName("_player");
        pl.x = pl.y = 0;
        player = new PlayerView(m.player, cast pl);
        canvas.addChild(player);
        bullet = new BulletView(m.bullet);
        canvas.addChild(bullet);
        distraction = new DistractionView(_distraction);
        canvas.addChild(distraction);
        distraction.y = -model.fHeight + 30;

//        var controls = new Controls();
//        controls.width = model.fWidth;
//        controls.height = 120;
////        controls.x = -model.fWidth/2;
//        controls.alpha = 0.2;
//        controls.y = openfl.Lib.current.stage.stageHeight;
        var controls = screen.getChildByName("_controls");
        controls.x += openfl.Lib.current.stage.stageWidth / 2;
        controls.y += openfl.Lib.current.stage.stageHeight / 2;
        addChild(controls);

//        player.addChild(pl);

    }

    public function reset() {
        canvas.x = openfl.Lib.current.stage.stageWidth / 2;
        canvas.y = openfl.Lib.current.stage.stageHeight - 30;
    }

    public function add(d:DisplayObject) {
        canvas.addChild(d);
    }
}

enum PlayerState {
    Hit;
    Stunned;
    Active;
}
class PlayerView extends Sprite {
    var asset:MovieClip;

    public function new(o:GameObj, v:MovieClip) {
        super();
        asset = v;
        addChild(v);
        v.stop();
    }

    function animateRegion(f1, f2) {
        if (GlobalTime.tick % 10 == 0) {
            var fr = asset.currentFrame < f2 ? asset.currentFrame + 1 : f1;
            asset.gotoAndStop(fr);
        }
    }

    public function update(state:PlayerState) {
        switch state {
            case Stunned:animateRegion(3, 4);
            case Active:    animateRegion(1, 2);
            case Hit:    asset.gotoAndStop(5);
        }
    }
}
class BulletView extends Sprite {
    public function new(o:GameObj) {
        graphics.clear();
        this.graphics.beginFill(o.color, 1);
        graphics.drawCircle(0, 0, o.r);
//        graphics.drawRect(-o.r, -o.r, o.r*2, o.r*2);
        graphics.endFill();
        super();
    }
}
