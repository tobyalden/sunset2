package scenes;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.graphics.text.*;
import haxepunk.graphics.tile.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import entities.*;

class StartPrompt extends Scene {
    private var title:Image;
    private var selectSound:Sfx;
    private var background:Entity;

    override public function begin() {
        var startText = new Text("PRESS Z TO START");
        startText.smooth = false;
        startText.size = 24;
        startText.font = "font/m5x7.ttf";
        startText.x = HXP.width / 2 - startText.textWidth / 2;
        startText.y = HXP.height / 2 - startText.textHeight / 2;
        addGraphic(startText);
        selectSound = new Sfx("audio/menuselect.wav");
    }

    override public function update() {
        if(Main.inputCheck("shoot")) {
            selectSound.play();
            HXP.scene = new MainMenu();
        }
        super.update();
    }
}

