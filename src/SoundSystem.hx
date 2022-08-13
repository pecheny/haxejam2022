package ;
import treefortress.sound.SoundHX;
import openfl.Assets;
import openfl.media.Sound;
class SoundSystem {
    public function new() {

        addSound(MUSIC);
        addSound(BALL_FALL);
        addSound(WALL_HIT);
        addSound(CHAR_HIT);
        addSound(CLOUD_PF);
        addSound(STUN);
        addSound(PICK);
//        addSound(START);
        addSound(OVER);
    }

    inline static var TEST = "flaunch.wav";

    inline static var BALL_FALL:String = #if flash "flaunch.wav" #else "416890__whitelinefever__hammer-hitting-a-head.wav"#end;
    inline static var WALL_HIT:String = "405550__raclure__stiff-wooden-tap.wav";
    inline static var CHAR_HIT:String = "521552__omerbhatti34__arrow-impact.mp3";
    inline static var CLOUD_PF:String = "521506__typeoo__air-hiss-cola.wav";
//    inline static var PANIC:String =              "";
    inline static var STUN:String = "172003__drewkelly__smash-and-grunt.wav";
    inline static var PICK:String = #if flash "flaunch.wav" #else "51437__vibe-crc__keys-catched.wav"#end;
    inline static var START:String = "20289__djgriffin__om-gate-gate-paragate-parasamgate-bodhi-ye-swaha.aiff";
    inline static var OVER:String = "496598__phonosupf__rattle.wav";

    inline static var MUSIC = "ChimeChase.mp3";

    var sounds:Map<String, Sound> = new Map<String, Sound>();

    public function addSound(name:String):Void {
        var snd = Assets.getSound('Assets/sound/' + name);
        sounds[name] = snd;
        SoundHX.addSound(name, snd);
    }


    public function pause() {
        SoundHX.pauseAll();
    }

    public function resume() {
        SoundHX.resumeAll();
    }

    public function startMusic():Void {
        playLoop(MUSIC);
    }

    public function stopMusic() {
        SoundHX.stop(MUSIC);
    }

    public function ballWallHit() {
        playFx(WALL_HIT);
    }


    public function ballFall() {
        playFx(BALL_FALL);
    }

    public function ballCharHit() {
        playFx(CHAR_HIT);
    }

    public function cloudPff() {
        playFx(CLOUD_PF);
    }

    public function panic() {
//        playFx(PANIC);
    }

    public function gStart() {
//        playFx(START);
    }

    public function stun() {
        playFx(STUN);
    }

    public function pick() {
        playFx(PICK);
    }

    public function gameOver() {
        playFx(OVER);
    }


    function playLoop(alias:String) {
        SoundHX.play(alias, 1, 0, -1, false);
    }

    function stop(alias:String) {
        SoundHX.stop(alias);
    }

    function playFx(alias:String, multi = false) {
        SoundHX.play(alias, 1, 0, 1, multi);
        try {
        } catch (e:Dynamic) {
            trace("Error! : " + e);
        }
    }
}