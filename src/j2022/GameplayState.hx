package j2022;
import al.al2d.Axis2D;
import input.Input.GameButtons;
import j2022.GameFsm;
import j2022.GameView;
import j2022.GodModel;
import utils.Mathu;
class GameplayState extends GameState {
    var godModel:GodModel;
    var dt = 1 / 60;
    var maxSpd = 100;
    var acc = 100;
    var fWidth = 600;

    override public function update(t:Float):Void {
        var p = godModel.player;
        var i = godModel.input;

        p.vx = Mathu.clamp(p.vx + i.getDirProjection(horizontal) * acc * dt, -maxSpd, maxSpd);
        p.x = Mathu.clamp(p.x + p.vx * dt, -fWidth / 2, fWidth / 2);

        var v = godModel.view.player;
        v.x = p.x;
        v.y = p.y;
        handleBullet(godModel.bullet, godModel.view.bullet);
    }


    function handleBullet(b:Bullet, v:PlayerView) {
        var p = godModel.player;
        var i = godModel.input;
        if (p.bullet == b) { // bullet is carried by player
            b.x = p.x;
            b.y = p.y - 10;
            if (i.pressed(GameButtons.jump)) lauch(b);
        } else if (false) { // handle player hit

        } else if (b.y < godModel.baseline - 1) { // handle ballistics

            trace(b.y  + " " + godModel.baseline);
            b.x += b.vx * dt;
            if (Math.abs(b.x) > fWidth / 2) {
                b.x = Mathu.clamp(b.x, -fWidth / 2, fWidth / 2);
                b.vx *= -1;
            }
            b.vy += godModel.gravity * dt;
            b.y += b.vy * dt;
            if (b.y > godModel.baseline) b.y = godModel.baseline;
        } else { // idle
            trace(b.y);
            if (Math.abs(b.x - p.x) < (b.r + p.r)) pick(b); // check dist and pick
        }
        v.x = b.x;
        v.y = b.y;
    }

    function pick(b:Bullet) {
        var p = godModel.player;
        if (p.bullet != null)
            return;
        p.bullet = b;
    }

    function lauch(b:Bullet) {
        var p = godModel.player;
        if (p.bullet != b) {throw "wrong";}
        p.bullet = null;
        b.vx = p.vx;
        b.vy = -300;
    }

    override public function onEnter():Void {
        godModel = fsm.model;
        openfl.Lib.current.addChild(godModel.view);
//        var player = GodModel.instance.view.player;
        godModel.reset();
    }

    override public function onExit():Void {
        openfl.Lib.current.removeChild(godModel.view);
    }
}


