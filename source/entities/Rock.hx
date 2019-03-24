package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;

class Rock extends Enemy {
    public static inline var FALL_ACCEL = 0.0001;
    public static inline var ACCEL_VARIATION = 0.0002;

    private var acceleration:Vector2;
    private var sprite:Image;

    public function new(x:Int, y:Int) {
        super(x, y);

        acceleration = new Vector2(
            0, FALL_ACCEL + ACCEL_VARIATION * Math.random()
        );
        mask = new Hitbox(32, 32);

        sprite = new Image(
            'graphics/rock${HXP.choose(1, 2, 3, 4)}.png'
        );
        graphic = sprite;
        health = 3;
    }

    override public function update() {
        velocity.x += acceleration.x * Main.getDelta();
        velocity.y += acceleration.y * Main.getDelta();
        super.update();
    }
}
