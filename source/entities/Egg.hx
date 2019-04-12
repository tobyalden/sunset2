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
    public static inline var SHOT_SPEED = 0.2;
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

    private function shoot() {
        for(i in 0...5) {
            var spreadAngles = getSpreadAngles(5, Math.PI / 4);
            var shotAngle = getAngleTowardsPlayer() + spreadAngles[i];
            scene.add(new EnemyBullet(
                centerX, centerY, SHOT_SPEED, shotAngle
            ));
        }
    }

    private function getSpreadAngles(numAngles:Int, maxSpread:Float) {
        var spreadAngles = new Array<Float>();
        var startAngle = -maxSpread / 2;
        var angleIncrement = maxSpread / (numAngles - 1);
        for(i in 0...numAngles) {
            spreadAngles.push(startAngle + angleIncrement * i);
        }
        return spreadAngles;
    }

    public function getAngleTowardsPlayer() {
        var player = scene.getInstance("player");
        return (
            Math.atan2(player.centerY - centerY, player.centerX - centerX)
            - Math.PI / 2
        );
    }

    public function degreesToRadians(degrees:Float) {
        return Math.PI / 180 * degrees;
    }

    override public function update() {
        y = MathUtil.lerp(
            -HEIGHT, dropDistance, Ease.sineOut(dropTween.percent)
        );
        super.update();
    }

    private function isInPosition() {
        return y == dropDistance;
    }
}
