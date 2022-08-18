package utils;
import openfl.events.Event;
import ec.Signal;
class LostFocusHandler {
    public var onHide = new Signal<Void -> Void>();

    public function new() {
        js.Browser.document.addEventListener("visibilitychange", () -> {
            if (js.Browser.document.hidden)
                fire(null);
        });

//        openfl.Lib.current.stage.addEventListener(FocusEvent.FOCUS_OUT, focusLost);
        openfl.Lib.current.stage.addEventListener(Event.DEACTIVATE, fire);
    }

    function fire(_) {
        onHide.dispatch();
    }
}
