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
    var maxSpd = 400;
    var maxBVertSpd = 1600;
    var acc = 500;
    var fWidth = 600;
    var fHeight = 800;

    override public function update(t:Float):Void {
        GlobalTime.time += dt;
        GlobalTime.tick ++;

//        handlePlayerSimple();
        handlePlayer();
        handleBullet(godModel.bullet, godModel.view.bullet);
        godModel.clouds.update(dt);
        godModel.cloudSpawner.update(dt);
    }

    function handlePlayer() {
        var p = godModel.player;
        var i = godModel.input;
        p.speed.x = Mathu.clamp(p.speed.x + i.getDirProjection(horizontal) * acc * dt, -maxSpd, maxSpd);
        if (i.getDirProjection(horizontal) == 0) {
            p.speed.x *= 0.9;
            if (Math.abs(p.speed.x) < 1)
                p.speed.x = 0;
        }
        p.pos.x = Mathu.clamp(p.pos.x + p.speed.x * dt, -fWidth / 2, fWidth / 2);
        if (Math.abs(p.pos.x) > (fWidth / 2 - 1)) {
            p.speed.x = 0;
        }
        var v = godModel.view.player;
        v.x = p.pos.x;
        v.y = p.pos.y;
    }

    function handlePlayerSimple() {
        var p = godModel.player;
        var i = godModel.input;
        p.speed.x = i.getDirProjection(horizontal) * 200;
        p.pos.x = Mathu.clamp(p.pos.x + dt * p.speed.x, -fWidth / 2, fWidth / 2);

        if (Math.abs(p.pos.x) > (fWidth / 2 - 1)) {
            p.speed.x = 0;
        }
        var v = godModel.view.player;
        v.x = p.pos.x;
        v.y = p.pos.y;
    }


    function handleBullet(b:Bullet, v:PlayerView) {
        var p = godModel.player;
        var i = godModel.input;
        var thld = ( p.r + b.r ) * ( p.r + b.r );
        var dst = p.pos.distSq(b.pos);
        if (p.bullet == b) { // bullet is carried by player
            b.pos.x = p.pos.x;
            b.pos.y = p.pos.y - 10;
            if (i.pressed(GameButtons.jump)) lauch(b);
        } else if (dst < thld && b.speed.y > 0) { // handle player hit
            // ===  speed reverse
//            b.speed.x *= -1;
//            b.speed.y = Mathu.clamp(b.speed.y * -1.2, -maxBVertSpd, 0);

            // === axis of centers
            var magn = Mathu.clamp(Math.sqrt(b.speed.magnSq() * 1.2) ,0, maxBVertSpd);
            b.speed.x = b.pos.x - p.pos.x;
            b.speed.y = b.pos.y - p.pos.y;
            b.speed.normalize(magn);

        } else if (b.pos.y < godModel.baseline - 1) { // handle ballistics
            b.pos.x += b.speed.x * dt;
            if (Math.abs(b.pos.x) > fWidth / 2) {
                b.pos.x = Mathu.clamp(b.pos.x, -fWidth / 2, fWidth / 2);
                b.speed.x *= -1;
            }
            b.speed.y += godModel.gravity * dt;
            b.pos.y += b.speed.y * dt;
            if (b.pos.y < -fHeight && b.speed.y < 0) // hit with ceil
                b.speed.y *= -1;
            if (b.pos.y > godModel.baseline) b.pos.y = godModel.baseline;
        } else { // idle
            if (Math.abs(b.pos.x - p.pos.x) < (b.r + p.r)) pick(b); // check dist and pick
        }
        v.x = b.pos.x;
        v.y = b.pos.y;
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
        b.speed.x = p.speed.x * 2.4;
        b.speed.y = -600;
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


