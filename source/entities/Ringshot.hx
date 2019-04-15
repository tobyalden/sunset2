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
    public static inline var HEIGHT = 24;

    private var sprite:Image;
    private var dropDistance:Float;
    private var dropTween:Alarm;
    private var shotTimer:Alarm;

    public function new(x:Float) {
        super(x, -HEIGHT, HEALTH);
        mask = new Hitbox(HEIGHT, HEIGHT);
        sprite = new Image("graphics/ringshot.png");
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
        if(bulletsPerShot % 2 == 0) {
            // Always shoot an odd # of bullets so one is aimed at the player
            bulletsPerShot -= 1;
        }
        for(i in 0...bulletsPerShot) {
            // Circular shot
            var spreadAngles = getSpreadAngles(bulletsPerShot, Math.PI * 2);
            var shotAngle = getAngleTowardsPlayer() + spreadAngles[i];
            var shotSpeed = MathUtil.lerp(
                MIN_SHOT_SPEED, MAX_SHOT_SPEED, GameScene.difficulty
            );
            scene.add(new EnemyBullet(
                centerX, centerY, shotSpeed, shotAngle,
                0, 0.0001, EnemyBullet.BLUE_CIRCLE
            ));
        }
    }
}

