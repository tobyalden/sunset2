package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;

class EnemyBullet extends Entity {
    public static inline var BLUE_CIRCLE = 0;
    public static inline var YELLOW_CIRCLE = 1;

    public var speed(default, null):Float;
    public var angle(default, null):Float;
    private var startAngle:Float;
    private var sprite:Image;
    private var age:Float;
    private var rotation:Float;
    private var accel:Float;
    private var subroutineTimer:Alarm;

    public function new(
        x:Float, y:Float, speed:Float, angle:Float, rotation:Float,
        accel:Float, bulletType:Int, ?subroutine:EnemyBullet->Void,
        ?subroutineInterval:Float
    ) {
        super(x, y);
        this.speed = speed;
        this.angle = angle;
        this.startAngle = angle;
        this.rotation = rotation;
        this.accel = accel;
        type = "enemybullet";
        mask = new Hitbox(4, 4, -3, -3);

        if(bulletType == BLUE_CIRCLE) {
            sprite = new Image("graphics/enemybullet.png");
        }
        else {
            sprite = new Image("graphics/enemybullet2.png");
        }
        sprite.centerOrigin();
        graphic = sprite;
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
        super.update();
    }
}
