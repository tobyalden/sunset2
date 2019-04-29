package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class Ringshot extends Enemy {
    public static inline var DROP_TIME = 1;
    public static inline var HEALTH = 25;
    public static inline var MIN_TIME_BETWEEN_SHOTS = 0.5;
    public static inline var MAX_TIME_BETWEEN_SHOTS = 1.5;
    public static inline var MIN_BULLETS_PER_SHOT = 7;
    public static inline var MAX_BULLETS_PER_SHOT = 25;
    public static inline var MIN_SHOT_SPEED = 0.08;
    public static inline var MAX_SHOT_SPEED = 0.12;
    public static inline var WIDTH = 19;
    public static inline var HEIGHT = 23;

    private var sprite:Spritemap;
    private var dropDistance:Float;
    private var dropTween:Alarm;
    private var shotTimer:Alarm;

    public function new(x:Float, difficulty:Float) {
        super(x, -HEIGHT, HEALTH, difficulty);
        mask = new Hitbox(WIDTH, HEIGHT, 2, 24 - HEIGHT);
        sprite = new Spritemap("graphics/24enemies.png", 24, 24);
        sprite.add("fan", [0, 1], 5);
        sprite.add("fanslow", [2, 3], 5);
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
            Main.isSlowmo() ? "fanslow" : "fan",
            [0, 1][MathUtil.ilerp(0, 1, ((age * 4) % 1))]
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
        if(bulletsPerShot % 2 == 0) {
            // Always shoot an odd # of bullets so one is aimed at the player
            bulletsPerShot -= 1;
        }
        for(i in 0...bulletsPerShot) {
            // Circular shot
            var spreadAngles = getSpreadAngles(bulletsPerShot, Math.PI * 2);
            var shotAngle = getAngleTowardsPlayer() + spreadAngles[i];
            var shotSpeed = MathUtil.lerp(
                MIN_SHOT_SPEED, MAX_SHOT_SPEED, difficulty
            );
            scene.add(new EnemyBullet(
                centerX, centerY, shotSpeed, shotAngle,
                0, 0.0001, EnemyBullet.NORMAL
            ));
        }
    }
}

