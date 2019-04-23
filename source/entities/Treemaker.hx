package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class Treemaker extends Enemy {
    public static inline var DROP_TIME = 1;
    public static inline var HEALTH = 25;
    public static inline var MIN_TIME_BETWEEN_SHOTS = 2;
    public static inline var MAX_TIME_BETWEEN_SHOTS = 3.5;
    public static inline var SHOT_SPEED = 0.1;
    public static inline var SHOT_ACCEL = 0.000075;
    public static inline var MIN_SUBROUTINE_INTERVAL = 0.2;
    public static inline var MAX_SUBROUTINE_INTERVAL = 0.8;
    public static inline var MIN_SUBROUTINE_SHOT_SPEED = 0.06;
    public static inline var MAX_SUBROUTINE_SHOT_SPEED = 0.08;
    public static inline var SUBROUTINE_SHOT_ACCEL = 0.000035;
    public static inline var WIDTH = 19;
    public static inline var HEIGHT = 24;

    private var sprite:Spritemap;
    private var dropDistance:Float;
    private var dropTween:Alarm;
    private var shotTimer:Alarm;

    public function new(x:Float, difficulty:Float) {
        super(x, -HEIGHT, HEALTH, difficulty);
        mask = new Hitbox(WIDTH, HEIGHT, 3, 0);
        sprite = new Spritemap("graphics/24enemies.png", 24, 24);
        sprite.add("lightbulb", [4, 5], 5);
        sprite.add("lightbulbslow", [6, 7], 5);
        graphic = sprite;
        dropDistance = GameScene.getEnemyYPosition();
        dropTween = new Alarm(DROP_TIME, TweenType.OneShot);
        dropTween.onComplete.bind(function() {
            shoot();
            shotTimer.start();
        });
        addTween(dropTween, true);

        var timeBetweenShots = MathUtil.lerp(
            MAX_TIME_BETWEEN_SHOTS,
            MIN_TIME_BETWEEN_SHOTS,
            difficulty
        );
        shotTimer = new Alarm(timeBetweenShots, TweenType.Looping);
        shotTimer.onComplete.bind(function() {
            shoot();
        });
        addTween(shotTimer);
    }

    override public function update() {
        var percent = shotTimer.percent;
        if(dropTween.active) {
            percent = dropTween.percent;
            sprite.setAnimFrame(
                Main.isSlowmo() ? "lightbulbslow" : "lightbulb",
                [0, 0, 0, 0, 0, 0, 0, 1][MathUtil.ilerp(0, 6, percent)]
            );
        }
        else {
            sprite.setAnimFrame(
                Main.isSlowmo() ? "lightbulbslow" : "lightbulb",
                [1, 0, 0, 0, 0, 0, 0, 1][MathUtil.ilerp(0, 6, percent)]
            );
        }
        y = MathUtil.lerp(
            -HEIGHT, dropDistance, Ease.sineOut(dropTween.percent)
        );
        super.update();
    }

    private function shoot() {
        var shotAngle = getAngleTowardsPlayer();
        var subroutineInterval = MathUtil.lerp(
            MAX_SUBROUTINE_INTERVAL, MIN_SUBROUTINE_INTERVAL,
            difficulty
        );
        scene.add(new EnemyBullet(
            centerX, centerY, SHOT_SPEED, shotAngle, 0, SHOT_ACCEL,
            EnemyBullet.BLUE_CIRCLE, shotSubroutine, subroutineInterval
        ));
    }

    private function shotSubroutine(parent:EnemyBullet) {
        var subroutineShotSpeed = MathUtil.lerp(
            MIN_SUBROUTINE_SHOT_SPEED, MAX_SUBROUTINE_SHOT_SPEED,
            difficulty
        );
        HXP.scene.add(new EnemyBullet(
            parent.centerX, parent.centerY, subroutineShotSpeed,
            parent.angle + Math.PI / 2, 0, SUBROUTINE_SHOT_ACCEL,
            EnemyBullet.YELLOW_CIRCLE
        ));
        HXP.scene.add(new EnemyBullet(
            parent.centerX, parent.centerY, subroutineShotSpeed,
            parent.angle - Math.PI / 2, 0, SUBROUTINE_SHOT_ACCEL,
            EnemyBullet.YELLOW_CIRCLE
        ));
    }
}

