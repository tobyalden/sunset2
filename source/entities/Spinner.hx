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
    public static inline var SPIN_SPEED = 0.0012;
    public static inline var SHOT_COOLDOWN = 0.13;
    public static inline var SHOT_SPEED = 0.12;

    private var sprite:Spritemap;
    private var dropDistance:Float;
    private var shotCooldown:Alarm;
    private var shotAngle:Float;

    public function new(x:Int, y:Int) {
        super(x, y);
        mask = new Circle(12);
        sprite = new Spritemap('graphics/spinner.png', 24, 24);
        sprite.add('idle', [0]);
        sprite.play('idle');
        sprite.centerOrigin();
        sprite.x = 12;
        sprite.y = 12;
        graphic = sprite;
        health = 5;
        dropDistance = Math.random() * (MAX_DROP - MIN_DROP) + MIN_DROP;
        shotCooldown = new Alarm(SHOT_COOLDOWN, TweenType.Looping);
        shotCooldown.onComplete.bind(function() {
            shoot();
        });
        addTween(shotCooldown);
    }

    override public function update() {
        if(y < dropDistance) {
            velocity.y = SPEED;
        }
        else {
            if(velocity.y != 0) {
                shotCooldown.start();
            }
            velocity.y = 0;
            sprite.angle = -shotAngle * 57.2958;
            shotAngle += SPIN_SPEED * Main.getDelta();
            if(shotAngle > Math.PI * 2) {
                shotAngle -= Math.PI * 2;
            }
        }
        super.update();
    }

    private function shoot() {
        var shotVelocities = [
            new Vector2(0, SHOT_SPEED),
            new Vector2(0, -SHOT_SPEED),
            new Vector2(SHOT_SPEED, 0),
            new Vector2(-SHOT_SPEED, 0)
        ];
        for(shotVelocity in shotVelocities) {
            shotVelocity.rotate(shotAngle);
            scene.add(new EnemyBullet(
                Std.int(centerX), Std.int(centerY), shotVelocity
            ));
        }
    }
}

