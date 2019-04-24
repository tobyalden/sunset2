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
    private var lifeText:Text;
    private var lifeIcon:Image;
    private var coinText:Text;
    private var coinIcon:Image;

    public function new() {
        super(0, 0);

        lifeText = new Text("?");
        lifeText.smooth = false;
        lifeText.size = 24;
        lifeText.font = "font/m5x7.ttf";
        lifeText.x = 5;
        lifeIcon = new Image("graphics/lifeicon.png");
        lifeIcon.x = lifeText.x + lifeText.width;
        lifeIcon.y = 8;

        coinText = new Text("?");
        coinText.smooth = false;
        coinText.size = 24;
        coinText.font = "font/m5x7.ttf";
        coinText.x = lifeIcon.x + 25;
        coinIcon = new Image("graphics/coinicon.png");
        coinIcon.x = coinText.x + coinText.width;
        coinIcon.y = 8;

        addGraphic(lifeText);
        addGraphic(lifeIcon);
        addGraphic(coinText);
        addGraphic(coinIcon);
    }

    override function update() {
        var player = scene.getInstance("player");
        lifeText.text = '${cast(player, Player).lives}';
        lifeIcon.x = lifeText.x + lifeText.width;

        coinText.text = '${cast(player, Player).coins}';
        coinText.x = lifeIcon.x + 25;
        coinIcon.x = coinText.x + coinText.width;
    }
}
