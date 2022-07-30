package j2022;
import input.DummyTouch;
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
    public var distraction:Distraction;
    public var fsm:GameFsm;
    public var sounds:SoundSystem;

    public var fWidth = 600;
    public var fHeight = 800;

    public function new() {
        player = new Player();
        bullet = new Bullet();
        clouds = new Clouds(this);
        cloudSpawner = new CloudSpawner(clouds);
        distraction = new Distraction(this);
        view = new GameView(this);

        sounds = new SoundSystem();
        sounds.startMusic();

        baseline = 0;//openfl.Lib.current.stage.stageHeight - 30;
        var keys = new KeyPoll(openfl.Lib.current.stage);
        input = new MetaInput()
        .add(
            new KeyboardInput({
                forward:Keyboard.RIGHT,
                backward:Keyboard.LEFT,
                up:Keyboard.UP,
                down:Keyboard.DOWN,
            }, keys, [GameButtons.jump => Keyboard.SPACE ]))
        .add(new GamepadInput(GamepadAxis.LEFT_X, GamepadAxis.LEFT_Y, [ GameButtons.jump => GamepadButton.A ]))
        .add(new DummyTouch(this));
    }

    public function reset() {
        player.reset();
        player.pos.x = baseline;
        bullet.reset();
        bullet.pos.x = baseline;
        view.reset();
        distraction.reset();
        clouds.reset();
        cloudSpawner.reset();
        GlobalTime.reset();
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
        round.phase = 2;
        moveSystems.push(round);

        var dizzy = new DizzyMove();
        moveSystems.push(dizzy);

        var pong = new PongMoveSystem();
        pong.bounds = {
            l:-model.fWidth / 2,
            r:model.fWidth / 2,
            b:0,
            t:-model.fHeight,
        }
        moveSystems.push(pong);

//        var pong2 = new PongMoveSystem();
//        pong2.bounds = {
//            l:-model.fWidth / 4,
//            r:model.fWidth / 4,
//            b:- model.fHeight / 4,
//            t:- 3*model.fHeight / 4,
//        }
//        moveSystems.push(pong);

        var round2 = new RoundCloudMoveSystem();
        round2.center.y = -500;
        moveSystems.push(round2);

    }

    public function reset() {
        for (c in clouds) {
            c.changeState(inactive);
            if (!model.cloudSpawner.inactiveClouds.contains(c))
                model.cloudSpawner.inactiveClouds.push(c);
        }
    }

    public function createCloud() {
        var c = new Cloud(model);
        clouds.push(c);
        model.view.add(c.view);
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
            if (c.currentStateName == active && c.pos.distSq(b.pos) < sthld) {
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
    var max = 26;

    public function reset() {
        nextTick = 0;
    }

    public function new(c) {
        clouds = c;
        randomInitializer.push((c:Cloud) -> {
            c.r = 16;
            clouds.moveSystems[0].add(c);
            clouds.moveSystems[1].add(c);
        });

        randomInitializer.push((c:Cloud) -> {
            c.r = 32;
            clouds.moveSystems[3].add(c);
        });

        randomInitializer.push((c:Cloud) -> {
            c.r = 32;
            clouds.moveSystems[2].add(c);
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


typedef Bounds = {
        l:Float,
        r:Float,
        t:Float,
        b:Float,
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
    public function new() {
        super();
        color = 0x201010;
        r = 8;
    }
}
class Player extends GameObj {
    public var bullet:Bullet;

    public function new() {
        super();
        color = 0xa0a0a0;
        r = 24;
    }
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
