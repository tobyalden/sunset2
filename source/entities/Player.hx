package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.math.*;

class Player extends Entity {
    public static inline var SPEED = 0.1;

    private var velocity:Vector2;
    private var sprite:Spritemap;

    public function new(x:Int, y:Int) {
        super(x, y);

        velocity = new Vector2(0, 0);
        setHitbox(16, 16);

        sprite = new Spritemap("graphics/player.png", 16, 16);
        sprite.add("idle", [0]);
        graphic = sprite;
    }

    override public function update() {
        if(Main.inputCheck("up")) {
            velocity.y = -SPEED;
        }
        else if(Main.inputCheck("down")) {
            velocity.y = SPEED;
        }
        else {
            velocity.y = 0;
        }
        if(Main.inputCheck("left")) {
            velocity.x = -SPEED;
        }
        else if(Main.inputCheck("right")) {
            velocity.x = SPEED;
        }
        else {
            velocity.x = 0;
        }
        moveBy(
            velocity.x * Main.getDelta(),
            velocity.y * Main.getDelta(),
            "walls"
        );

        // Don't let the player leave the screen
        x = Math.max(x, 0);
        x = Math.min(x, HXP.width - width);
        y = Math.max(y, 0);
        y = Math.min(y, HXP.height - height);

        super.update();
    }
}
