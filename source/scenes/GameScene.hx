package scenes;

import haxepunk.*;
import haxepunk.graphics.tile.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import entities.*;

class GameScene extends Scene
{
    public static inline var SCROLL_SPEED = 0.1;
    public static inline var TIME_BETWEEN_WAVES = 0.5;
    public static inline var MAX_ENEMIES = 5;

    private var background:Entity;
    private var player:Player;
    private var waveTimer:Alarm;

    override public function begin() {
        background = new Entity(
            0, 0, new Backdrop('graphics/background.png')
        );
        background.layer = 10;
        add(background);
        player = new Player(100, 100);
        add(player);

        waveTimer = new Alarm(TIME_BETWEEN_WAVES, TweenType.Looping);
        waveTimer.onComplete.bind(function() {
            sendWave();
        });
        addTween(waveTimer, true);
    }

    override public function update() {
        background.y -= SCROLL_SPEED * Main.getDelta();
        if(background.y > HXP.height) {
            background.y -= HXP.height;
        }
        super.update();
    }

    private function sendWave() {
        if(typeCount("enemy") < MAX_ENEMIES) {
            var cactus = new Cactus(
                Std.int(32 + Math.random() * (HXP.width - 64)), -32
            );
            var rock = new Rock(
                Std.int(32 + Math.random() * (HXP.width - 64)), -32
            );
            var spinner = new Spinner(
                Std.int(32 + Math.random() * (HXP.width - 64)), -32
            );
            add(HXP.choose(cactus, rock, spinner));
        }
    }
}
