package j2022;
import flash.display.DisplayObject;
import j2022.GodModel;
import openfl.display.Sprite;
import j2022.Distraction;
class GameView extends Sprite {
    public var player:PlayerView;
    public var bullet:PlayerView;
    public var distraction:DistractionView;
    public var canvas = new Sprite();
    var model:GodModel;
    public function new(m:GodModel) {
        super();
        addChild(canvas);
        canvas.mouseEnabled = false;
        this.model = m;
        player = new PlayerView(m.player);
        canvas.addChild(player);
        bullet = new PlayerView(m.bullet);
        canvas.addChild(bullet);
        distraction = new DistractionView();
        canvas.addChild(distraction);

        var controls = new Controls();
        addChild(controls);
    }

    public function reset() {
        x = openfl.Lib.current.stage.stageWidth / 2;
        y = openfl.Lib.current.stage.stageHeight - 30;
    }

    public function add(d:DisplayObject) {
        canvas.addChild(d);
    }
}

class PlayerView extends Sprite {
    public function new(o:GameObj) {
        trace(graphics);
        graphics.clear();
        this.graphics.beginFill(o.color, 1);
        graphics.drawCircle(0, 0, o.r);
        graphics.endFill();
        super();
    }
}
