package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;

class PlayerBullet extends Entity {
    public static inline var SPEED = 0.3;

    private var velocity:Vector2;
    private var sprite:Image;
    private var sfx:Map<String, Sfx>;

    public function new(player:Player) {
        mask = new Hitbox(8, 16);
        super(player.x + player.width / 2 - width / 2, player.y);
        type = "playerbullet";

        velocity = new Vector2(0, -SPEED);

        sprite = new Image('graphics/playerbullet.png');
        graphic = sprite;
        layer = 1;

        sfx = [
            'hit1' => new Sfx('audio/bullethit1.wav'),
            'hit2' => new Sfx('audio/bullethit2.wav'),
            'hit3' => new Sfx('audio/bullethit3.wav')
        ];
    }

    override public function update() {
        moveBy(
            velocity.x * Main.getDelta(),
            velocity.y * Main.getDelta()
        );
        if(y < 0 - height) {
            scene.remove(this);
        }
        var enemy = collide("enemy", x, y);
        if(enemy != null) {
            cast(enemy, Rock).takeHit();
            die();
        }
        super.update();
    }

    public function die() {
        sfx['hit${HXP.choose(1, 2, 3)}'].play();
        explode(2);
        scene.remove(this);
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
                centerX, centerY, directions[count], true
            );
            explosion.layer = -99;
            scene.add(explosion);
            count++;
        }
    }
}
