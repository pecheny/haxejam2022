package j2022;
class CloudMove {
    public function new() {
    }
}

class CloudMoveSystemBase implements CloudMoveSystem {
    var clouds:Array<Cloud> = [];

    public function update(dt:Float):Void {
    }

    public function add(c:Cloud):Void {
        if (clouds.contains(c))
            throw "Weong";
        clouds.push(c);
        c.offsets[this] = new Pos();
    }

    public function remove(c:Cloud):Void {
        clouds.remove(c);
        c.offsets.remove(this);
    }
}
interface CloudMoveSystem {
    function add(c:Cloud):Void;

    function remove(c:Cloud):Void;

    function update(dt:Float):Void;
}

class RoundCloudMoveSystem extends CloudMoveSystemBase implements CloudMoveSystem {
    var phase:Float = 0;
    var speed = Math.PI / 25;
    public var center = new Pos();

    public var r = 130;


    public function new() {}

    override public function update(dt:Float) {
        phase += speed * dt;
        while (phase > Math.PI * 2) phase -= Math.PI * 2;

        var angleStep = Math.PI * 2 / clouds.length;
        for (i in 0...clouds.length) {
            var angle = phase + i * angleStep;
            var c = clouds[i];
            var tp = c.offsets[this];
            tp.x = center.x + Math.cos(angle) * r;
            tp.y = center.y + Math.sin(angle) * r;

        }
    }
}

class DizzyMove implements CloudMoveSystem extends CloudMoveSystemBase {

    public var r:Float = 40;
    public var speed = 100;
    public var rndDelta = Math.PI / 5;

    public function new() {}

    override public function update(dt:Float):Void {
        for (c in clouds) {
            var pws:PosWithVel = cast c.offsets[this];
            pws.x += pws.vel.x * dt;
            pws.y += pws.vel.y * dt;

            if (pws.magnSq() > r * r) {
                pws.vel.x *= -1;
                pws.vel.y *= -1;
//                var angle = Math.random() * rndDelta - (rndDelta / 2);
//
//                var newX = pws.vel.x * Math.cos(angle) - pws.vel.y * Math.sin(angle);
//                var newY = pws.vel.x * Math.sin(angle) + pws.vel.y * Math.cos(angle) ;
//
//                pws.vel.x = newX;
//                pws.vel.y = newX;
            }

        }
    }

    override public function add(c:Cloud):Void {
        super.add(c);
        var pws = new PosWithVel();
        c.offsets[this] = pws;
        var ang = Math.random() * Math.PI * 2;
        pws.vel.x = Math.cos(ang) * speed;
        pws.vel.y = Math.sin(ang) * speed;
    }

}

class PosWithVel extends Pos {
    public var vel = new Pos();
}

class Pos {
    public var x:Float = 0;
    public var y:Float = 0;

    public function new() {}

    public function reset() {
        x = 0;
        y = 0;
    }

    public inline function magnSq() {
        return x * x + y * y;
    }

    public inline function distSq(o:Pos) {
        return (o.x - x) * (o.x - x)
        + (o.y - y) * (o.y - y);
    }
}
