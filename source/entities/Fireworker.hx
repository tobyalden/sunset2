package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class Fireworker extends Enemy {
    public static inline var DROP_TIME = 1;
    public static inline var HEALTH = 25;
    public static inline var MIN_TIME_BETWEEN_SHOTS = 1.5;
    public static inline var MAX_TIME_BETWEEN_SHOTS = 2;
    public static inline var MIN_SHOT_SPEED = 0.15;
    public static inline var MAX_SHOT_SPEED = 0.24;
    public static inline var SHOT_ACCEL = -0.00016;
    public static inline var HEIGHT = 24;
    public static inline var MIN_BULLETS_PER_SUBROUTINE_SHOT = 8;
    public static inline var MAX_BULLETS_PER_SUBROUTINE_SHOT = 16;
    public static inline var SUBROUTINE_SHOT_SPEED = 0.1;
    public static inline var SUBROUTINE_SHOT_ACCEL = 0.000035;
    public static inline var SUBROUTINE_Sb = 0.000035;

    private var sprite:Image;
    private var dropDistance:Float;
    private var dropTween:Alarm;
    private var shotTimer:Alarm;

    public function new(x:Float) {
        super(x, -HEIGHT, HEALTH);
        mask = new Hitbox(HEIGHT, HEIGHT);
        sprite = new Image("graphics/fireworker.png");
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
        var shotAngle = getAngleTowardsPlayer() / 2;
        var shotSpeed = MathUtil.lerp(
            MIN_SHOT_SPEED, MAX_SHOT_SPEED, GameScene.difficulty
        );
        scene.add(new EnemyBullet(
            centerX, centerY, shotSpeed, shotAngle, 0,
            SHOT_ACCEL + Math.random() * SHOT_ACCEL,
            EnemyBullet.BLUE_CIRCLE, shotSubroutine,
            EnemyBullet.CONSTANT_INTERVAL
        ));
    }

    private function shotSubroutine(parent:EnemyBullet) {
        if(parent.speed < 0.02) {
            parent.setSpriteScale(MathUtil.lerp(
                0.1, 2,
                Ease.quadIn(Math.min(parent.speed, 0.02) * (1 / 0.02))
            ));
        }
        else if(parent.speed < 0.05) {
            parent.setSpriteScale(MathUtil.lerp(
                2, 1,
                Ease.quadIn(Math.min(parent.speed, 0.05) * (1 / 0.05))
            ));
        }
        if(parent.speed > 0) {
            return;
        }
        var bulletsPerShot = MathUtil.ilerp(
            MIN_BULLETS_PER_SUBROUTINE_SHOT, MAX_BULLETS_PER_SUBROUTINE_SHOT,
            GameScene.difficulty
        );
        for(i in 0...bulletsPerShot) {
            var spreadAngles = getSpreadAngles(bulletsPerShot, Math.PI * 2);
            HXP.scene.add(new EnemyBullet(
                parent.centerX, parent.centerY, SUBROUTINE_SHOT_SPEED,
                spreadAngles[i], 0, 0,
                EnemyBullet.YELLOW_CIRCLE
            ));
        }
        HXP.scene.remove(parent);
    }
}
