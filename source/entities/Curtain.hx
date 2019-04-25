package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import scenes.*;

class Curtain extends Entity
{
    public static inline var FADE_SPEED = 0.0019;

    public var isFadingIn(default, null):Bool;
    private var isFadingOut:Bool;
    private var fadeSpeed:Float;

    public function new(x:Float, y:Float) {
        super(x, y);
        graphic = new ColoredRect(HXP.width, HXP.height, 0x000000);
        graphic.alpha = 1;
        layer = -99999;
        isFadingIn = false;
        isFadingOut = false;
        fadeSpeed = FADE_SPEED;
    }

    public function fadeIn(newFadeSpeed:Float = FADE_SPEED) {
        fadeSpeed = newFadeSpeed;
        isFadingIn = true;
        isFadingOut = false;
    }

    public function fadeOut(newFadeSpeed:Float = FADE_SPEED) {
        fadeSpeed = newFadeSpeed;
        isFadingOut = true;
        isFadingIn = false;
    }

    override public function update() {
        x = scene.camera.x;
        y = scene.camera.y;
        if(isFadingIn) {
            graphic.alpha = Math.max(
                0, graphic.alpha - fadeSpeed * Main.getDelta()
            );
            if(graphic.alpha == 0) {
                isFadingIn = false;
            }
        }
        else if(isFadingOut) {
            graphic.alpha = Math.min(
                1, graphic.alpha + fadeSpeed * Main.getDelta()
            );
            if(graphic.alpha == 1) {
                isFadingOut = false;
            }
        }
        super.update();
    }
}
