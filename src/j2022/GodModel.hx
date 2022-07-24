package j2022;
import utils.Updatable;
import input.GamepadInput;
import flash.ui.Keyboard;
import input.KeyboardInput;
import input.MetaInput;
import utils.KeyPoll;
import input.Input;
import j2022.CloudMove;
class GodModel {
    public var view:GameView;
    public var player:Player;
    public var bullet:Bullet;
    public var input:Input;
    public var baseline:Float;
    public var gravity = 400;
    public var clouds:Clouds;

    public function new() {
        player = new Player();
        bullet = new Bullet();
        clouds = new Clouds();
        view = new GameView(this);
        baseline = 0;//openfl.Lib.current.stage.stageHeight - 30;
        var keys = new KeyPoll(openfl.Lib.current.stage);
        input = new MetaInput().add(
            new KeyboardInput({
                forward:Keyboard.RIGHT,
                backward:Keyboard.LEFT,
                up:Keyboard.UP,
                down:Keyboard.DOWN,
            }, keys, [GameButtons.jump => Keyboard.SPACE ])).add(
            new GamepadInput(GamepadAxis.LEFT_X, GamepadAxis.LEFT_Y, [ GameButtons.jump => GamepadButton.A ])
        );
    }

    public function reset() {
        player.reset();
        player.pos.x = baseline;
        bullet.reset();
        bullet.pos.x = baseline;
        view.reset();
    }
}

class Clouds implements Updatable {
    public var clouds = new Array<Cloud>();
    var moveSystems = new Array<CloudMoveSystem>();

    public function new() {
        var round = new RoundCloudMoveSystem();
        round.center.y = -350;
        moveSystems.push(round);
        for (i in 0...4) {
            var c = new Cloud();
            clouds.push(c);
            round.add(c);
//            clouds[i].y = -100;
        }
    }

    public function update(dt:Float):Void {
        for (s in moveSystems) {
            s.update(dt);
        }
        for (c in clouds) {
            c.update(dt);
//            if (c.pos)
        }
    }
}


class Bullet extends GameObj {
}
class Player extends GameObj {
    public var bullet:Bullet;
}
class GameObj {
    public var color:Int = 0;
    public var pos = new Pos();
    public var speed = new Pos();
//    public var x:Float;
//    public var y:Float;
//    public var vx:Float;
//    public var vy:Float;
    public var r:Float = 16;

    public function new() {
        reset();
    }

    public function reset() {
        pos.reset();
        speed.reset();
    }
}
