package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.math.*;

class PlayerBullet extends Entity {
    public static inline var SPEED = 0.3;

    private var velocity:Vector2;
    private var sprite:Image;

    public function new(player:Player) {
        setHitbox(8, 16);
        super(player.x + player.width / 2 - width / 2, player.y);

        velocity = new Vector2(0, -SPEED);

        sprite = new Image('graphics/playerbullet.png');
        graphic = sprite;
        layer = 1;
    }

    override public function update() {
        moveBy(
            velocity.x * Main.getDelta(),
            velocity.y * Main.getDelta()
        );
        if(y < 0 - height) {
            scene.remove(this);
        }
        super.update();
    }
}
