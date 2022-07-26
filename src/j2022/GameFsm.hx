package j2022;
import openfl.Lib;
import openfl.events.MouseEvent;
import fsm.State;
import fsm.FSM;
class GameFsm extends FSM<GameStates, GameFsm> {
    public var model(default, null):GodModel;
    public function new(m) {
        super();
        this.model = m;
        addState(GAMEPLAY, new GameplayState());
        addState(INTRO, new IntroState());

        Lib.current.stage.stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
//        stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
//        Lib.current.stage.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
//        Lib.current.stage.stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
    }

    public function mouseDownHandler(e:MouseEvent):Void {
        getCurrentState().mouseDownHandler(e);
    }
}

@:enum abstract GameStates(String) to String {
    var GAMEPLAY = "GAMEPLAY";
    var INTRO = "INTRO";
}

class GameState extends State<GameStates, GameFsm> {
    public function new() {}
}
