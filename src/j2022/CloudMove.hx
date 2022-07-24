package j2022;
class CloudMove {
    public function new() {
    }
}

interface CloudMoveSystem {
    function add(c:Cloud):Void;

    function remove(c:Cloud):Void;

    function update(dt:Float):Void;
}

class RoundCloudMoveSystem implements CloudMoveSystem {
    var clouds:Array<Cloud> = [];
    var phase:Float = 0;
    var speed = Math.PI / 5;
    public var center = new Pos();

    public var r = 130;

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


    public function new() {}

    public function update(dt:Float) {
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

class Pos {
    public var x:Float = 0;
    public var y:Float = 0;

    public function new() {}

    public function reset() {
        x = 0;
        y = 0;
    }

    public inline function distSq(o:Pos) {
        return (o.x - x) * (o.x - x)
            + (o.y - y) * (o.y - y);
    }
}
