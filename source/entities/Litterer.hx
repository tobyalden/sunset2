package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class Litterer extends Enemy {
    public static inline var DROP_TIME = 1;
    public static inline var HEALTH = 33;
    public static inline var MIN_TIME_BETWEEN_SHOTS = 2;
    public static inline var MAX_TIME_BETWEEN_SHOTS = 3.5;
    public static inline var MIN_SHOT_SPEED = 0.15;
    public static inline var MAX_SHOT_SPEED = 0.2;
    public static inline var SHOT_ACCEL = 0.000015;
    public static inline var MIN_SUBROUTINE_INTERVAL = 0.2;
    public static inline var MAX_SUBROUTINE_INTERVAL = 0.8;
    public static inline var SUBROUTINE_SHOT_ACCEL = 0.000054;
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
        sprite.add("toaster", [0, 1, 2], 5);
        sprite.add("toasterslow", [3, 4, 5], 5);
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
            sprite.setAnimFrame(
                Main.isSlowmo() ? "toasterslow" : "toaster",
                [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2][
                    MathUtil.ilerp(0, 20, percent)
                ]
            );
        }
        else {
            sprite.setAnimFrame(
                Main.isSlowmo() ? "toasterslow" : "toaster",
                [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2][
                    MathUtil.ilerp(0, 20, percent)
                ]
            );
        }
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
        var subroutineInterval = MathUtil.lerp(
            MAX_SUBROUTINE_INTERVAL, MIN_SUBROUTINE_INTERVAL,
            difficulty
        );
        scene.add(new EnemyBullet(
            centerX, centerY, shotSpeed, shotAngle, 0, SHOT_ACCEL,
            EnemyBullet.ALT_STAR, shotSubroutine, subroutineInterval
        ));
    }

    private function shotSubroutine(parent:EnemyBullet) {
        if(scene == null) {
            return;
        }
        scene.add(new EnemyBullet(
            parent.centerX, parent.centerY, 0,
            getAngleTowardsPlayer(), 0, SUBROUTINE_SHOT_ACCEL,
            EnemyBullet.ALT
        ));
    }
}


