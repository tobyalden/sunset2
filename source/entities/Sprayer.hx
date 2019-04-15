package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class Sprayer extends Enemy {
    public static inline var DROP_TIME = 1;
    public static inline var HEALTH = 25;
    public static inline var MIN_TIME_BETWEEN_SHOTS = 0.85;
    public static inline var MAX_TIME_BETWEEN_SHOTS = 1.6;
    public static inline var MIN_BULLETS_PER_SHOT = 3;
    public static inline var MAX_BULLETS_PER_SHOT = 6;
    public static inline var MIN_SHOT_SPEED = 0.09;
    public static inline var MAX_SHOT_SPEED = 0.12;
    public static inline var MIN_SHOT_SPREAD = 16;
    public static inline var MAX_SHOT_SPREAD = 8; // Math.PI * 2 / SPREAD
    public static inline var HEIGHT = 24;

    private var sprite:Image;
    private var dropDistance:Float;
    private var dropTween:Alarm;
    private var shotTimer:Alarm;

    public function new(x:Float) {
        super(x, -HEIGHT, HEALTH);
        mask = new Hitbox(HEIGHT, HEIGHT);
        sprite = new Image("graphics/sprayer.png");
        graphic = sprite;
        dropDistance = GameScene.getEnemyYPosition();
        dropTween = new Alarm(DROP_TIME * Math.random(), TweenType.OneShot);
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
        var spread = MathUtil.ilerp(
            MIN_SHOT_SPREAD, MAX_SHOT_SPREAD, GameScene.difficulty
        );
        for(i in 0...bulletsPerShot) {
            var sprayAngles = getSprayAngles(
                bulletsPerShot, Math.PI * 2 / spread
            );
            var shotAngle = getAngleTowardsPlayer() + sprayAngles[i];
            var shotSpeed = MathUtil.lerp(
                MIN_SHOT_SPEED, MAX_SHOT_SPEED, GameScene.difficulty
            );
            scene.add(new EnemyBullet(
                centerX, centerY, shotSpeed, shotAngle,
                //0.0005 * (Math.random() - 0.5),
                0,
                0.0003 * Math.max(0.2, Math.random()),
                EnemyBullet.BLUE_CIRCLE
            ));
        }
    }
}
