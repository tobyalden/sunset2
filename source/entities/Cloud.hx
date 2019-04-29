package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.graphics.text.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import scenes.*;

class Cloud extends Entity {
    public static inline var MIN_SPEED = 0.1;
    public static inline var MAX_SPEED = 0.15;
    public static inline var MIN_OPACITY = 0.3;
    public static inline var MAX_OPACITY = 0.1;

    private var sprite:Image;
    private var speed:Float;

    public function new(x:Float, y:Float) {
        super(x, y);
        layer = 5;
        sprite = new Image(
            "graphics/clouds.png", 
            new Rectangle(HXP.choose(0, 50, 100, 150), 0, 50, 50)
        );
        graphic = sprite;
        var lerpAmount = Math.random();
        speed = MathUtil.lerp(MIN_SPEED, MAX_SPEED, lerpAmount);
        graphic.alpha = MathUtil.lerp(MIN_OPACITY, MAX_OPACITY, lerpAmount);
    }

    override function update() {
        var velocity = new Vector2(0, speed);
        moveBy(
            velocity.x * Main.getDelta(),
            velocity.y * Main.getDelta()
        );
        if(y > 360) {
            y -= 420;
        }
    }
}


