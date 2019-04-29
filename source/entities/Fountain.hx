package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class Fountain extends Enemy {
    public static inline var DROP_TIME = 1;
    public static inline var HEALTH = 37;
    public static inline var MIN_TIME_BETWEEN_SHOTS = 0.5;
    public static inline var MAX_TIME_BETWEEN_SHOTS = 2;
    public static inline var MIN_SHOT_SPEED = 0.1;
    public static inline var MAX_SHOT_SPEED = 0.15;
    public static inline var MIN_SHOT_ACCEL = 0.0001;
    public static inline var MAX_SHOT_ACCEL = 0.0002;
    public static inline var WIDTH = 32;
    public static inline var HEIGHT = 25;

    private var sprite:Spritemap;
    private var dropDistance:Float;
    private var dropTween:Alarm;
    private var shotTimer:Alarm;

    public function new(x:Float, difficulty:Float) {
        super(x, -HEIGHT, HEALTH, difficulty);
        mask = new Hitbox(WIDTH, HEIGHT, 0, 32 - HEIGHT);
        sprite = new Spritemap("graphics/32enemies.png", 32, 32);
        sprite.add("kettle", [6, 7, 8, 9], 5);
        sprite.add("kettleslow", [10, 11, 12, 13], 5);
        graphic = sprite;

        dropDistance = GameScene.getEnemyYPosition(this);
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
        }
        sprite.setAnimFrame(
            Main.isSlowmo() ? "kettleslow" : "kettle",
            [3, 2, 1, 0, 1, 2, 3][MathUtil.ilerp(0, 6, percent)]
        );
        y = MathUtil.lerp(
            -HEIGHT, dropDistance, Ease.sineOut(dropTween.percent)
        );
        super.update();
    }

    private function shoot() {
        var shotAngle = getAngleTowardsPlayer();
        var shotSpeed = MathUtil.lerp(
            MIN_SHOT_SPEED, MAX_SHOT_SPEED, difficulty
        );
        var shotAccel = MathUtil.lerp(
            MIN_SHOT_ACCEL, MAX_SHOT_ACCEL, difficulty
        );
        scene.add(new EnemyBullet(
            centerX, centerY, -shotSpeed, shotAngle, 0,
            shotAccel + shotAccel / 5,
            EnemyBullet.NORMAL
        ));
        scene.add(new EnemyBullet(
            centerX, centerY, -shotSpeed, shotAngle, 0.0001, shotAccel,
            EnemyBullet.NORMAL
        ));
        scene.add(new EnemyBullet(
            centerX, centerY, -shotSpeed, shotAngle, -0.0001, shotAccel,
            EnemyBullet.NORMAL
        ));
    }
}

