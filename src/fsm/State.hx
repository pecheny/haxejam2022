package fsm;

import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
class State<TStates:String, TFSM:FSM<TStates, TFSM>> {
    public var fsm:TFSM;

    public function update(t:Float):Void {}

    public function onEnter():Void {}

    public function onExit():Void {}

    public function mouseDownHandler(e:MouseEvent):Void {}

    public function keyUpHandler(e:KeyboardEvent):Void {}

}