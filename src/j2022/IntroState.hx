package j2022;
import openfl.events.KeyboardEvent;
import flash.display.DisplayObject;
import openfl.events.MouseEvent;
import j2022.ui.IntroScreen;
import j2022.GameFsm;
class IntroState extends GameState {
    var view = new IntroScreen();

    public function new() {
        super();
        view.introFinished.listen(()->fsm.changeState(GAMEPLAY));
    }

    override public function update(t:Float):Void {
        super.update(t);
    }

    override public function onEnter():Void {
        super.onEnter();
        view.reset();
        openfl.Lib.current.stage.addChild(view);
    }

    override public function onExit():Void {
        super.onExit();
        openfl.Lib.current.stage.removeChild(view);
    }

    override public function mouseDownHandler(e:MouseEvent):Void {

        var target:DisplayObject = e.target;
        trace(target.name);
        switch target.name {
            case "_play": fsm.changeState(GameStates.GAMEPLAY);
        }
    }

    override public function keyUpHandler(e:KeyboardEvent):Void {
        fsm.changeState(GameStates.GAMEPLAY);
    }
}
