package j2022;
import utils.AbstractEngine;
import j2022.GameFsm;
class Main extends AbstractEngine {
    var fsm : GameFsm;
    public function new() {
        super();
        var m = new GodModel();
        fsm = new GameFsm(m);
        fsm.changeState(GameStates.INTRO);
    }

    override public function update(t:Float):Void {
        super.update(t);
        fsm.update(t);
    }


}
