package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;

class Cactus extends Enemy {
    public static inline var SPEED = 0.05;
    public static inline var MIN_DROP = 10;
    public static inline var MAX_DROP = 180;
    public static inline var SHOT_COOLDOWN = 1;
    public static inline var SHOT_SPEED = 0.1;

    private var sprite:Spritemap;
    private var dropDistance:Float;
    private var shotCooldown:Alarm;

    public function new(x:Int, y:Int) {
        super(x, y);
        mask = new Hitbox(24, 24);
        sprite = new Spritemap('graphics/cactus.png', 24, 24);
        sprite.add('idle', [0, 1, 2], 10);
        sprite.play('idle');
        graphic = sprite;
        health = 3;
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
            velocity.y = 0;
            if(velocity.x == 0) {
                velocity.x = HXP.choose(SPEED, -SPEED);
                shotCooldown.start();
            }
        }
        super.update();
    }

    private function shoot() {
        if(velocity.x == 0) {
            return;
        }
        scene.add(new EnemyBullet(
            Std.int(centerX),
            Std.int(centerY),
            new Vector2(0, SHOT_SPEED)
        ));
    }
}
