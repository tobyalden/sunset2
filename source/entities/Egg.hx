package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class Egg extends Enemy {
    public static inline var DROP_TIME = 1;
    public static inline var HEALTH = 100;
    public static inline var MIN_TIME_BETWEEN_SHOTS = 0.5;
    public static inline var MAX_TIME_BETWEEN_SHOTS = 1;
    public static inline var MIN_BULLETS_PER_SHOT = 4;
    public static inline var MAX_BULLETS_PER_SHOT = 12;
    public static inline var CIRCULAR_SHOT_SPEED = 0.08;
    public static inline var TARGETED_SHOT_SPEED = 0.15;
    public static inline var SHOT_SPREAD = 30; // Math.PI * 2 / SHOT_SPREAD
    public static inline var SHOT_ROTATION = 0.0005;
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
        var bulletsPerShot = MathUtil.ilerp(
            MIN_BULLETS_PER_SHOT, MAX_BULLETS_PER_SHOT, GameScene.difficulty
        );
        for(i in 0...bulletsPerShot) {
            // Circular shot
            var spreadAngles = getSpreadAngles(bulletsPerShot, Math.PI * 2);
            var shotAngle = spreadAngles[i];
            scene.add(new EnemyBullet(
                centerX, centerY, CIRCULAR_SHOT_SPEED, shotAngle,
                SHOT_ROTATION, 0, EnemyBullet.BLUE_CIRCLE
            ));
            scene.add(new EnemyBullet(
                centerX, centerY, CIRCULAR_SHOT_SPEED, shotAngle,
                -SHOT_ROTATION, 0, EnemyBullet.BLUE_CIRCLE
            ));

            // Targeted shot
            var sprayAngles = getSprayAngles(
                bulletsPerShot, Math.PI * 2 / SHOT_SPREAD
            );
            shotAngle = getAngleTowardsPlayer() + sprayAngles[i];
            scene.add(new EnemyBullet(
                centerX, centerY, TARGETED_SHOT_SPEED, shotAngle, 0,
                Random.random * 0.0001,
                EnemyBullet.YELLOW_CIRCLE
            ));
        }
    }
}
