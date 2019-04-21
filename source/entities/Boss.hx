package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class Boss extends Enemy {
    public static inline var DROP_TIME = 1;
    public static inline var HEALTH = 1000;
    public static inline var HEIGHT = 120;

    public static inline var MIN_TIME_BETWEEN_SLOW_SHOTS = 0.5;
    public static inline var MAX_TIME_BETWEEN_SLOW_SHOTS = 1.5;
    public static inline var MIN_TIME_BETWEEN_FAST_SHOTS = 0.13;
    public static inline var MAX_TIME_BETWEEN_FAST_SHOTS = 0.25;
    public static inline var MIN_SHOT_SPEED = 0.08;
    public static inline var MAX_SHOT_SPEED = 0.12;
    public static inline var MIN_SPIN_RATE = 2;
    public static inline var MAX_SPIN_RATE = 4;
    public static inline var MIN_SHOT_SPREAD = 64;
    public static inline var MAX_SHOT_SPREAD = 32; // Math.PI * 2 / SPREAD

    public static inline var RING_PORT = 0;
    public static inline var SPIRAL_PORT = 1;
    public static inline var SPRAY_PORT = 2;
    public static inline var EMPTY_PORT = 4;

    private var sprite:Image;
    private var dropDistance:Float;
    private var dropTween:Alarm;
    private var slowShotTimer:Alarm;
    private var fastShotTimer:Alarm;
    private var ports:Array<Int>;

    public function new(x:Float) {
        super(x, -HEIGHT, HEALTH);
        mask = new Hitbox(HEIGHT, HEIGHT);
        sprite = new Image("graphics/boss.png");
        graphic = sprite;
        dropDistance = 24;
        dropTween = new Alarm(DROP_TIME, TweenType.OneShot);
        dropTween.onComplete.bind(function() {
            slowShoot();
            fastShoot();
            slowShotTimer.start();
            fastShotTimer.start();
        });
        addTween(dropTween, true);

        var timeBetweenSlowShots = MathUtil.lerp(
            MAX_TIME_BETWEEN_SLOW_SHOTS,
            MIN_TIME_BETWEEN_SLOW_SHOTS,
            GameScene.difficulty
        );
        slowShotTimer = new Alarm(timeBetweenSlowShots, TweenType.Looping);
        slowShotTimer.onComplete.bind(function() {
            slowShoot();
        });
        addTween(slowShotTimer);

        var timeBetweenFastShots = MathUtil.lerp(
            MAX_TIME_BETWEEN_FAST_SHOTS,
            MIN_TIME_BETWEEN_FAST_SHOTS,
            GameScene.difficulty
        );
        fastShotTimer = new Alarm(timeBetweenFastShots, TweenType.Looping);
        fastShotTimer.onComplete.bind(function() {
            fastShoot();
        });
        addTween(fastShotTimer);

        ports = [
            //RING_PORT, RING_PORT, RING_PORT, RING_PORT, RING_PORT, RING_PORT
            //SPIRAL_PORT, SPIRAL_PORT, SPIRAL_PORT, SPIRAL_PORT, SPIRAL_PORT, SPIRAL_PORT
            //SPRAY_PORT, SPRAY_PORT, SPRAY_PORT, SPRAY_PORT, SPRAY_PORT, SPRAY_PORT
            HXP.choose(RING_PORT, SPRAY_PORT, SPRAY_PORT, EMPTY_PORT),
            HXP.choose(RING_PORT, SPRAY_PORT, SPRAY_PORT, EMPTY_PORT),
            HXP.choose(RING_PORT, SPRAY_PORT, SPRAY_PORT, EMPTY_PORT),
            HXP.choose(RING_PORT, SPRAY_PORT, SPRAY_PORT, EMPTY_PORT),
            HXP.choose(RING_PORT, SPRAY_PORT, SPRAY_PORT, EMPTY_PORT),
            HXP.choose(RING_PORT, SPRAY_PORT, SPRAY_PORT, EMPTY_PORT)
        ];
        var portCount = 0;
        for(port in ports) {
            var portGraphic:Image;
            if(port == EMPTY_PORT) {
                portGraphic = new Image("graphics/bossportempty.png");
            }
            else {
                portGraphic = new Image("graphics/bossport.png");
            }
            portGraphic.x = [24, 84, 144, 24, 84, 144][portCount];
            portGraphic.y = [24, 24, 24, 72, 72, 72][portCount];
            addGraphic(portGraphic);
            portCount++;
        }
    }

    override public function update() {
        y = MathUtil.lerp(
            -HEIGHT, dropDistance, Ease.sineOut(dropTween.percent)
        );
        super.update();
    }

    private function slowShoot() {
        var portCount = 0;
        for(port in ports) {
            var portX = [24, 84, 144, 24, 84, 144][portCount];
            var portY = [24, 24, 24, 72, 72, 72][portCount];
            if(port == RING_PORT) {
                shootRing(portX + x + 12, portY + y + 12);
            }
            else if(port == SPRAY_PORT) {
                shootSpray(portX + x + 12, portY + y + 12);
            }
            portCount++;
        }
    }

    private function fastShoot() {
        var portCount = 0;
        for(port in ports) {
            var portX = [24, 84, 144, 24, 84, 144][portCount];
            var portY = [24, 24, 24, 72, 72, 72][portCount];
            if(port == SPIRAL_PORT) {
                shootSpiral(portX + x + 12, portY + y + 12);
            }
            portCount++;
        }
    }

    private function shootSpiral(shotOriginX:Float, shotOriginY:Float) {
        var bulletsPerShot = MathUtil.ilerp(
            2, 4, GameScene.difficulty
        );
        var spinRate = MathUtil.lerp(
            MIN_SPIN_RATE, MAX_SPIN_RATE, GameScene.difficulty
        );
        for(i in 0...bulletsPerShot) {
            var spreadAngles = getSpreadAngles(bulletsPerShot + 1, Math.PI * 2);
            var shotAngle = age * spinRate + spreadAngles[i];
            var shotSpeed = MathUtil.lerp(
                MIN_SHOT_SPEED, MAX_SHOT_SPEED, GameScene.difficulty
            );
            scene.add(new EnemyBullet(
                shotOriginX, shotOriginY, shotSpeed, shotAngle,
                0, 0.0001, EnemyBullet.BLUE_CIRCLE
            ));
        }
    }

    private function shootRing(shotOriginX:Float, shotOriginY:Float) {
        var bulletsPerShot = MathUtil.ilerp(
            7, 25, GameScene.difficulty
        );
        if(bulletsPerShot % 2 == 0) {
            // Always shoot an odd # of bullets so one is aimed at the player
            bulletsPerShot -= 1;
        }
        for(i in 0...bulletsPerShot) {
            // Circular shot
            var spreadAngles = getSpreadAngles(bulletsPerShot, Math.PI * 2);
            var shotAngle = getAngleTowardsPlayer() + spreadAngles[i];
            var shotSpeed = MathUtil.lerp(
                MIN_SHOT_SPEED, MAX_SHOT_SPEED, GameScene.difficulty
            );
            scene.add(new EnemyBullet(
                shotOriginX, shotOriginY, shotSpeed, shotAngle,
                0, 0.0001, EnemyBullet.BLUE_CIRCLE
            ));
        }
    }

    private function shootSpray(shotOriginX:Float, shotOriginY:Float) {
        var bulletsPerShot = MathUtil.ilerp(
            1, 3, GameScene.difficulty
        );
        var spread = MathUtil.ilerp(
            MIN_SHOT_SPREAD, MAX_SHOT_SPREAD, GameScene.difficulty
        );
        for(i in 0...bulletsPerShot) {
            var sprayAngles = getSprayAngles(
                bulletsPerShot, Math.PI * 2 / spread
            );
            var shotAngle = getAngleTowardsPlayer() + sprayAngles[i];
            var shotSpeed = MathUtil.lerp(
                MIN_SHOT_SPEED, MAX_SHOT_SPEED, GameScene.difficulty
            );
            scene.add(new EnemyBullet(
                shotOriginX, shotOriginY, shotSpeed, shotAngle,
                //0.0005 * (Math.random() - 0.5),
                0,
                0.0003 * Math.max(0.2, Math.random()),
                EnemyBullet.BLUE_CIRCLE
            ));
        }
    }
}
