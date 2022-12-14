package j2022;
import openfl.display.StageAlign;
import openfl.display.StageScaleMode;
import utils.AbstractEngine;
import j2022.GameFsm;
class Main extends AbstractEngine {
    var fsm : GameFsm;
    public function new() {
        super();
        stage.scaleMode = StageScaleMode.SHOW_ALL;
        stage.align = StageAlign.TOP_LEFT;
        var m = new GodModel();
        fsm = new GameFsm(m);
        m.fsm = fsm;
        fsm.changeState(GameStates.WELCOME);
    }

    override public function update(t:Float):Void {
        super.update(t);
        fsm.update(t);
    }


}
