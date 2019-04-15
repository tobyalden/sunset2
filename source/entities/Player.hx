package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import scenes.*;

class Player extends Entity {
    public static inline var SPEED = 0.175;
    public static inline var SHOT_COOLDOWN = 0.025;

    public var velocity(default, null):Vector2;
    public var sprite(default, null):Spritemap;
    private var shotCooldown:Alarm;
    private var sfx:Map<String, Sfx>;

    public function new(x:Int, y:Int) {
        super(x, y);
        name = "player";

        velocity = new Vector2(0, 0);
        mask = new Hitbox(4, 4, 6, 6);

        sprite = new Spritemap('graphics/player.png', 16, 16);
        sprite.add('idle', [0]);
        sprite.add('right', [1]);
        sprite.add('left', [2]);
        graphic = sprite;

        shotCooldown = new Alarm(SHOT_COOLDOWN, TweenType.Persist);
        addTween(shotCooldown);

        sfx = [
            'shoot1' => new Sfx('audio/shoot1.wav'),
            'shoot2' => new Sfx('audio/shoot2.wav'),
            'shoot3' => new Sfx('audio/shoot3.wav')
        ];
    }

    private function explode(numExplosions:Int) {
        var directions = new Array<Vector2>();
        for(i in 0...numExplosions) {
            var angle = (2 / numExplosions) * i;
            directions.push(
                new Vector2(Math.cos(angle), Math.sin(angle))
            );
            directions.push(
                new Vector2(-Math.cos(angle), Math.sin(angle))
            );
            directions.push(
                new Vector2(Math.cos(angle), -Math.sin(angle))
            );
            directions.push(
                new Vector2(-Math.cos(angle), -Math.sin(angle))
            );
        }
        var count = 0;
        for(direction in directions) {
            direction.scale(0.8 * Math.random());
            direction.normalize(
                Math.max(0.1 + 0.2 * Math.random(), direction.length)
            );
            var explosion = new Explosion(
                centerX, centerY, directions[count]
            );
            explosion.layer = -99;
            scene.add(explosion);
            count++;
        }
    }

    override public function update() {
        movement();
        shooting();
        if(
            collide("enemybullet", x , y) != null
            || collide("enemy", x , y) != null
        ) {
            explode(23);
            visible = false;
            var resetTimer = new Alarm(2, TweenType.OneShot);
            resetTimer.onComplete.bind(function() {
                HXP.scene = new GameScene();
            });
            addTween(resetTimer, true);
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
            sprite.play("left");
        }
        else if(Main.inputCheck('right')) {
            velocity.x = SPEED;
            sprite.play("right");
        }
        else {
            velocity.x = 0;
            sprite.play("idle");
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
