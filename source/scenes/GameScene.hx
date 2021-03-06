package scenes;

import haxepunk.*;
import haxepunk.graphics.tile.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import entities.*;

class GameScene extends Scene
{
    public static inline var SCROLL_SPEED = 0.2;
    public static inline var TIME_BETWEEN_WAVES = 3;
    public static inline var ENEMIES_PER_WAVE = 1;
    public static inline var MAX_ENEMIES = 1;

    public static var bossDifficultiesByLevel:Map<Int, Float> = [
        1 => 0.1,
        2 => 0.3,
        3 => 0.8,
        4 => 1
    ];

    public var waves:Array<Array<Dynamic>>;
    public var waveCount:Int;
    public var level(default, null):Int;

    private var curtain:Curtain;
    private var background:Entity;
    private var backgroundSlow:Entity;
    private var player:Player;
    private var hud:HUD;
    private var waveTimer:Alarm;

    private var instrumental:Sfx;
    private var drums:Sfx;
    private var isHardMode:Bool;


    static public var enemyPositions(default, null):Map<String, Entity>;

    static public function freeEnemyPosition(enemy:Entity) {
        for(key in enemyPositions.keys()) {
            if(enemyPositions[key] == enemy) {
                enemyPositions.remove(key);
            }
        }
    }

    static public function getEnemyYPosition(enemy:Entity):Float {
        var yPosition:Float = HXP.choose(30, 65, 100, 135);
        var key = '${enemy.x}-${yPosition}';
        var count = 0;
        while(enemyPositions.exists(key) && count < 1000) {
            yPosition = HXP.choose(30, 65, 100, 135);
            key = '${enemy.x}-${yPosition}';
            count++;
        }
        enemyPositions.set(key, enemy);
        return yPosition;
    }

    private function getVeryEasyWave():Array<Dynamic> {
        // Enemy count trigger, difficulty, enemy list
        var trigger = HXP.choose(0, 1);
        var difficulty = 0;
        var numEnemies = HXP.choose(1, 2);
        var enemyNames = getRandomEnemyNames(numEnemies);
        return [trigger, difficulty, enemyNames];
    }

    private function getEasyWave():Array<Dynamic> {
        // Enemy count trigger, difficulty, enemy list
        var trigger = HXP.choose(1, 2);
        var difficulty = (
            trigger > 1 ? HXP.choose(0, 0.2, 0.4) : HXP.choose(0.5, 0.6, 0.7)
        );
        var numEnemies = (
            trigger > 1 ? 1 : HXP.choose(1, 2)
        );
        var enemyNames = getRandomEnemyNames(numEnemies);
        return [trigger, difficulty, enemyNames];
    }

    private function getNormalWave():Array<Dynamic> {
        // Enemy count trigger, difficulty, enemy list
        var trigger = HXP.choose(1, 2, 3, 4);
        var difficulty = (
            trigger > 2 ? HXP.choose(0.5, 0.6, 0.7) : HXP.choose(0.8, 0.9, 1)
        );
        var numEnemies = HXP.choose(2, 3, 4);
        var enemyNames = getRandomEnemyNames(numEnemies);
        return [trigger, difficulty, enemyNames];
    }

    private function getHardWave():Array<Dynamic> {
        // Enemy count trigger, difficulty, enemy list
        var trigger = HXP.choose(2, 3, 4);
        var difficulty = (
            trigger > 2 ? HXP.choose(0.7, 0.8, 0.9) : 1
        );
        var numEnemies = HXP.choose(3, 4);

        var enemyNames = getRandomEnemyNames(numEnemies);
        return [trigger, difficulty, enemyNames];
    }

    private function getVeryHardWave():Array<Dynamic> {
        // Enemy count trigger, difficulty, enemy list
        var trigger = HXP.choose(3, 4);
        var difficulty = 1;
        var numEnemies = HXP.choose(4, 5);

        var enemyNames = getRandomEnemyNames(numEnemies);
        return [trigger, difficulty, enemyNames];
    }

    private function getRandomEnemyNames(numEnemies:Int) {
        var enemyNameArray = new Array<String>();
        if(Math.random() < 0.5) {
            var enemyName = getRandomEnemyName();
            for(num in 0...cast(numEnemies, Int)) {
                enemyNameArray.push(enemyName);
            }
        }
        else {
            for(num in 0...cast(numEnemies, Int)) {
                enemyNameArray.push(getRandomEnemyName());
            }
        }
        var enemyNames = enemyNameArray.join(',');
        return enemyNames;
    }

    public function new(level:Int) {
        super();
        this.level = level;
    }

    public function getTilesetName() {
        if(level == 1) {
            return 'city';
        }
        else if(level == 2) {
            return 'ocean';
        }
        else if(level == 3) {
            return 'forest';
        }
        else {
            return 'space';
        }
    }

    override public function begin() {
        curtain = new Curtain(0, 0);
        add(curtain);
        curtain.fadeIn();

        enemyPositions = new Map<String, Entity>();

        background = new Entity(
            0, 0, new Backdrop('graphics/${getTilesetName()}.png')
        );
        background.layer = 10;
        add(background);
        background.visible = false;
        backgroundSlow = new Entity(
            0, 0, new Backdrop('graphics/${getTilesetName()}slow.png')
        );
        backgroundSlow.layer = 10;
        add(backgroundSlow);

        player = new Player(HXP.width / 2 - 8, HXP.height - 100);
        add(player);

        hud = new HUD(level);
        add(hud);

        isHardMode = false;
        waves = new Array<Array<Dynamic>>();
        if(isHardMode) {
            for(i in 0...10) {
                waves.push(getHardWave());
            }
        }
        else if(level == 1) {
            for(i in 0...6) {
                waves.push(getVeryEasyWave());
            }
            for(i in 0...6) {
                waves.push(getEasyWave());
            }
            HXP.shuffle(waves);
        }
        else if(level == 2) {
            for(i in 0...9) {
                waves.push(getEasyWave());
            }
            for(i in 0...4) {
                waves.push(getNormalWave());
            }
        }
        else if(level == 3) {
            for(i in 0...6) {
                waves.push(getEasyWave());
            }
            for(i in 0...7) {
                waves.push(getNormalWave());
            }
            HXP.shuffle(waves);
        }
        else if(level == 4) {
            for(i in 0...10) {
                waves.push(getNormalWave());
            }
        }
        waves.push([0, 0, "boss"]);
        waveCount = 0;

        waveTimer = new Alarm(TIME_BETWEEN_WAVES, TweenType.Looping);
        waveTimer.onComplete.bind(function() {
            sendWave();
        });
        addTween(waveTimer, true);

        var musicLevel = level;
        instrumental = new Sfx('audio/lvl${musicLevel}instrumental.wav');
        drums = new Sfx('audio/lvl${musicLevel}drums.wav');
        instrumental.loop();
        drums.volume = 0;
        drums.loop();

        if(level != 4) {
            for(i in 0...40) {
                add(new Cloud(
                    MathUtil.lerp(-25, 25, Math.random()),
                    Math.random() * HXP.height
                ));
                add(new Cloud(
                    MathUtil.lerp(240 - 50 - 25, 240 - 25, Math.random()),
                    Math.random() * HXP.height
                ));
            }
        }
    }

    public function onBossDeath() {
        stopAllMusic();
        var fadeTimer = new Alarm(5, TweenType.OneShot);
        fadeTimer.onComplete.bind(function() {
            curtain.fadeOut();
            var resetTimer = new Alarm(3, TweenType.OneShot);
            resetTimer.onComplete.bind(function() {
                if(level < 4) {
                    var newLevel = level + 1;
                    if(newLevel > MainMenu.continueFrom) {
                        MainMenu.continueFrom = newLevel;
                    }
                    HXP.scene = new GameScene(newLevel);
                }
                else {
                    HXP.scene = new MainMenu();
                }
            });
            addTween(resetTimer, true);
        });
        addTween(fadeTimer, true);
    }

    public function stopAllMusic() {
        instrumental.stop();
        drums.stop();
    }

    public function gameOver() {
        stopAllMusic();
        var displayTimer = new Alarm(3, TweenType.OneShot);
        displayTimer.onComplete.bind(function() {
            hud.displayGameOver();
            var fadeTimer = new Alarm(3, TweenType.OneShot);
            fadeTimer.onComplete.bind(function() {
                curtain.fadeOut();
                var resetTimer = new Alarm(3, TweenType.OneShot);
                resetTimer.onComplete.bind(function() {
                    HXP.scene = new MainMenu();
                });
                addTween(resetTimer, true);
            });
            addTween(fadeTimer, true);
        });
        addTween(displayTimer, true);
    }

    private function getRandomEnemyName() {
        return HXP.choose(
            "fanmaker", "fireworker", "fountain", "litterer", "ringshot",
            "scatterer", "spiralshot", "sprayer", "treemaker"
        );

    }

    private function sendWave() {
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
                //var bossDelay = new Alarm(0.1, TweenType.OneShot);
                bossDelay.onComplete.bind(function() {
                    var boss = new Boss(
                        HXP.width / 2 - 192 / 2,
                        isHardMode ? 1 : bossDifficultiesByLevel[level],
                        getTilesetName(),
                        level
                    );
                    add(boss);
                    for(port in boss.ports) {
                        if(port != null) {
                            add(port);
                        }
                    }
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
        for(i in 0...4) {
            enemyPositions.push(i * 55 + 17);
        }
        HXP.shuffle(enemyPositions);
        return enemyPositions;
    }

    override public function update() {
        background.visible = !Main.isSlowmo();
        backgroundSlow.visible = Main.isSlowmo();
        for(bg in [background, backgroundSlow]) {
            bg.y += SCROLL_SPEED * Main.getDelta();
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
