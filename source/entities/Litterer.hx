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
    public static inline var HEALTH = 25;
    public static inline var MIN_TIME_BETWEEN_SHOTS = 2;
    public static inline var MAX_TIME_BETWEEN_SHOTS = 3.5;
    public static inline var MIN_SHOT_SPEED = 0.15;
    public static inline var MAX_SHOT_SPEED = 0.2;
    public static inline var SHOT_ACCEL = 0.000015;
    public static inline var HEIGHT = 24;
    public static inline var MIN_SUBROUTINE_INTERVAL = 0.2;
    public static inline var MAX_SUBROUTINE_INTERVAL = 0.8;
    public static inline var SUBROUTINE_SHOT_ACCEL = 0.000054;

    private var sprite:Image;
    private var dropDistance:Float;
    private var dropTween:Alarm;
    private var shotTimer:Alarm;

    public function new(x:Float) {
        super(x, -HEIGHT, HEALTH);
        mask = new Hitbox(HEIGHT, HEIGHT);
        sprite = new Image("graphics/litterer.png");
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
            centerX, centerY, shotSpeed, shotAngle, 0, SHOT_ACCEL,
            EnemyBullet.BLUE_CIRCLE, shotSubroutine, subroutineInterval
        ));
    }

    private function shotSubroutine(parent:EnemyBullet) {
        if(scene == null) {
            return;
        }
        scene.add(new EnemyBullet(
            parent.centerX, parent.centerY, 0,
            getAngleTowardsPlayer(), 0, SUBROUTINE_SHOT_ACCEL,
            EnemyBullet.YELLOW_CIRCLE
        ));
    }
}


