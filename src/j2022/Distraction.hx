package j2022;
import j2022.GameFsm.GameStates;
import utils.Mathu;
import openfl.display.Sprite;
import j2022.GodModel.GlobalTime;
class Distraction {
    var distraction:Float = 50;
//    var affection:Float;
    var checkTime = 60;
    var gameoverCooldown = 600;
    var gameoverCounter = 0;
    var model:GodModel;
    var maxDistraction = 100;
    var offset = 0.;

    public function new(m) {
        model = m;
    }

    public function update(dt) {
        if (GlobalTime.tick % checkTime == 0) {
            var aff = calcAffection();
            if (aff < 10) {
                distraction -= 2;
            } else if (aff > 10) {
                distraction += 2;
            }
            distraction = Mathu.clamp(distraction, 0, maxDistraction);
            model.view.distraction.setValue(distraction / maxDistraction);
        }

        if (distraction > 80) {
            gameoverCounter++;
            model.view.distraction.y -= offset;
            offset = Math.random() * 10;
            model.view.distraction.y += offset;
            if (gameoverCounter >= gameoverCooldown) gameOver();
        } else {
            model.view.distraction.y -= offset;
            offset = 0;
            gameoverCounter = 0;
        }
    }

    function gameOver() {
        model.fsm.changeState(GameStates.INTRO);
    }

    function calcAffection() {
        var a =0;
        for (c in model.clouds.clouds) {
            a += c.getDistrPower();
        }
        return a;
    }

    public function reset() {
        distraction = 50;
        gameoverCounter = 0;
        model.view.distraction.y -= offset;
        offset = 0;
        model.view.distraction.setValue(distraction / maxDistraction);
    }
}

class DistractionView extends Sprite {
    var pointer:Sprite;
    var w = 300;

    public function new() {
        super();
        pointer = new Sprite();
        pointer.graphics.beginFill(0xa0a000);
        var pr = 3;
        var ph = 32;
        pointer.graphics.drawRect(-pr, -ph, pr * 2, ph * 2);
        addChild(pointer);
        graphics.beginFill(0x907000);
        graphics.drawRect(0, 0, w, 32);
    }

    public function setValue(v:Float) {
        pointer.x = v * w;
    }
}
