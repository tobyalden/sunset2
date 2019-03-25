package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;

class Player extends Entity {
    public static inline var SPEED = 0.125;
    public static inline var SHOT_COOLDOWN = 0.1;

    private var velocity:Vector2;
    private var sprite:Spritemap;
    private var shotCooldown:Alarm;
    private var sfx:Map<String, Sfx>;

    public function new(x:Int, y:Int) {
        super(x, y);

        velocity = new Vector2(0, 0);
        setHitbox(16, 16);

        sprite = new Spritemap('graphics/player.png', 16, 16);
        sprite.add('idle', [0]);
        graphic = sprite;

        shotCooldown = new Alarm(SHOT_COOLDOWN, TweenType.Persist);
        addTween(shotCooldown);

        sfx = [
            'shoot1' => new Sfx('audio/shoot1.wav'),
            'shoot2' => new Sfx('audio/shoot2.wav'),
            'shoot3' => new Sfx('audio/shoot3.wav')
        ];
    }

    override public function update() {
        movement();
        shooting();
        if(
            collide("enemybullet", x , y) != null
            || collide("enemy", x , y) != null
        ) {
            sprite.color = 0xFF0000;
        }
        else {
            sprite.color = 0xFFFFFF;
        }
        super.update();
    }

    private function movement() {
        if(Main.inputCheck('up')) {
            velocity.y = -SPEED;
        }
        else if(Main.inputCheck('down')) {
            velocity.y = SPEED;
        }
        else {
            velocity.y = 0;
        }
        if(Main.inputCheck('left')) {
            velocity.x = -SPEED;
        }
        else if(Main.inputCheck('right')) {
            velocity.x = SPEED;
        }
        else {
            velocity.x = 0;
        }
        moveBy(
            velocity.x * Main.getDelta(),
            velocity.y * Main.getDelta()
        );

        // Don't let the player leave the screen
        x = Math.max(x, 0);
        x = Math.min(x, HXP.width - width);
        y = Math.max(y, 0);
        y = Math.min(y, HXP.height - height);
    }

    private function shooting() {
        if(Main.inputCheck('shoot')) {
            if(!shotCooldown.active) {
                scene.add(new PlayerBullet(this));
                shotCooldown.start();
                sfx['shoot${HXP.choose(1, 2, 3)}'].play();
            }
        }
    }
}
