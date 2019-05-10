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
    public var coins(default, null):Int;
    public var isDead(default, null):Bool;
    private var shotCooldown:Alarm;
    private var sfx:Map<String, Sfx>;
    private var invincibilityTimer:Alarm;
    private var age:Float;

    public function new(x:Float, y:Float) {
        super(x, y);
        name = "player";

        velocity = new Vector2(0, 0);
        mask = new Hitbox(4, 4, 6, 6);

        sprite = new Spritemap('graphics/player.png', 16, 16);
        sprite.add('idleslow', [5, 6, 7]);
        sprite.add('idle', [1, 2, 3]);

        heart = new Spritemap('graphics/player.png', 16, 16);
        heart.add('idleslow', [4]);
        heart.add('idle', [0]);

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
            'shoot3' => new Sfx('audio/shoot3.wav'),
            'coin1' => new Sfx('audio/coin1.wav'),
            'coin2' => new Sfx('audio/coin2.wav'),
            'coin3' => new Sfx('audio/coin3.wav'),
            'coin4' => new Sfx('audio/coin4.wav'),
            'coin5' => new Sfx('audio/coin5.wav'),
            'playerdeath' => new Sfx('audio/playerdeath.wav'),
            'respawn' => new Sfx('audio/respawn.wav'),
            'extralife' => new Sfx('audio/extralife.wav')
        ];

        isDead = false;
        lives = 3;
        coins = 0;
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

        if(coins >= 100) {
            sfx['extralife'].play();
            coins -= 100;
            lives++;
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

            var coin = collide("coin", x , y);
            if(coin != null) {
                sfx['coin${HXP.choose(1, 2, 3, 4, 5)}'].play();
                scene.remove(coin);
                coins++;
            }

            if(
                !invincibilityTimer.active
                && collide("enemybullet", x , y) != null
                || collide("enemy", x , y) != null
            ) {
                die();
            }
        }
        age += Main.getDelta() / 1000;
        super.update();
    }

    private function die() {
        isDead = true;
        lives -= 1;
        explode(23);
        sfx['playerdeath'].play();
        visible = false;
        if(lives > 0) {
            var resetTimer = new Alarm(1, TweenType.OneShot);
            resetTimer.onComplete.bind(function() {
                respawn();
            });
            addTween(resetTimer, true);
        }
        else {
            cast(scene, GameScene).gameOver();
        }
    }

    private function respawn() {
        x = HXP.width / 2 - 8;
        y = HXP.height - 100;
        isDead = false;
        invincibilityTimer.start();
        sfx['respawn'].play();
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
        x = Math.min(x, HXP.width - 16);
        y = Math.max(y, 0);
        y = Math.min(y, HXP.height - 16);
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
