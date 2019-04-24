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
    public static inline var MIN_BULLETS_PER_SUBROUTINE_SHOT = 8;
    public static inline var MAX_BULLETS_PER_SUBROUTINE_SHOT = 16;
    public static inline var SUBROUTINE_SHOT_SPEED = 0.1;
    public static inline var SUBROUTINE_SHOT_ACCEL = 0.000035;
    public static inline var WIDTH = 48;
    public static inline var HEIGHT = 26;

    private var sprite:Spritemap;
    private var dropDistance:Float;
    private var dropTween:Alarm;
    private var shotTimer:Alarm;

    public function new(x:Float, difficulty:Float) {
        super(x, -HEIGHT, HEALTH, difficulty);
        mask = new Hitbox(WIDTH, HEIGHT, 0, 32 - HEIGHT - 2);
        sprite = new Spritemap("graphics/48enemies.png", 48, 32);
        sprite.add("eye", [8, 9, 10, 11], 5);
        sprite.add("eyeslow", [14, 15, 16, 17], 5);
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
            Main.isSlowmo() ? "eyeslow" : "eye",
            [3, 2, 1, 0, 1, 2, 3][MathUtil.ilerp(0, 6, percent)]
        );
        y = MathUtil.lerp(
            -HEIGHT, dropDistance, Ease.sineOut(dropTween.percent)
        );
        super.update();
    }

    private function shoot() {
        var shotAngle = getAngleTowardsPlayer() / 2;
        var shotSpeed = MathUtil.lerp(
            MIN_SHOT_SPEED, MAX_SHOT_SPEED, difficulty
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
                0.5, 2,
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
            difficulty
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
