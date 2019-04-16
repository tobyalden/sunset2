package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class Scatterer extends Enemy {
    public static inline var DROP_TIME = 1;
    public static inline var HEALTH = 25;
    public static inline var MIN_TIME_BETWEEN_SHOTS = 2.8;
    public static inline var MAX_TIME_BETWEEN_SHOTS = 3.9;
    public static inline var MIN_SHOT_SPEED = 0.15;
    public static inline var MAX_SHOT_SPEED = 0.18;
    public static inline var SHOT_ACCEL = 0.00001;
    public static inline var SHOT_ROTATION = 0.00065;
    public static inline var HEIGHT = 24;
    public static inline var MIN_SUBROUTINE_INTERVAL = 0.2;
    public static inline var MAX_SUBROUTINE_INTERVAL = 0.8;
    public static inline var SUBROUTINE_SHOT_ACCEL = 0.000084;

    private var sprite:Image;
    private var dropDistance:Float;
    private var dropTween:Alarm;
    private var shotTimer:Alarm;

    public function new(x:Float) {
        super(x, -HEIGHT, HEALTH);
        mask = new Hitbox(HEIGHT, HEIGHT);
        sprite = new Image("graphics/scatterer.png");
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
        var shotAngle = getAngleTowardsPlayer();
        var shotSpeed = MathUtil.lerp(
            MIN_SHOT_SPEED, MAX_SHOT_SPEED, GameScene.difficulty
        );
        var subroutineInterval = MathUtil.lerp(
            MAX_SUBROUTINE_INTERVAL, MIN_SUBROUTINE_INTERVAL,
            GameScene.difficulty
        );
        scene.add(new EnemyBullet(
            centerX, centerY, shotSpeed, shotAngle,
            SHOT_ROTATION, SHOT_ACCEL,
            EnemyBullet.BLUE_CIRCLE, shotSubroutine, subroutineInterval
        ));
        scene.add(new EnemyBullet(
            centerX, centerY, shotSpeed, shotAngle,
            -SHOT_ROTATION, SHOT_ACCEL,
            EnemyBullet.BLUE_CIRCLE, shotSubroutine, subroutineInterval
        ));
    }

    private function shotSubroutine(parent:EnemyBullet) {
        if(HXP.scene == null) {
            return;
        }
        HXP.scene.add(new EnemyBullet(
            parent.centerX, parent.centerY, 0,
            Math.random() * Math.PI - Math.PI / 2, 0, SUBROUTINE_SHOT_ACCEL,
            EnemyBullet.YELLOW_CIRCLE
        ));
    }
}



