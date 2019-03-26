package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.utils.*;

class FireworkBullet extends EnemyBullet {
    public static inline var SPEED = 0.3;

    private var elapsed:Float;
    private var fireworkDelay:Float;
    private var bulletsInFirework:Int;
    private var fireworkBulletSpeed:Float;

    public function new(
        x:Int,
        y:Int,
        velocity:Vector2,
        decel:Float = 1,
        fireworkDelay = 1800.0,
        bulletsInFirework = 5,
        fireworkBulletSpeed = 0.1
    ) {
        mask = new Hitbox(4, 4, -3, -3);
        super(x, y, velocity, decel);
        this.fireworkDelay = fireworkDelay;
        this.bulletsInFirework = bulletsInFirework;
        this.fireworkBulletSpeed = fireworkBulletSpeed;
        sprite = new Image('graphics/enemybullet.png');
        sprite.centerOrigin();
        graphic = sprite;
        elapsed = 0;
    }

    override public function update() {
        elapsed += Main.getDelta();
        if(elapsed > fireworkDelay) {
            firework();
        }
        sprite.color = Color.colorLerp(
            Color.getColorRGB(255, 255, 255),
            Color.getColorRGB(255, 0, 0),
            Math.min(elapsed, fireworkDelay) / fireworkDelay
        );
        super.update();
    }

    public function firework() {
        var stepAngle = (Math.PI * 2) / bulletsInFirework;
        for(i in 0...bulletsInFirework) {
            var shotVelocity = new Vector2(0, Spinner.ELITE_SHOT_SPEED);
            shotVelocity.rotate(stepAngle * i);
            scene.add(new EnemyBullet(
                Std.int(centerX),
                Std.int(centerY),
                shotVelocity,
                0.995
            ));
        }
        scene.remove(this);
    }
}
