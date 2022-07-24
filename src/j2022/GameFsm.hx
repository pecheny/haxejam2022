package j2022;
import fsm.State;
import fsm.FSM;
class GameFsm extends FSM<GameStates, GameFsm> {
    public var model(default, null):GodModel;
    public function new(m) {
        super();
        this.model = m;
        addState(GAMEPLAY, new GameplayState());
    }
}

@:enum abstract GameStates(String) to String {
    var GAMEPLAY = "GAMEPLAY";
}

class GameState extends State<GameStates, GameFsm> {
    public function new() {}
}
