package ;
import treefortress.sound.SoundHX;
import openfl.Assets;
import openfl.media.Sound;
class SoundSystem {
    public function new() {

        addSound("ChimeChase.mp3");
        addSound(TEST);
    }

    inline static var TEST = "flaunch.wav";

    var sounds:Map<String, Sound> = new Map<String, Sound>();

    public function addSound(name:String):Void {
        var snd = Assets.getSound('Assets/sound/' + name);
        sounds[name] = snd;
        SoundHX.addSound(name, snd);
    }


    public function startMusic():Void {
//		SoundHX.fadeAllTo(0);
//        playLoop("ChimeChase.mp3", 1);
    }

    public function ballWallHit() {
        playFx(TEST);
    }


    public function ballFall() {
        playFx(TEST);
    }

    public function ballCharHit() {
        playFx(TEST);
    }

    public function cloudPff() {
        playFx(TEST);
    }

    public function panic() {
        playFx(TEST);
    }

    public function gStart() {
        playFx(TEST);
    }

    public function stun() {
        playFx(TEST);
    }

    public function pick() {
        playFx(TEST);
    }
    public function gameOver() {
        playFx(TEST);
    }


    function playLoop(alias:String, n:Int) {
        SoundHX.play(alias, n);
    }

    function stop(alias:String) {
        SoundHX.stop(alias);
    }

    function playFx(alias:String) {
        SoundHX.playFx(alias);
    }
}