package j2022.ui;
import ec.Signal;
import openfl.events.Event;
import openfl.display.MovieClip;
import flash.display.Sprite;
class IntroScreen extends Sprite {
    public var introFinished(default, null):Signal<Void->Void> = new Signal();
    var clip:MovieClip = new Intro();
    public function new() {
        super();
        var fr = 0;
        var frFactor = 4;
        clip.addEventListener(Event.ENTER_FRAME, e -> {
            fr++;
            if (fr >= frFactor) {
                fr = 0;
                clip.gotoAndStop(clip.currentFrame + 1);
            }
            if (clip.currentFrame == clip.totalFrames) {
                clip.stop();
                introFinished.dispatch();
            }
        });
        addChild(clip);
    }

    public function reset() {
        clip.gotoAndStop(0);
    }

}
