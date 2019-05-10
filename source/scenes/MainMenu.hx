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

class MainMenu extends Scene {
    public static inline var CURSOR_PAUSE_TIME = 0.5;
    public static inline var BOB_AMOUNT = 0.25;
    public static inline var BOB_SPEED = 0.23;

    public static var continueFrom:Int = 1;

    private var title:Image;

    private var startText:Text;
    private var continueText:Text;

    private var cursor:Entity;
    private var cursorPosition:Int;
    private var canControl:Bool;
    private var bob:NumTween;
    private var cursorPause:Alarm;

    private var curtain:Curtain;

    private var selectSound:Sfx;
    private var startSound:Sfx;

    private var background:Entity;
    private var music:Sfx;
    private var fromPrompt:Bool;

    public function new(fromPrompt:Bool = false) {
        super();
        this.fromPrompt = fromPrompt;
    }

    override public function begin() {
        music = new Sfx("audio/mainmenu.wav");
        music.loop();
        title = new Image("graphics/titlescreen.png");
        background = new Entity(
            0, 0, new Backdrop('graphics/titlebackground.png')
        );
        background.layer = 10;
        add(background);

        addGraphic(title);
        startText = new Text("START");
        startText.smooth = false;
        startText.size = 24;
        startText.font = "font/m5x7.ttf";
        startText.x = HXP.width / 2 - startText.textWidth / 2;
        startText.y = HXP.height - 100 - startText.textHeight / 2;
        addGraphic(startText);

        continueText = new Text("CONTINUE");
        continueText.smooth = false;
        continueText.size = 24;
        continueText.font = "font/m5x7.ttf";
        continueText.x = startText.x;
        continueText.y = startText.y + 20;
        addGraphic(continueText);

        cursor = new Entity(
            startText.x - 17, startText.y + 6,
            new Image("graphics/cursor.png")
        );
        cursor.graphic.pixelSnapping = true;
        cursor.graphic.smooth = false;
        add(cursor);
        cursorPosition = 0;

        canControl = true;

        bob = new NumTween(TweenType.PingPong);
        bob.tween(-BOB_AMOUNT, BOB_AMOUNT, BOB_SPEED, Ease.sineInOut);
        addTween(bob, true);

        cursorPause = new Alarm(CURSOR_PAUSE_TIME, TweenType.Persist);
        addTween(cursorPause);

        curtain = new Curtain(0, 0);
        add(curtain);
        curtain.fadeIn();

        selectSound = new Sfx("audio/menuselect.wav");
        startSound = new Sfx("audio/menustart.wav");
    }

    override public function update() {
        background.y += GameScene.SCROLL_SPEED * Main.getDelta();
        if(canControl && Main.inputCheck("up")) {
            if(!cursorPause.active) {
                if(cursorPosition > 0) {
                    cursorPosition--;
                    cursorPause.start();
                    selectSound.play();
                }
            }
        }
        else if(canControl && Main.inputCheck("down")) {
            if(!cursorPause.active) {
                if(cursorPosition < 1) {
                    cursorPosition++;
                    cursorPause.start();
                    selectSound.play();
                }
            }
        }
        else {
            cursorPause.cancel();
        }
        if(cursorPosition == 0) {
            cursor.x = startText.x - 17;
            cursor.y = startText.y + 6;
        }
        else if(cursorPosition == 1) {
            cursor.x = continueText.x - 17;
            cursor.y = continueText.y + 6;
        }
        cursor.x += bob.value;

        if(canControl && Main.inputPressed("shoot")) {
            var flasher = new Alarm(0.1, TweenType.Looping);
            flasher.onComplete.bind(function() {
                if(cursorPosition == 0) {
                    startText.visible = !startText.visible;
                }
                else if(cursorPosition == 1) {
                    continueText.visible = !continueText.visible;
                }
            });
            addTween(flasher, true);
            var levelToStartFrom = cursorPosition == 0 ? 1 : continueFrom;
            var resetTimer = new Alarm(2, TweenType.OneShot);
                resetTimer.onComplete.bind(function() {
                    clearTweens();
                    HXP.scene = new GameScene(continueFrom);
                });
            addTween(resetTimer, true);
            canControl = false;
            curtain.fadeOut();
            music.stop();
            startSound.play();
        }
        super.update();
    }
}
