package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;

class Spinner extends Enemy {
    public static inline var SPEED = 0.05;
    public static inline var MIN_DROP = 10;
    public static inline var MAX_DROP = 180;
    public static inline var SPIN_SPEED = 0.0007;
    //public static inline var SHOT_COOLDOWN = 0.2;
    public static inline var SHOT_COOLDOWN = 0.8;
    public static inline var SHOT_SPEED = 0.2;
    public static inline var SHOT_DECEL_RATE = 0.992;
    public static inline var ELITE_SPIN_SPEED = 0.0006;
    public static inline var ELITE_SHOT_COOLDOWN = 0.1;
    public static inline var ELITE_SHOT_SPEED = 0.14;
    public static inline var ELITE_SHOT_DECEL_RATE = 0.998;
    public static inline var SPRAY = 0.2;

    private var sprite:Spritemap;
    private var dropDistance:Float;
    private var shotCooldown:Alarm;
    private var shotAngle:Float;
    private var clockwise:Bool;
    private var isElite:Bool;

    public function new(x:Int, y:Int, isElite:Bool) {
        super(x, y);
        this.isElite = isElite;
        mask = new Circle(12);
        sprite = new Spritemap(
            'graphics/${isElite ? 'elitespinner.png' : 'spinner.png'}',
            24, 24
        );
        sprite.add('idle', [0]);
        sprite.play('idle');
        sprite.centerOrigin();
        sprite.x = 12;
        sprite.y = 12;
        graphic = sprite;
        health = 5;
        dropDistance = Math.random() * (MAX_DROP - MIN_DROP) + MIN_DROP;
        shotCooldown = new Alarm(
            isElite ? ELITE_SHOT_COOLDOWN : SHOT_COOLDOWN,
            TweenType.Looping
        );
        shotCooldown.onComplete.bind(function() {
            shoot();
        });
        addTween(shotCooldown);
        clockwise = HXP.choose(true, false);
    }

    override public function update() {
        if(y < dropDistance) {
            velocity.y = SPEED;
        }
        else {
            if(velocity.y != 0) {
                shoot();
                shotCooldown.start();
            }
            velocity.y = 0;
            var spinSpeed = isElite ? ELITE_SPIN_SPEED : SPIN_SPEED;
            if(clockwise) {
                sprite.angle = -shotAngle * 57.2958;
                shotAngle += spinSpeed * Main.getDelta();
                if(shotAngle > Math.PI * 2) {
                    shotAngle -= Math.PI * 2;
                }
            }
            else {
                sprite.angle = -shotAngle * 57.2958;
                shotAngle -= spinSpeed * Main.getDelta();
                if(shotAngle < 0) {
                    shotAngle += Math.PI * 2;
                }
            }
        }
        super.update();
    }

    private function shoot() {
        var shotSpeed = isElite ? ELITE_SHOT_SPEED : SHOT_SPEED;
        var shotVelocities:Array<Vector2>;
        if(isElite) {
            shotVelocities = [
                new Vector2((Math.random() - 0.5) * SPRAY, shotSpeed),
                new Vector2((Math.random() - 0.5) * SPRAY, shotSpeed),
                new Vector2((Math.random() - 0.5) * SPRAY, shotSpeed),
                new Vector2((Math.random() - 0.5) * SPRAY, -shotSpeed),
                new Vector2((Math.random() - 0.5) * SPRAY, -shotSpeed),
                new Vector2((Math.random() - 0.5) * SPRAY, -shotSpeed),
                new Vector2(shotSpeed, (Math.random() - 0.5) * SPRAY),
                new Vector2(shotSpeed, (Math.random() - 0.5) * SPRAY),
                new Vector2(shotSpeed, (Math.random() - 0.5) * SPRAY),
                new Vector2(-shotSpeed, (Math.random() - 0.5) * SPRAY),
                new Vector2(-shotSpeed, (Math.random() - 0.5) * SPRAY),
                new Vector2(-shotSpeed, (Math.random() - 0.5) * SPRAY)
            ];
        }
        else {
            shotVelocities = [
                new Vector2(0, shotSpeed),
                new Vector2(0, -shotSpeed),
                new Vector2(shotSpeed, 0),
                new Vector2(-shotSpeed, 0)
            ];
        }
        for(shotVelocity in shotVelocities) {
            shotVelocity.rotate(shotAngle);
            scene.add(new FireworkBullet(
                Std.int(centerX),
                Std.int(centerY),
                shotVelocity,
                isElite? ELITE_SHOT_DECEL_RATE : SHOT_DECEL_RATE
            ));
        }
    }
}

