package scenes;

import haxepunk.*;
import haxepunk.graphics.tile.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import entities.*;

class GameScene extends Scene
{
    public static inline var SCROLL_SPEED = 0.1;
    public static inline var TIME_BETWEEN_WAVES = 2;
    public static inline var ENEMIES_PER_WAVE = 1;
    public static inline var MAX_ENEMIES = 1;


    public var waves:Array<Array<Dynamic>>;
    public var waveCount:Int;

    private var background:Entity;
    private var player:Player;
    private var waveTimer:Alarm;

    private var instrumental:Sfx;
    private var drums:Sfx;

    static public function getEnemyYPosition() {
        return HXP.choose(20, 40, 80, 100, 120, 140);
        //return 400;
    }

    override public function begin() {
        background = new Entity(
            0, 0, new Backdrop('graphics/background.png')
        );
        background.layer = 10;
        add(background);
        player = new Player(HXP.width / 2 - 8, HXP.height - 100);
        add(player);

        add(new HUD());

        waves = [
            // Enemy count trigger, difficulty, enemy list
            [2, 0.4, "fanmaker,ringshot"],
            [1, 0.2, "fireworker,fountain"],
            [2, 0.4, "litterer,fountain"],
            [2, 0.4, "spiralshot,sprayer"],
            [2, 0.4, "treemaker,fanmaker"],
            [0, 0, "boss"]
        ];
        waveCount = 0;

        waveTimer = new Alarm(TIME_BETWEEN_WAVES, TweenType.Looping);
        waveTimer.onComplete.bind(function() {
            sendWave();
        });
        addTween(waveTimer, true);
        sendWave();

        instrumental = new Sfx("audio/instrumental.wav");
        drums = new Sfx("audio/drums.wav");
        instrumental.play();
        drums.volume = 0;
        drums.play();
    }

    private function sendWave() {
        trace('what is waves? ${Type.getClass(waves)}');
        var wave = waves[waveCount];
        if(wave == null) {
            return;
        }
        var enemyCountTrigger:Int = cast(wave[0], Int);
        var waveDifficulty:Float = cast(wave[1], Float);
        var enemyList:Array<String> = cast(wave[2], String).split(",");
        if(typeCount("enemy") > enemyCountTrigger) {
            return;
        }
        var enemyXPositions = getEnemyXPositions();
        var count = 0;
        for(enemy in enemyList) {
            if(enemy == "boss") {
                var bossDelay = new Alarm(3, TweenType.OneShot);
                bossDelay.onComplete.bind(function() {
                    add(new Boss(HXP.width / 2 - 192 / 2, 0));
                });
                addTween(bossDelay, true);
            }
            else if(enemy == "fanmaker") {
                add(new Fanmaker(enemyXPositions[count], waveDifficulty));
            }
            else if(enemy == "fireworker") {
                add(new Fireworker(enemyXPositions[count], waveDifficulty));
            }
            else if(enemy == "fountain") {
                add(new Fountain(enemyXPositions[count], waveDifficulty));
            }
            else if(enemy == "litterer") {
                add(new Litterer(enemyXPositions[count], waveDifficulty));
            }
            else if(enemy == "ringshot") {
                add(new Ringshot(enemyXPositions[count], waveDifficulty));
            }
            else if(enemy == "scatterer") {
                add(new Scatterer(enemyXPositions[count], waveDifficulty));
            }
            else if(enemy == "spiralshot") {
                add(new Spiralshot(enemyXPositions[count], waveDifficulty));
            }
            else if(enemy == "sprayer") {
                add(new Sprayer(enemyXPositions[count], waveDifficulty));
            }
            else if(enemy == "treemaker") {
                add(new Treemaker(enemyXPositions[count], waveDifficulty));
            }
            count++;
        }
        waveCount++;
    }

    private function getEnemyXPositions() {
        var enemyPositions = new Array<Int>();
        for(i in 0...5) {
            enemyPositions.push(i * 2 * 24 + 12);
        }
        HXP.shuffle(enemyPositions);
        return enemyPositions;
    }

    override public function update() {
        background.visible = !Main.isSlowmo();
        background.y -= SCROLL_SPEED * Main.getDelta();
        if(background.y > HXP.height) {
            background.y -= HXP.height;
        }

        drums.volume = Main.isSlowmo() ? 0 : 1;

        // The code below is copied from haxepunk/Scene.hx
        // so we can use our time factor in e.updateTweens()

		// update the camera
		camera.update();

		// update the entities
		for (e in _update)
		{
			if (e.active)
			{
				if (e.hasTween) e.updateTweens(
                    HXP.elapsed * Main.getTimeFactor()
                );
				if (e.active)
				{
					if (e.shouldUpdate())
					{
						e.preUpdate.invoke();
						e.update();
						e.postUpdate.invoke();
					}
				}
			}
			var g = e.graphic;
			if (g != null && g.active)
			{
				g.preUpdate.invoke();
				g.update();
				g.postUpdate.invoke();
			}
		}

		// update the camera again, in case it's following an entity
		camera.update();

		// updates the cursor
		if (HXP.cursor != null && HXP.cursor.active)
		{
			HXP.cursor.update();
		}
    }
}
