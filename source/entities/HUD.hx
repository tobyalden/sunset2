package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.graphics.text.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import scenes.*;

class HUD extends Entity {
    private var text:Text;
    private var lifeIcon:Image;

    public function new() {
        super(0, 0);
        text = new Text("?");
        text.smooth = false;
        text.size = 24;
        text.font = "font/m5x7.ttf";
        text.x = 5;
        lifeIcon = new Image("graphics/lifeicon.png");
        lifeIcon.x = text.x + text.width;
        lifeIcon.y = 8;
        addGraphic(text);
        addGraphic(lifeIcon);
    }

    override function update() {
        var player = scene.getInstance("player");
        text.text = '${cast(player, Player).lives}';
        lifeIcon.x = text.x + text.width;
    }
}
