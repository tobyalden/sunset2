package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;

class Enemy extends Entity {
    public static inline var FLICKER_DURATION = 0.2;
    public static inline var FLICKER_SPEED = 0.05;
    public static inline var MIN_DROP_DISTANCE = 50;
    public static inline var MAX_DROP_DISTANCE = 100;

    private var health:Int;
    private var flickerTimer:Alarm;

    public function new(x:Float, y:Float, health:Int) {
        super(x, y);
        this.health = health;
        type = "enemy";
        flickerTimer = new Alarm(FLICKER_DURATION, TweenType.Persist);
        addTween(flickerTimer);
    }

    override public function update() {
        if(flickerTimer.active) {
            graphic.color = 0xFF0000;
            visible = Math.floor(
                flickerTimer.elapsed / FLICKER_SPEED
            ) % 2 == 0;
        }
        else {
            graphic.color = 0xFFFFFF;
            visible = true;
        }
        if(x < -width || x > HXP.width || y > HXP.height) {
            // Remove offscreen enemies
            scene.remove(this);
        }
        super.update();
    }

    public function takeHit() {
        health -= 1;
        flickerTimer.start();
        if(health < 0) {
            die();
        }
    }

    private function die() {
        explode(4);
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
                centerX, centerY, directions[count]
            );
            explosion.layer = -99;
            scene.add(explosion);
            count++;
        }
    }
}
