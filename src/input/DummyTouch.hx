package input;
import input.Input.GameButtons;
import openfl.events.Event;
import flash.display.DisplayObject;
import j2022.GodModel;
import openfl.events.MouseEvent;
import input.Input.GameButtons;
class DummyTouch implements Input {
    var model:GodModel;
    var _pressed = false;
    var horizontal = 0;
    var topPressed = false;

    public function new(m) {
        model = m;
        model.view.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
        model.view.addEventListener(MouseEvent.MOUSE_UP, onUp);
        model.view.addEventListener(MouseEvent.MOUSE_OUT, onOut);
        model.view.addEventListener(MouseEvent.MOUSE_OVER, onOver);
        openfl.Lib.current.stage.addEventListener(Event.MOUSE_LEAVE, onUp);
    }


    function onDown(e:MouseEvent) {
        _pressed = true;
        var trg:DisplayObject = e.target;
        switch trg.name {
            case ControlAliases._left : horizontal --;
            case ControlAliases._right : horizontal ++;
            case ControlAliases._top : topPressed = true;
        }
        if (horizontal * horizontal > 1) throw "Wrong";
    }

    function onUp(e:Event) {
        _pressed = false;
        horizontal = 0;
        topPressed = false;
    }

    function onOver(e:MouseEvent) {
        var trg:DisplayObject = e.target;
        if (!_pressed)
            return;
        switch trg.name {
            case ControlAliases._left : horizontal --;
            case ControlAliases._right : horizontal ++;
            case ControlAliases._top : topPressed = true;
        }
    }

    function onOut(e:MouseEvent) {
        var trg:DisplayObject = e.target;
        if (!_pressed)
            return;
        switch trg.name {
            case ControlAliases._left : horizontal ++;
            case ControlAliases._right : horizontal --;
            case ControlAliases._top : topPressed = false;
        }
    }


    public function getDirProjection(axis:Axis2D):Float {
        return horizontal;
    }

    public function pressed(button:GameButtons):Bool {
        return button == GameButtons.jump && topPressed;
    }

}
@:enum abstract ControlAliases(String) to String {
    var _left = "_left";
    var _right = "_right";
    var _top = "_top";
}