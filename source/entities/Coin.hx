package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.graphics.text.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import scenes.*;

class Coin extends Entity {
    public static inline var MIN_SPEED = 0.1;
    public static inline var MAX_SPEED = 0.12;
    public static inline var MAX_SPREAD = 0.01;
    public static inline var MIN_ACCEL = 0.00014;
    public static inline var MAX_ACCEL = 0.0002;

    private var sprite:Image;
    private var speed:Float;
    private var spread:Float;
    private var accel:Float;

    public function new(x:Float, y:Float) {
        super(x - 5, y - 5);
        type = "coin";
        mask = new Hitbox(22, 22, -6, -6);
        sprite = new Image("graphics/coin.png");
        graphic = sprite;
        speed = -MathUtil.lerp(MIN_SPEED, MAX_SPEED, Math.random());
        accel = MathUtil.lerp(MIN_ACCEL, MAX_ACCEL, Math.random());
        spread = MathUtil.lerp(-MAX_SPREAD, MAX_SPREAD, Math.random());
    }

    override function update() {
        speed += accel * Main.getDelta();
        var velocity = new Vector2(spread, speed);
        moveBy(
            velocity.x * Main.getDelta(),
            velocity.y * Main.getDelta()
        );
        if(
            x < -width - 10 || x > HXP.width + 10
            || y < -height - 10 || y > HXP.height + 10
        ) {
            // Remove offscreen coins
            scene.remove(this);
        }
    }
}

