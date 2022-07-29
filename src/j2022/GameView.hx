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
        distraction.y = - model.fHeight + 30;

        var controls = new Controls();
        controls.width = model.fWidth;
        controls.height = 120;
//        controls.x = -model.fWidth/2;
        controls.alpha = 0.2;
        controls.y = openfl.Lib.current.stage.stageHeight;
        addChild(controls);
    }

    public function reset() {
        canvas.x = openfl.Lib.current.stage.stageWidth / 2;
        canvas.y = openfl.Lib.current.stage.stageHeight - 30;
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
//        graphics.drawRect(-o.r, -o.r, o.r*2, o.r*2);
        graphics.endFill();
        super();
    }
}
