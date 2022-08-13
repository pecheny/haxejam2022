package j2022;
import flash.text.TextField;
import openfl.events.KeyboardEvent;
import flash.display.DisplayObject;
import openfl.events.MouseEvent;
import j2022.ui.IntroScreen;
import j2022.GameFsm;
class IntroState extends GameState {
    var view = new IntroScreen();

    public function new() {
        super();
        view.introFinished.listen(()->fsm.startGame());
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
        switch target.name {
            case "_play": fsm.startGame();
        }
    }

    override public function keyUpHandler(e:KeyboardEvent):Void {
        fsm.startGame();
    }
}
class WelcomeState extends GameState {
    var view = new Welcome();

    public function new() {
        super();
    }

    override public function update(t:Float):Void {
        super.update(t);
    }

    override public function onEnter():Void {
        super.onEnter();
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
            case "_play": fsm.changeState(GameStates.INTRO);
        }
    }

    override public function keyUpHandler(e:KeyboardEvent):Void {
        fsm.startGame();
    }
}

class GameOverState extends GameState {
    var view = new GameOver();
    var score = new TextField();

    public function new() {
        super();
        var t = score;
        t.scaleY = t.scaleX = 3;
        t.text = "" ;
        t.textColor = 0xffffff;
        view.addChild(score);
    }

    override public function update(t:Float):Void {
        super.update(t);
    }

    override public function onEnter():Void {
        super.onEnter();
        score.text = "Your score is :" + fsm.model.score;
        openfl.Lib.current.stage.addChild(view);
        fsm.model.sounds.stopMusic();
    }

    override public function onExit():Void {
        super.onExit();
        openfl.Lib.current.stage.removeChild(view);
    }

    override public function mouseDownHandler(e:MouseEvent):Void {
        var target:DisplayObject = e.target;
        trace(target.name);
        switch target.name {
            case "_play": fsm.startGame();
        }
    }

    override public function keyUpHandler(e:KeyboardEvent):Void {
        fsm.startGame();
    }
}