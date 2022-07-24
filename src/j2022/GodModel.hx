package j2022;
import input.GamepadInput;
import flash.ui.Keyboard;
import input.KeyboardInput;
import input.MetaInput;
import utils.KeyPoll;
import input.Input;
class GodModel {
    public var view:GameView;
    public var player:Player;
    public var bullet:Bullet;
    public var input:Input;
    public var baseline:Float;
    public var gravity = 100;

    public function new() {
        player = new Player();
        bullet = new Bullet();
        view = new GameView(this);
        baseline = 0;//openfl.Lib.current.stage.stageHeight - 30;
        var keys = new KeyPoll(openfl.Lib.current.stage);
        input = new MetaInput().add(
            new KeyboardInput({
                forward:Keyboard.RIGHT,
                backward:Keyboard.LEFT,
                up:Keyboard.UP,
                down:Keyboard.DOWN,
            }, keys, [GameButtons.jump => Keyboard.SPACE ])).add(
            new GamepadInput(GamepadAxis.LEFT_X, GamepadAxis.LEFT_Y, [ GameButtons.jump => GamepadButton.A ])
        );
    }

    public function reset() {
        player.reset();
        player.x = baseline;
        bullet.reset();
        bullet.x = baseline;
        view.reset();
    }
}


class Bullet extends GameObj {
}
class Player extends GameObj {
    public var bullet:Bullet;
}
class GameObj {
    public var color:Int = 0;
    public var x:Float;
    public var y:Float;
    public var vx:Float;
    public var vy:Float;
    public var r:Float = 16;

    public function new() {
        reset();
    }

    public function reset() {
        x = 0;
        y = 0;
        vx = 0;
        vy = 0;
    }
}
