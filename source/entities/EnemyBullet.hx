package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;

class EnemyBullet extends Entity {
    public static inline var SPEED = 0.3;

    private var velocity:Vector2;
    private var sprite:Image;
    private var decel:Float;

    public function new(
        x:Int, y:Int, velocity:Vector2, decel:Float = 1
    ) {
        mask = new Hitbox(4, 4, -3, -3);
        super(x, y);
        this.decel = decel;
        type = "enemybullet";

        this.velocity = velocity;

        sprite = new Image('graphics/enemybullet.png');
        sprite.centerOrigin();
        graphic = sprite;
        layer = 1;
    }

    override public function update() {
        velocity.scale(decel);
        moveBy(
            velocity.x * Main.getDelta(),
            velocity.y * Main.getDelta()
        );
        if(
            x < -width || x > HXP.width
            || y < -height || y > HXP.height
        ) {
            // Remove offscreen bullets
            scene.remove(this);
        }
        super.update();
    }
}
