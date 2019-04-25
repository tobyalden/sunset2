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
    private var levelText:Text;
    private var gameOver:Text;
    private var levelSubtitle:Text;
    private var fadeTimer:Alarm;

    private var levelSubtitles:Map<Int, String> = [
        1 => 'above the city \n a bird soars without a sound \n our tale begins here',
        2 => 'the waves sound below \n wings grow damp with sea and salt \n we have far to go',
        3 => 'the forest is old \n roots hold firm to warm soil \n and the air is clear',
        4 => 'the city returns \n the sounds of conversation \n blend to a dull hum',
        5 => 'the smell of ocean \n seaweed, driftwood, and tide pools \n we return once more',
        6 => 'the forest, again \n leaves turn sun to pools of light \n our last time on earth',
        7 => 'among the stars, now \n outside of time and meaning \n find love in this void!',
    ];

    public function new(level:Int) {
        super(0, 0);
        layer = -10;

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

        levelText = new Text('LEVEL ${level}');
        levelText.smooth = false;
        levelText.size = 48;
        levelText.smooth = false;
        levelText.x = HXP.width / 2 - levelText.textWidth / 2;
        levelText.y = HXP.height / 2 - levelText.textHeight / 2;

        levelSubtitle = new Text(levelSubtitles[level]);
        levelSubtitle.smooth = false;
        levelSubtitle.size = 12;
        levelSubtitle.smooth = false;
        levelSubtitle.x = HXP.width / 2 - levelSubtitle.textWidth / 2;
        levelSubtitle.y = levelText.y + levelText.textHeight - 15;

        gameOver = new Text('GAME OVER');
        gameOver.smooth = false;
        gameOver.size = 48;
        gameOver.smooth = false;
        gameOver.x = HXP.width / 2 - gameOver.textWidth / 2;
        gameOver.y = HXP.height / 2 - gameOver.textHeight / 2;
        gameOver.visible = false;

        addGraphic(lifeText);
        addGraphic(lifeIcon);
        addGraphic(coinText);
        addGraphic(coinIcon);
        addGraphic(levelText);
        addGraphic(levelSubtitle);
        addGraphic(gameOver);
        fadeTimer = new Alarm(3);
        addTween(fadeTimer, true);
    }

    public function displayGameOver() {
        gameOver.visible = true;
    }

    override function update() {
        var player = scene.getInstance("player");
        lifeText.text = '${cast(player, Player).lives}';
        lifeIcon.x = lifeText.x + lifeText.width;

        coinText.text = '${cast(player, Player).coins}';
        coinText.x = lifeIcon.x + 25;
        coinIcon.x = coinText.x + coinText.width;
        levelText.alpha = 1 - fadeTimer.percent;
        levelSubtitle.alpha = 1 - fadeTimer.percent;
    }
}
