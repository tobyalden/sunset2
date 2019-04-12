package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;

class Egg extends Enemy {
    public static inline var DROP_TIME = 1;
    public static inline var HEALTH = 10;
    public static inline var TIME_BETWEEN_SHOTS = 0.5;
    public static inline var BULLETS_PER_SHOT = 16;
    public static inline var SHOT_SPEED = 0.2;
    public static inline var SHOT_SPREAD = 1; // Math.PI * 2 / SHOT_SPREAD
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

        shotTimer = new Alarm(1, TweenType.Looping);
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
        for(i in 0...BULLETS_PER_SHOT) {
            var spreadAngles = getSpreadAngles(
                BULLETS_PER_SHOT, Math.PI * 2 / SHOT_SPREAD
            );
            var shotAngle = getAngleTowardsPlayer() + spreadAngles[i];
            scene.add(new EnemyBullet(
                centerX, centerY, SHOT_SPEED, shotAngle
            ));
        }
    }
}
