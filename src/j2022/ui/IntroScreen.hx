package j2022.ui;
import openfl.events.Event;
import openfl.display.MovieClip;
import flash.display.Sprite;
class IntroScreen extends Sprite{
    public function new() {
        super();
        var clip:MovieClip = new Intro();
        clip.addEventListener(Event.ENTER_FRAME, e -> {if (clip.currentFrame == clip.totalFrames)clip.stop();});
        addChild (clip);
    }
}
