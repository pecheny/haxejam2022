package j2022;
import j2022.GodModel;
class CloudMove {
    public function new() {
    }
}

class CloudMoveSystemBase implements CloudMoveSystem {
    var clouds:Array<Cloud> = [];

    public function new() {}

    public function update(dt:Float):Void {
    }

    public function add(c:Cloud):Void {
        if (clouds.contains(c))
            throw "Weong";
        clouds.push(c);
        c.offsets[this] = new PosWithVel();
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
    public var phase:Float = 0;
    var speed = Math.PI / 25;
    public var center = new Pos();

    public var r = 130;

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

    override public function add(c:Cloud):Void {
        super.add(c);
        var pv = c.offsets[this];
        if (clouds.length > 1) {
            var prev = clouds[clouds.length - 2].offsets[this];
            pv.x = prev.x;
            pv.y = prev.y;
        } else {
            var tp = c.offsets[this];
            tp.x = center.x ;
            tp.y = center.y -r;
        }

        c.pos.x += pv.x;
        c.pos.y += pv.y;
    }


}

class PongMoveSystem extends CloudMoveSystemBase {
    public var bounds:Bounds;

    override public function update(dt:Float):Void {
        for (c in clouds) {
            var pv:PosWithVel = cast c.offsets[this];
            pv.x += pv.vel.x * dt;
            if (pv.x < bounds.l || pv.x > bounds.r)
                pv.vel.x *= -1;
            pv.y += pv.vel.y * dt;
            if (pv.y < bounds.t || pv.y > bounds.b)
                pv.vel.y *= -1;

        }
    }

    override public function add(c:Cloud):Void {
        super.add(c);
        var pv = c.offsets[this];
        var w = 500;
        pv.x = Math.random() * w - w / 2;
        pv.y = -Math.random() * 300 - 100;
        pv.vel.x = Math.random() * 100;
        pv.vel.y = Math.random() * 100;
        c.pos.x += pv.x;
        c.pos.y += pv.y;
    }

}

class DizzyMove implements CloudMoveSystem extends CloudMoveSystemBase {

    public var r:Float = 40;
    public var speed = 100;
    public var rndDelta = Math.PI / 5;

    override public function update(dt:Float):Void {
        for (c in clouds) {
            var pv:PosWithVel = cast c.offsets[this];
            pv.x += pv.vel.x * dt;
            pv.y += pv.vel.y * dt;

            if (pv.magnSq() > r * r) {
                pv.vel.x *= -1;
                pv.vel.y *= -1;
//                var angle = Math.random() * rndDelta - (rndDelta / 2);
//
//                var newX = pv.vel.x * Math.cos(angle) - pv.vel.y * Math.sin(angle);
//                var newY = pv.vel.x * Math.sin(angle) + pv.vel.y * Math.cos(angle) ;
//
//                pv.vel.x = newX;
//                pv.vel.y = newX;
            }

        }
    }

    override public function add(c:Cloud):Void {
        super.add(c);
        var pv = new PosWithVel();
        c.offsets[this] = pv;
        var ang = Math.random() * Math.PI * 2;
        pv.vel.x = Math.cos(ang) * speed;
        pv.vel.y = Math.sin(ang) * speed;
        c.pos.x += pv.x;
        c.pos.y += pv.y;
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

    public inline function normalize(length:Float = 1) {
        if (x != 0. || y != 0.) {
            var norm = length / Math.sqrt(x * x + y * y);
            x *= norm;
            y *= norm;
        }
        return cast this;
    }

    public function toString() return '[$x, $y]';
}
