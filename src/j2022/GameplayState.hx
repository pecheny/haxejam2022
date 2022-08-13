package j2022;
import Axis2D;
import flash.ui.Keyboard;
import input.Input.GameButtons;
import j2022.GameFsm;
import j2022.GameView;
import j2022.GodModel;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import utils.Mathu;
class GameplayState extends GameState {
    var godModel:GodModel;
    var dt = 1 / 60;
    var maxSpd = 600;
    var maxBVertSpd = 1000;
    var acc = 1700;
    var openingDur = 1.;
    var paused = false;

    override public function update(t:Float):Void {
        if (paused)
            return;
        GlobalTime.time += dt;
        GlobalTime.tick ++;
        if (GlobalTime.time < openingDur) {
            godModel.view.curtain.scaleX = 1 - (GlobalTime.time / openingDur);
        }


//        handlePlayerSimple();
        handlePlayer();
        handleBullet(godModel.bullet, godModel.view.bullet);
        godModel.clouds.update(dt);
        godModel.distraction.update(dt);
        godModel.cloudSpawner.update(dt);
    }


    inline function stunned() {
        return godModel.stunEnd > GlobalTime.tick;
    }

    inline function stun() {
        godModel.sounds.stun();
        godModel.stunEnd = GlobalTime.tick + 60 * 3;
    }

    var playerJustHit = false;

    function handlePlayer() {
        var p = godModel.player;
        var i = godModel.input;
        var v = godModel.view.player;
        if (stunned()) {
            v.y = p.pos.y + 10;
            v.update(Stunned);
            return;
        }
        var projection = i.getDirProjection(horizontal);
        p.speed.x = Mathu.clamp(p.speed.x + projection * acc * dt, -maxSpd, maxSpd);
        if (projection == 0 || projection * p.speed.x < 0) {
            p.speed.x *= 0.9;
            if (Math.abs(p.speed.x) < 1)
                p.speed.x = 0;
        }
        p.pos.x = Mathu.clamp(p.pos.x + p.speed.x * dt, -godModel.fWidth / 2, godModel.fWidth / 2);
        if (Math.abs(p.pos.x) > (godModel.fWidth / 2 - 1)) {
            p.speed.x = 0;
        }
        if (playerJustHit) {
            playerJustHit = false;
            v.update(Hit);
        }
        else
            v.update(Active);
        v.x = p.pos.x;
        v.y = p.pos.y;
    }

    function handlePlayerSimple() {
        var p = godModel.player;
        var i = godModel.input;
        p.speed.x = i.getDirProjection(horizontal) * 200;
        p.pos.x = Mathu.clamp(p.pos.x + dt * p.speed.x, -godModel.fWidth / 2, godModel.fWidth / 2);

        if (Math.abs(p.pos.x) > (godModel.fWidth / 2 - 1)) {
            p.speed.x = 0;
        }
        var v = godModel.view.player;
        v.x = p.pos.x;
        v.y = p.pos.y;
    }

    var wasIdle = false;

    function handleBullet(b:Bullet, v:BulletView) {
        var p = godModel.player;
        var i = godModel.input;
        var thld = ( p.r + b.r ) * ( p.r + b.r );
        var dst = p.pos.distSq(b.pos);
        if (p.bullet == b) { // bullet is carried by player
            b.pos.x = p.pos.x;
            b.pos.y = p.pos.y - 10;
            if (i.pressed(GameButtons.jump)) lauch(b);
        } else if (dst < thld && b.speed.y > 0 && !stunned()) { // handle player hit
            // ===  speed reverse
//            b.speed.x *= -1;
//            b.speed.y = Mathu.clamp(b.speed.y * -1.2, -maxBVertSpd, 0);

            // === axis of centers
            var magn = Mathu.clamp(Math.sqrt(b.speed.magnSq() * 1.2), 0, maxBVertSpd);
            if (b.speed.x * b.speed.x < 1 && magn == maxBVertSpd) {
                b.speed.x = 0;
                b.speed.y = 0;
                stun();
            } else {
                b.speed.x = b.pos.x - p.pos.x;
                b.speed.y = b.pos.y - p.pos.y;

                b.speed.normalize(magn);
                playerJustHit = true;
                godModel.sounds.ballCharHit();
            }
        } else if (b.pos.y <= godModel.baseline - 1) { // handle ballistics
            wasIdle = false;
            b.pos.x += b.speed.x * dt;
            if (Math.abs(b.pos.x) > godModel.fWidth / 2) {
                b.pos.x = Mathu.clamp(b.pos.x, -godModel.fWidth / 2, godModel.fWidth / 2);
                b.speed.x *= -1;
                godModel.sounds.ballWallHit();
            }
            b.speed.y += godModel.gravity * dt;
            b.pos.y += b.speed.y * dt;
            if (b.pos.y < -godModel.fHeight && b.speed.y < 0) // hit with ceil
                b.speed.y *= -1;
            if (b.pos.y > godModel.baseline) b.pos.y = godModel.baseline;
        } else { // idle
            if (!wasIdle) {
                wasIdle = true;
                godModel.sounds.ballWallHit();
            }
            if (!stunned() && Math.abs(b.pos.x - p.pos.x) < (b.r + p.r)) { // check dist and pick
                godModel.sounds.pick();
                pick(b);
            }
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
    }

    override public function onExit():Void {
        openfl.Lib.current.removeChild(godModel.view);
    }

    override public function keyUpHandler(e:KeyboardEvent):Void {
        super.keyUpHandler(e);
        switch e.keyCode {
            case Keyboard.P : fsm.changeState(PAUSED);
        }
    }


}


class PausedState extends GameState {

    override public function keyUpHandler(e:KeyboardEvent):Void {
        super.keyUpHandler(e);
        switch e.keyCode {
            case Keyboard.P : fsm.changeState(GAMEPLAY);
        }
    }

    override public function onEnter():Void {
        openfl.Lib.current.addChild(fsm.model.view);
        fsm.model.sounds.pause();
    }

    override public function onExit():Void {
        openfl.Lib.current.removeChild(fsm.model.view);
        fsm.model.sounds.resume();
    }

    override public function mouseDownHandler(e:MouseEvent):Void {
        super.mouseDownHandler(e);
    }
}
