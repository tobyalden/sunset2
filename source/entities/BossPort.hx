package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.graphics.text.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import scenes.*;

class BossPort extends Enemy {
    public static inline var SIZE = 24;
    public static inline var HEALTH = 50;

    private var sprite:Spritemap;
    private var spriteName:String;
    private var portType:Int;
    private var startX:Int;
    private var startY:Int;
    private var boss:Boss;

    public function new(
        x:Int, y:Int, spriteName:String, portType:Int, boss:Boss,
        difficulty:Float
    ) {
        var health = MathUtil.ilerp(HEALTH, HEALTH * 2, difficulty);
        super(x - 5, y - 5, health, difficulty);
        layer = 2;
        this.startX = x;
        this.startY = y;
        this.spriteName = spriteName;
        this.portType = portType;
        this.boss = boss;
        type = "enemy";
        mask = new Hitbox(24, 24);
        sprite = new Spritemap("graphics/bossparts.png", 24, 24);
        sprite.add("spaceslowbroken", [0]);
        sprite.add("spaceslow", [1]);
        sprite.add("spacebroken", [2]);
        sprite.add("space", [3]);
        sprite.add("forestslowbroken", [4]);
        sprite.add("forestslow", [5]);
        sprite.add("forestbroken", [6]);
        sprite.add("forest", [7]);
        sprite.add("oceanslowbroken", [8]);
        sprite.add("oceanslow", [9]);
        sprite.add("oceanbroken", [10]);
        sprite.add("ocean", [11]);
        sprite.add("cityslowbroken", [12]);
        sprite.add("cityslow", [14]);
        sprite.add("citybroken", [16]);
        sprite.add("city", [18]);
        graphic = sprite;
    }

    override private function die() {
        sfx['enemydeath${HXP.choose(1, 2, 3)}'].play();
        explode(4);
    }

    public function kill() {
        super.die();
    }

    override function update() {
        var speedSuffix = Main.isSlowmo() ? "slow" : "";
        var brokenSuffix = isDead() ? "broken" : "";
        sprite.play(spriteName + speedSuffix + brokenSuffix);
        x = boss.x + startX;
        y = boss.y + startY;
        super.update();
    }
}


