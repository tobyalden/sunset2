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
    public static inline var INVINCIBLE_TIME_ON_RESPAWN = 1;
    public static inline var FLICKER_SPEED = 0.05;

    public var velocity(default, null):Vector2;
    public var sprite(default, null):Spritemap;
    public var heart(default, null):Spritemap;
    public var lives(default, null):Int;
    private var shotCooldown:Alarm;
    private var sfx:Map<String, Sfx>;
    private var isDead:Bool;
    private var invincibilityTimer:Alarm;
    private var age:Float;

    public function new(x:Float, y:Float) {
        super(x, y);
        name = "player";

        velocity = new Vector2(0, 0);
        mask = new Hitbox(4, 4, 6, 6);

        sprite = new Spritemap('graphics/player.png', 16, 16);
        sprite.add('idle', [5, 6, 7]);
        sprite.add('idleslow', [1, 2, 3]);

        heart = new Spritemap('graphics/player.png', 16, 16);
        heart.add('idle', [4]);
        heart.add('idleslow', [0]);

        addGraphic(sprite);
        addGraphic(heart);

        shotCooldown = new Alarm(SHOT_COOLDOWN, TweenType.Persist);
        addTween(shotCooldown);

        invincibilityTimer = new Alarm(
            INVINCIBLE_TIME_ON_RESPAWN, TweenType.Persist
        );
        addTween(invincibilityTimer);

        sfx = [
            'shoot1' => new Sfx('audio/shoot1.wav'),
            'shoot2' => new Sfx('audio/shoot2.wav'),
            'shoot3' => new Sfx('audio/shoot3.wav')
        ];

        isDead = false;
        lives = 3;
        age = 0;
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
        if(isDead) {
            visible = false;
        }
        else if(invincibilityTimer.active) {
            visible = Math.floor(
                invincibilityTimer.elapsed / FLICKER_SPEED
            ) % 2 == 0;
        }
        else {
            visible = true;
        }

        if(!isDead) {
            movement();
            shooting();

            sprite.setAnimFrame(
                Main.isSlowmo() ? "idle" : "idleslow",
                [0, 1, 2, 1, 0][MathUtil.ilerp(0, 5, ((age * 4) % 1))]
            );
            heart.setAnimFrame(
                Main.isSlowmo() ? "idle" : "idleslow", 0
            );

            if(
                collide("enemybullet", x , y) != null
                || collide("enemy", x , y) != null
            ) {
                isDead = true;
                explode(23);
                visible = false;
                var resetTimer = new Alarm(1, TweenType.OneShot);
                resetTimer.onComplete.bind(function() {
                    respawn();
                });
                addTween(resetTimer, true);
            }
        }
        age += Main.getDelta() / 1000;
        super.update();
    }

    private function respawn() {
        x = HXP.width / 2 - 8;
        y = HXP.height - 100;
        isDead = false;
        invincibilityTimer.start();
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
