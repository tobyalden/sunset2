package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class Spiralshot extends Enemy {
    public static inline var DROP_TIME = 1;
    public static inline var HEALTH = 25;
    public static inline var MIN_TIME_BETWEEN_SHOTS = 0.13;
    public static inline var MAX_TIME_BETWEEN_SHOTS = 0.25;
    public static inline var MIN_BULLETS_PER_SHOT = 2;
    public static inline var MAX_BULLETS_PER_SHOT = 4;
    public static inline var MIN_SHOT_SPEED = 0.07;
    public static inline var MAX_SHOT_SPEED = 0.11;
    public static inline var MIN_SPIN_RATE = 2;
    public static inline var MAX_SPIN_RATE = 4;
    public static inline var HEIGHT = 24;

    private var sprite:Spritemap;
    private var dropDistance:Float;
    private var dropTween:Alarm;
    private var shotTimer:Alarm;

    public function new(x:Float, difficulty:Float) {
        super(x, -HEIGHT, HEALTH, difficulty);
        mask = new Hitbox(HEIGHT, HEIGHT);
        sprite = new Spritemap("graphics/24enemies.png", 24, 24);
        sprite.add("clock", [11, 12, 13], 5);
        sprite.add("clockslow", [17, 18, 19], 5);
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
        sprite.setAnimFrame(
            Main.isSlowmo() ? "clockslow" : "clock",
            [0, 1, 2][MathUtil.ilerp(0, 2, ((age * 4) % 1))]
        );
        y = MathUtil.lerp(
            -HEIGHT, dropDistance, Ease.sineOut(dropTween.percent)
        );
        super.update();
    }

    private function shoot() {
        var bulletsPerShot = MathUtil.ilerp(
            MIN_BULLETS_PER_SHOT, MAX_BULLETS_PER_SHOT, difficulty
        );
        var spinRate = MathUtil.lerp(
            MIN_SPIN_RATE, MAX_SPIN_RATE, difficulty
        );
        for(i in 0...bulletsPerShot) {
            var spreadAngles = getSpreadAngles(bulletsPerShot + 1, Math.PI * 2);
            var shotAngle = age * spinRate + spreadAngles[i];
            var shotSpeed = MathUtil.lerp(
                MIN_SHOT_SPEED, MAX_SHOT_SPEED, difficulty
            );
            scene.add(new EnemyBullet(
                centerX, centerY, shotSpeed, shotAngle,
                0, 0.0001, EnemyBullet.ALT
            ));
        }
    }
}


