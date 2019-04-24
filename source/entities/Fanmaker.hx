package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class Fanmaker extends Enemy {
    public static inline var DROP_TIME = 1;
    public static inline var HEALTH = 25;
    public static inline var MIN_TIME_BETWEEN_SHOTS = 0.8;
    public static inline var MAX_TIME_BETWEEN_SHOTS = 1.6;
    public static inline var BULLETS_PER_SHOT = 3;
    public static inline var MIN_SHOT_SPEED = 0.09;
    public static inline var MAX_SHOT_SPEED = 0.12;
    public static inline var MIN_SHOT_SPREAD = 30;
    public static inline var MAX_SHOT_SPREAD = 15; // Math.PI * 2 / SPREAD
    public static inline var WIDTH = 48;
    public static inline var HEIGHT = 23;

    private var sprite:Spritemap;
    private var dropDistance:Float;
    private var dropTween:Alarm;
    private var shotTimer:Alarm;

    public function new(x:Float, difficulty:Float) {
        super(x, -HEIGHT, HEALTH, difficulty);
        mask = new Hitbox(WIDTH, HEIGHT, 0, 32 - HEIGHT);
        sprite = new Spritemap("graphics/48enemies.png", 48, 32);
        sprite.add("lips", [0, 1, 2, 3], 5);
        sprite.add("lipsslow", [4, 5, 6, 7], 5);
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
            Main.isSlowmo() ? "lipsslow" : "lips",
            [3, 2, 1, 0, 1, 2, 3][MathUtil.ilerp(0, 6, percent)]
        );
        y = MathUtil.lerp(
            -HEIGHT, dropDistance, Ease.sineOut(dropTween.percent)
        );
        super.update();
    }

    private function shoot() {
        var spread = MathUtil.ilerp(
            MIN_SHOT_SPREAD, MAX_SHOT_SPREAD, difficulty
        );
        for(i in 0...BULLETS_PER_SHOT) {
            var spreadAngles = getSpreadAngles(
                BULLETS_PER_SHOT, Math.PI * 2 / spread
            );
            var shotAngle = getAngleTowardsPlayer() + spreadAngles[i];
            var shotSpeed = MathUtil.lerp(
                MIN_SHOT_SPEED, MAX_SHOT_SPEED, difficulty
            );
            scene.add(new EnemyBullet(
                centerX, centerY, shotSpeed, shotAngle,
                0, 0.0001, EnemyBullet.BLUE_CIRCLE
            ));
            scene.add(new EnemyBullet(
                centerX, centerY, shotSpeed, shotAngle,
                0, 0.000075, EnemyBullet.BLUE_CIRCLE
            ));
            if(difficulty > 0.5) {
                scene.add(new EnemyBullet(
                    centerX, centerY, shotSpeed, shotAngle,
                    0, 0.00005, EnemyBullet.BLUE_CIRCLE
                ));
            }
            if(difficulty > 0.75) {
                scene.add(new EnemyBullet(
                    centerX, centerY, shotSpeed, shotAngle,
                    0, 0.000025, EnemyBullet.BLUE_CIRCLE
                ));
            }
        }
    }
}
