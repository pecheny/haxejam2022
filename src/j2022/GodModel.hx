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
    public var cloudSpawner:CloudSpawners;
    public var distraction:Distraction;
    public var fsm:GameFsm;
    public var sounds:SoundSystem;

    public var fWidth = 600;
    public var fHeight = 800;

    public function new() {
        player = new Player();
        bullet = new Bullet();
        clouds = new Clouds(this);
        cloudSpawner = new CloudSpawners(clouds);
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
    public var model:GodModel;

    public function new(m) {
        model = m;
        var round = new RoundCloudMoveSystem();
        round.center.y = -350;
        round.phase = 2;
        moveSystems.push(round);


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

class CloudSpawners {
    public var inactiveClouds = [];
    public var dizzy:DizzyMove;
    var spawners:Array<CloudSpawner> = [];
    var clouds:Clouds;

    public function new(c) {
        clouds = c;
        dizzy = new DizzyMove();
        clouds.moveSystems.push(dizzy);

        spawners.push(new SuicidalSpawner(clouds, this));
        spawners.push(new FlySpawner(clouds, this));
        spawners.push(new DesiresSpawner(clouds, this));
        spawners.push(new DangerSpawner(clouds, this));

    }

    public function getCloud():Cloud {
        return if (inactiveClouds.length < 1) {
            clouds.createCloud();
        } else inactiveClouds.pop();
    }

    public function update(dt) {
        for (s in spawners)
            s.update();
    }

    public function reset() {
        for (s in spawners)
            s.reset();
    }

    public inline function activeCount() {
        var activeCount = clouds.clouds.length - inactiveClouds.length;
        return activeCount;
    }
}

class SuicidalSpawner extends CloudSpawner {
    var round:RoundCloudMoveSystem;
    var nextSpawn:Int;

    public function new(clouds:Clouds, factory) {
        super(factory);
        fr1 = 8;
        fr2 = 12;
        round = new RoundCloudMoveSystem();
        round.center.y = -350;
        round.phase = 2;
        clouds.moveSystems.push(round);
    }

    override public function update() {
        if (GlobalTime.tick > nextSpawn)
            spawn();
    }

    function spawn() {
        nextSpawn += getCooldown();
        if (round.clouds.length > 10)
            return;
        var c = spawners.getCloud();
        c.reset(Suicidal);
        c.r = 32;
        c.viewId = getFr();
        round.add(c);
        c.changeState(active);
    }

    function getCooldown() {
        return if (GlobalTime.tick < 20 * 60)
            5 * 60 ;
        else
            10 * 60;
    }

    override public function reset() {
        nextSpawn = 20;
    }
}

class FlySpawner extends CloudSpawner {
    var pong:PongMoveSystem;
    var nextSpawn:Int;

    public function new(clouds:Clouds, factory) {
        super(factory);
        fr1 = 12;
        fr2 = 15;
        pong = new PongMoveSystem();
        var model = clouds.model;
        pong.bounds = {
            l:-model.fWidth / 2,
            r:model.fWidth / 2,
            b:0,
            t:-model.fHeight,
        }
        clouds.moveSystems.push(pong);
    }

    override public function update() {
        if (GlobalTime.tick > nextSpawn)
            spawn();
    }

    function spawn() {
        nextSpawn += getCooldown();
        if (pong.clouds.length > 10)
            return;
        var c = spawners.getCloud();
        c.reset(Fly);
        c.r = 16;
        c.viewId = getFr();
        pong.add(c);
        if (Math.random() > 0.5)
            spawners.dizzy.add(c);
        c.changeState(active);
    }

    function getCooldown() {
        return
            if (GlobalTime.tick < 20 * 60)
                Std.int(Math.random() * 5 * 60) ;
            else
                10 * 60;
    }

    override public function reset() {
        nextSpawn = 60 * 5;
    }
}

class DesiresSpawner extends CloudSpawner {
    var pong:PongMoveSystem;
    var nextSpawn:Int;

    public function new(clouds:Clouds, factory) {
        super(factory);
        fr1 = 0;
        fr2 = 7;
        pong = new PongMoveSystem();
        var model = clouds.model;
        pong.initialSpeedProjection = axis -> {
            return switch axis {
                case Axis2D.horizontal: 100 + 300 * Math.random();
                case Axis2D.vertical: 200 * Math.random();
            }
        }
        pong.bounds = {
            l:-model.fWidth / 2,
            r:model.fWidth / 2,
            b:0,
            t:-model.fHeight,
        }
        clouds.moveSystems.push(pong);
    }

    override public function update() {
        if (GlobalTime.tick > nextSpawn)
            spawn();
    }

    function spawn() {
        nextSpawn += getCooldown();
        if (pong.clouds.length > 10)
            return;
        var c = spawners.getCloud();
        c.reset(Desire);
        c.viewId = getFr();
        c.r = 32;
        pong.add(c);
        if (Math.random() > 0.5)
            spawners.dizzy.add(c);
        c.changeState(active);
    }

    function getCooldown() {
        return
            if (GlobalTime.tick < 20 * 60)
                Std.int(Math.random() * 5 * 60) ;
            else
                5 * 60;
    }

    override public function reset() {
        nextSpawn = 60 * 15;
    }
}
class DangerSpawner extends CloudSpawner {
    var origins = new CloudMoveSystemBase();
    var nextSpawn:Int;
    var hpoints:Array<Float>;
    var vpoints:Array<Float>;

    public function new(clouds:Clouds, factory) {
        super(factory);
        fr1 = 7;
        fr2 = 7;
        var w = clouds.model.fWidth;
        var h = clouds.model.fHeight;
        hpoints = [-w / 2 * 0.66, w / 2 * 0.66];
        vpoints = [-h * 0.75];

    }

    override public function update() {
        if (GlobalTime.tick > nextSpawn)
            spawn();
    }

    function spawn() {
        nextSpawn += getCooldown();
        var c = spawners.getCloud();
        c.reset(Toilet);
        c.r = 40;
        c.distraction = 10;
//        trace(vpoints[Math.floor(Math.random() * vpoints.length)]);
        c.pos.x = hpoints[Math.floor(Math.random() * hpoints.length)];
        c.pos.y = vpoints[Math.floor(Math.random() * vpoints.length)];
        origins.add(c);
        c.viewId = getFr();
        var ofs = c.offsets[origins];
        ofs.x = c.pos.x;
        ofs.y = c.pos.y;
        spawners.dizzy.add(c);
        c.changeState(active);
    }

    function getCooldown() {
        return
            15 * 60 + Std.int(Math.random() * 15 * 60) ;
    }

    override public function reset() {
        nextSpawn = 60 * 50;
    }
}

class CloudSpawner {
    var spawners:CloudSpawners;
    var fr1:Int = 0;
    var fr2:Int = 0;

    public function new(fac) {
        this.spawners = fac;
    }

    public function update() {}

    public function reset() {}

    function getFr() {
        return fr1 + Math.floor(Math.random() * (fr2 - fr1));
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

@:enum abstract DistractionType(Int) to Int from Int {
    var Suicidal;
    var Desire;
    var Toilet;
    var Fly;
}

@:enum abstract FaceType(Int) to Int {
    var face_sad = 7;
    var face_calm = 6;
    var face_passionate = 1;
    var face_distracted = 2;
    var face_panic = 3;
    var face_susp = 4;
}