package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;

class EnemyBullet extends Entity {
    private var speed:Float;
    private var angle:Float;
    private var sprite:Image;

    public function new(x:Float, y:Float, speed:Float, angle:Float) {
        super(x, y);
        this.speed = speed;
        this.angle = angle;
        type = "enemybullet";

        mask = new Hitbox(4, 4, -3, -3);

        sprite = new Image("graphics/enemybullet.png");
        sprite.centerOrigin();
        graphic = sprite;
        layer = 1;
    }

    override public function update() {
        var velocity = new Vector2(0, speed);
        velocity.rotate(angle);
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
