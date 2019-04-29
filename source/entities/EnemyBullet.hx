package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;

class EnemyBullet extends Entity {
    public static inline var NORMAL = 0;
    public static inline var STAR = 1;

    public static inline var CONSTANT_INTERVAL = 0.0166666667;

    public var speed(default, null):Float;
    public var angle(default, null):Float;
    public var subroutineTimer(default, null):Alarm;
    private var startAngle:Float;
    private var sprite:Spritemap;
    private var age:Float;
    private var rotation:Float;
    private var accel:Float;
    private var bulletType:Int;

    public function setSpriteScale(newScale:Float) {
        sprite.scale = newScale;
        sprite.x = -(2 + 3) * (newScale - 1);
        sprite.y = -(2 + 3) * (newScale - 1);
    }

    public function new(
        x:Float, y:Float, speed:Float, angle:Float, rotation:Float,
        accel:Float, bulletType:Int, ?subroutine:EnemyBullet->Void,
        ?subroutineInterval:Float
    ) {
        super(x - (2 + 3), y - (2 + 3));
        this.speed = speed;
        this.angle = angle;
        this.startAngle = angle;
        this.rotation = rotation;
        this.accel = accel;
        this.bulletType = bulletType;
        type = "enemybullet";
        mask = new Hitbox(4, 4, 3, 3);

        sprite = new Spritemap("graphics/enemybullets.png", 10, 10);
        sprite.add("star", [0]);
        sprite.add("normal", [1]);
        sprite.add("starslow", [2]);
        sprite.add("normalslow", [3]);
        graphic = sprite;
        graphic.pixelSnapping = true;
        layer = -1;

        age = 0;

        if(subroutine != null && subroutineInterval != null) {
            subroutineTimer = new Alarm(subroutineInterval, TweenType.Looping);
            subroutineTimer.onComplete.bind(function() {
                subroutine(this);
            });
            addTween(subroutineTimer, true);
        }
    }

    override public function update() {
        speed += accel * Main.getDelta();
        var velocity = new Vector2(0, speed);
        angle += rotation * Main.getDelta();
        velocity.rotate(angle);
        moveBy(
            velocity.x * Main.getDelta(),
            velocity.y * Main.getDelta()
        );
        if(
            x < -width - 10 || x > HXP.width + 10
            || y < -height - 10 || y > HXP.height + 10
        ) {
            // Remove offscreen bullets
            scene.remove(this);
        }
        age += Main.getDelta() / 1000;
        if(
            subroutineTimer != null &&
            subroutineTimer.duration != EnemyBullet.CONSTANT_INTERVAL
        ) {
            setSpriteScale(MathUtil.lerp(
                1, 1.4, Ease.sineInOut(subroutineTimer.percent - 0.5)
            ));
        }

        var prefix = bulletType == STAR ? "star" : "normal";
        if(Main.isSlowmo()) {
            sprite.play('${prefix}slow');
        }
        else {
            sprite.play(prefix);
        }

        super.update();
    }

    public function getSubroutineTimerPercent() {
        return subroutineTimer.percent;
    }
}
