package j2022;
import j2022.GameFsm.GameStates;
import utils.Mathu;
import openfl.display.Sprite;
import j2022.GodModel;
class Distraction {
    var distraction:Float = 50;
//    var affection:Float;
    var checkTime = 60;
    var gameoverCooldown = 600;
    var gameoverCounter = 0;
    var model:GodModel;
    var maxDistraction = 100;
    var offset = 0.;

    var affection:Float = 0;
    var distrType:DistractionType;

    var calmCounter = 0;
    var calmThreshold = 60 * 15;
    var startCalm = -1;

    public function new(m) {
        model = m;
    }


    inline function enlighted() {
        return (startCalm > 0 && startCalm + calmThreshold < GlobalTime.tick );
    }


    public function update(dt) {
        if (GlobalTime.tick % checkTime == 0) {
            calcAffection();
            if (affection < 10) {
                distraction -= 2;
            } else if (affection > 10) {
                distraction += 2;
            }
            distraction = Mathu.clamp(distraction, 0, maxDistraction);
            model.view.distraction.setValue(distraction / maxDistraction);

            var face:FaceType = if (distraction > 80) face_panic;
            else if (enlighted()) face_calm;
            else if (startCalm > 0) face_susp;
            else {
                switch distrType {
                    case DistractionType.Desire: face_passionate;
                    case DistractionType.Fly: face_distracted;
                    case DistractionType.Suicidal:face_sad;
                    case DistractionType.Toilet: face_panic;
                }
            }
            model.view.setFace(face);
            if (enlighted()) {
// score
                model.score++;
            }
        }

        if (distraction > 80) {
            startCalm = -1;
            gameoverCounter++;
            model.view.distraction.view.y -= offset;
            offset = Math.random() * 10;
            model.view.distraction.view.y += offset;
            if (gameoverCounter >= gameoverCooldown) gameOver();
        } else if (distraction < 20) {
            if (startCalm == -1) startCalm = GlobalTime.tick;
        } else {
            startCalm = -1;
            model.view.distraction.view.y -= offset;
            offset = 0;
            gameoverCounter = 0;
        }
    }

    function gameOver() {
        model.sounds.gameOver();
        model.fsm.changeState(GameStates.GAMEOVER);
    }

    var typedDistr = [0., 0, 0, 0];// new Map<DistractionType, Int>() ;
    function calcAffection() {
        for (i in 0...typedDistr.length)
            typedDistr[i] = 0;
        var a = 0;
        for (k in 0...typedDistr.length)
            typedDistr[k] = 0;
        for (c in model.clouds.clouds) {
            a += c.getDistrPower();
            typedDistr[c.type] += c.getTypeW();
        }
        affection = a;
        var max = 0.;
        for (i in 0...typedDistr.length) {
            if (typedDistr[i] > max) {
                max = typedDistr[i];
                distrType = i;
            }
        }
    }

    public function reset() {
        model.view.setFace(face_sad);
        distraction = 50;
        gameoverCounter = 0;
        model.view.distraction.view.y -= offset;
        offset = 0;
        distrType = DistractionType.Suicidal;
        model.view.distraction.setValue(distraction / maxDistraction);
    }
}

class DistractionView extends Sprite {
    var pointer:Sprite;
    var w:Float = 300;
    public var view:Sprite;

    public function new(v) {
        super();
        this.view = v;
        pointer = cast view.getChildByName("_marker");
        w = view.width;
//        pointer = new Sprite();
//        pointer.graphics.beginFill(0xa0a000);
//        var pr = 3;
//        var ph = 32;
//        pointer.graphics.drawRect(-pr, -ph, pr * 2, ph * 2);
//        addChild(pointer);
//        graphics.beginFill(0x907000);
//        graphics.drawRect(0, 0, w, 32);
    }

    public function setValue(v:Float) {
        pointer.x = v * w;
    }
}
