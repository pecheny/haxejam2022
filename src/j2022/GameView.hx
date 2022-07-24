package j2022;
import j2022.GodModel;
import openfl.display.Sprite;
class GameView extends Sprite {
    public var player:PlayerView;
    public var bullet:PlayerView;
    var model:GodModel;
    public function new(m:GodModel) {
        super();
        this.model = m;
        player = new PlayerView(m.player);
        addChild(player);
        bullet = new PlayerView(m.bullet);
        addChild(bullet);

        for (c in m.clouds.clouds)
            addChild(c.view);
    }

    public function reset() {
        x = openfl.Lib.current.stage.stageWidth / 2;
        y = openfl.Lib.current.stage.stageHeight - 30;
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
