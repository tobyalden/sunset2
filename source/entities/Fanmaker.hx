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
    public static inline var DROP_TIME = 0.1;
    public static inline var HEALTH = 100;
    public static inline var MIN_TIME_BETWEEN_SHOTS = 0.8;
    public static inline var MAX_TIME_BETWEEN_SHOTS = 1.6;
    public static inline var BULLETS_PER_SHOT = 3;
    public static inline var MIN_SHOT_SPEED = 0.09;
    public static inline var MAX_SHOT_SPEED = 0.12;
    public static inline var MIN_SHOT_SPREAD = 30;
    public static inline var MAX_SHOT_SPREAD = 15; // Math.PI * 2 / SPREAD
    public static inline var HEIGHT = 24;

    private var sprite:Image;
    private var dropDistance:Float;
    private var dropTween:Alarm;
    private var shotTimer:Alarm;

    public function new(x:Float) {
        super(x, -HEIGHT, HEALTH);
        mask = new Hitbox(HEIGHT, HEIGHT);
        sprite = new Image("graphics/egg.png");
        graphic = sprite;
        dropDistance = (
            Enemy.MIN_DROP_DISTANCE
            + Random.random
            * (Enemy.MAX_DROP_DISTANCE - Enemy.MIN_DROP_DISTANCE)
        );
        dropTween = new Alarm(DROP_TIME, TweenType.OneShot);
        dropTween.onComplete.bind(function() {
            shoot();
            shotTimer.start();
        });
        addTween(dropTween, true);

        var timeBetweenShots = MathUtil.lerp(
            MAX_TIME_BETWEEN_SHOTS,
            MIN_TIME_BETWEEN_SHOTS,
            GameScene.difficulty
        );
        shotTimer = new Alarm(timeBetweenShots, TweenType.Looping);
        shotTimer.onComplete.bind(function() {
            shoot();
        });
        addTween(shotTimer);
    }

    override public function update() {
        y = MathUtil.lerp(
            -HEIGHT, dropDistance, Ease.sineOut(dropTween.percent)
        );
        super.update();
    }

    private function shoot() {
        var spread = MathUtil.ilerp(
            MIN_SHOT_SPREAD, MAX_SHOT_SPREAD, GameScene.difficulty
        );
        for(i in 0...BULLETS_PER_SHOT) {
            var spreadAngles = getSpreadAngles(
                BULLETS_PER_SHOT, Math.PI * 2 / spread
            );
            var shotAngle = getAngleTowardsPlayer() + spreadAngles[i];
            var shotSpeed = MathUtil.lerp(
                MIN_SHOT_SPEED, MAX_SHOT_SPEED, GameScene.difficulty
            );
            scene.add(new EnemyBullet(
                centerX, centerY, shotSpeed, shotAngle,
                0, 0.0001, EnemyBullet.BLUE_CIRCLE
            ));
            scene.add(new EnemyBullet(
                centerX, centerY, shotSpeed, shotAngle,
                0, 0.000075, EnemyBullet.BLUE_CIRCLE
            ));
            if(GameScene.difficulty > 0.5) {
                scene.add(new EnemyBullet(
                    centerX, centerY, shotSpeed, shotAngle,
                    0, 0.00005, EnemyBullet.BLUE_CIRCLE
                ));
            }
            if(GameScene.difficulty > 0.75) {
                scene.add(new EnemyBullet(
                    centerX, centerY, shotSpeed, shotAngle,
                    0, 0.000025, EnemyBullet.BLUE_CIRCLE
                ));
            }
        }
    }
}
