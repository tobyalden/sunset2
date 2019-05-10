package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import scenes.*;

class Enemy extends Entity {
    public static inline var FLICKER_DURATION = 0.2;
    public static inline var FLICKER_SPEED = 0.05;
    public static inline var MIN_DROP_DISTANCE = 50;
    public static inline var MAX_DROP_DISTANCE = 100;

    private var health:Int;
    private var flickerTimer:Alarm;
    private var age:Float;
    private var difficulty:Float;
    private var sfx:Map<String, Sfx>;

    public function new(x:Float, y:Float, health:Int, difficulty:Float) {
        super(x, y);
        this.health = health;
        type = "enemy";
        flickerTimer = new Alarm(FLICKER_DURATION, TweenType.Persist);
        addTween(flickerTimer);
        age = 0;
        sfx = [
            'enemydeath1' => new Sfx('audio/enemydeath1.wav'),
            'enemydeath2' => new Sfx('audio/enemydeath2.wav'),
            'enemydeath3' => new Sfx('audio/enemydeath3.wav')
        ];
    }

    override public function update() {
        if(flickerTimer.active) {
            visible = Math.floor(
                flickerTimer.elapsed / FLICKER_SPEED
            ) % 2 == 0;
        }
        else {
            visible = true;
        }

        if(x < -width || x > HXP.width || y > HXP.height) {
            // Remove offscreen enemies
            scene.remove(this);
        }
        age += Main.getDelta() / 1000;
        super.update();
    }

    public function getSpreadAngles(numAngles:Int, maxSpread:Float) {
        var spreadAngles = new Array<Float>();
        var startAngle = -maxSpread / 2;
        var angleIncrement = maxSpread / (numAngles - 1);
        for(i in 0...numAngles) {
            spreadAngles.push(startAngle + angleIncrement * i);
        }
        return spreadAngles;
    }

    public function getSprayAngles(numAngles:Int, maxSpread:Float) {
        var sprayAngles = new Array<Float>();
        for(i in 0...numAngles) {
            sprayAngles.push(-maxSpread / 2 + Random.random * maxSpread);
        }
        return sprayAngles;
    }

    public function getAngleTowardsPlayer() {
        var player = scene.getInstance("player");
        return (
            Math.atan2(player.centerY - centerY, player.centerX - centerX)
            - Math.PI / 2
        );
    }

    public function getAngleTowardsPlayerForPort(portX:Float, portY:Float) {
        var player = scene.getInstance("player");
        return (
            Math.atan2(player.centerY - portY, player.centerX - portX)
            - Math.PI / 2
        );
    }

    public function isDead() {
        return health < 0;
    }

    public function takeHit() {
        health -= 1;
        flickerTimer.start();
        if(health < 0) {
            die();
        }
    }

    private function die() {
        if(Type.getClass(this) != BossPort && Type.getClass(this) != Boss) {
            sfx['enemydeath${HXP.choose(1, 2, 3)}'].play();
        }
        explode(4);
        scene.remove(this); 
        GameScene.freeEnemyPosition(this);
        for(i in 0...(8 + Random.randInt(5))) {
            scene.add(new Coin(centerX, centerY));
        }
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
}
