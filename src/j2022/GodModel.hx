package j2022;
import j2022.Cloud.CloudStates;
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
    public var cloudSpawner:CloudSpawner;

    public function new() {
        player = new Player();
        bullet = new Bullet();
        clouds = new Clouds(this);
        cloudSpawner = new CloudSpawner(clouds);
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

    public function hitTHeCloud(c:Cloud) {
        c.changeState(CloudStates.disappearing);
    }
}

class Clouds implements Updatable {
    public var clouds = new Array<Cloud>();
    public var moveSystems = new Array<CloudMoveSystem>();
    var model:GodModel;

    public function new(m) {
        model = m;
        var round = new RoundCloudMoveSystem();
        round.center.y = -350;
        moveSystems.push(round);

        var dizzy = new DizzyMove();
        moveSystems.push(dizzy);

    }

    public function createCloud() {
        var c = new Cloud(model);
        clouds.push(c);
        model.view.addChild(c.view);
        trace("total " + clouds.length);
        return c;
    }

    public function update(dt:Float):Void {
        for (s in moveSystems) {
            s.update(dt);
        }

        for (c in clouds) {
            if (c.currentStateName == inactive)
                continue;
            c.update(dt);
            var b = model.bullet;
            var sthld = (c.r + b.r) * (c.r + b.r);
            if (c.pos.distSq(b.pos) < sthld) {
                model.hitTHeCloud(c);
            }
        }
    }
}

class CloudSpawner {
    public var inactiveClouds = [];
    var cooldown = 120;
    var nextTick = 0;
    var clouds:Clouds;
    var randomInitializer = [];
    var max = 6;

    public function new(c) {
        clouds = c;
        randomInitializer.push((c:Cloud) -> {
            c.r = 16;
            clouds.moveSystems[0].add(c);
            clouds.moveSystems[1].add(c);
        });


//        randomInitializer.push((c:Cloud) -> {
//            c.r = 32;
//            clouds.moveSystems[0].add(c);
//        });
    }

    public function update(dt) {
        var activeCount = clouds.clouds.length - inactiveClouds.length;
        if (GlobalTime.tick > nextTick && activeCount < max)
            spawn();
    }

    function rndInit(c) {
        var i = Math.floor(Math.random() * (randomInitializer.length ));
        randomInitializer[i](c);
    }

    function spawn() {
        var c =
        if (inactiveClouds.length < 1) {
            clouds.createCloud();
        } else inactiveClouds.pop();

        rndInit(c);
        c.changeState(active);
        nextTick += cooldown;

    }


}

class GlobalTime {
    public static var time:Float;
    public static var tick:Int;

    public static function reset() {
        time = 0;
        tick = 0;
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
