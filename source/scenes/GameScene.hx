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
    public static inline var TIME_BETWEEN_WAVES = 1;
    public static inline var ENEMIES_PER_WAVE = 1;
    public static inline var MAX_ENEMIES = 1;

    public static var difficulty(default, null):Float = 1; // from 0 to 1

    private var background:Entity;
    private var player:Player;
    private var waveTimer:Alarm;

    static public function getEnemyYPosition() {
        return HXP.choose(20, 40, 80, 100, 120, 140, 160);
    }

    override public function begin() {
        background = new Entity(
            0, 0, new Backdrop('graphics/background.png')
        );
        background.layer = 10;
        //add(background);
        player = new Player(100, 100);
        add(player);

        waveTimer = new Alarm(TIME_BETWEEN_WAVES, TweenType.Looping);
        waveTimer.onComplete.bind(function() {
            sendWave();
        });
        addTween(waveTimer, true);
        sendWave();
    }

    private function sendWave() {
        if(typeCount("enemy") < MAX_ENEMIES) {
            var enemyXPositions = getEnemyXPositions();
            for(i in 0...ENEMIES_PER_WAVE) {
                var fanmaker = new Fanmaker(enemyXPositions[i]);
                var ringshot = new Ringshot(enemyXPositions[i]);
                var spiralshot = new Spiralshot(enemyXPositions[i]);
                var sprayer = new Sprayer(enemyXPositions[i]);
                var fountain = new Fountain(enemyXPositions[i]);
                var treemaker = new Treemaker(enemyXPositions[i]);
                //var litterer = new Litterer(enemyXPositions[i]);
                var litterer = new Litterer(HXP.width / 2 - 14);
                add(litterer);
                //add(HXP.choose(
                    //fanmaker, ringshot, spiralshot, sprayer, fountain
                //));
            }
        }
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
        background.y -= SCROLL_SPEED * Main.getDelta();
        if(background.y > HXP.height) {
            background.y -= HXP.height;
        }

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
