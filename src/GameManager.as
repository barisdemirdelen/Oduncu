package {
	import aze.motion.easing.Linear;
	import aze.motion.eaze;
	import flash.display.SimpleButton;
	import flash.events.AccelerometerEvent;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.sensors.Accelerometer;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import sound.SoundManager;
	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.display.Stage;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.utils.HAlign;
	
	/**
	 * ...
	 * @author Barış Demirdelen
	 */
	public class GameManager extends BurgerManager {
		
		private var _gameScene:Sprite;
		private var _adam:MovieClip;
		private var _adamPatlama:MovieClip;
		
		private var _gameTimer:Timer;
		private var _finishTimer:Timer
		private var _trees:Array;
		
		private var _bossCreationRatio:Number;
		private var _treeCreationRatio:Number;
		
		private var _gameHeight:Number;
		private var _gameWidth:Number;
		
		private var _boss:Tree;
		private var _dead:Boolean;
		
		private var _scoreField:TextField;
		private var _score:Number;
		
		private var _textFormat:TextFormat;
		private var _startTime:int;
		
		private var _treeSpeed:Number;
		private var _paused:Boolean;
		
		private var _playButton:SimpleButton;
		private var _pauseButton:SimpleButton;
		private var _muteButton:SimpleButton;
		private var _unmuteButton:SimpleButton;
		
		private var _accelerometer:Accelerometer;
		private var _adamSpeed:Number;
		
		private var _stage:Stage;
		private var _treeLayer:Sprite;
		
		private const _adamOffset:Number = 5;
		
		private const ADAM_PATLAMA:Rectangle = new Rectangle(-319, -30, 551, -148);
		private const ADAM_HITBOX:Rectangle = new Rectangle(28, 10, 29, 87);
		private const SAW_HITBOX:Rectangle = new Rectangle(57, 53, 38, 20);
		private const TREE_HITBOX:Rectangle = new Rectangle(65, 28, 42, 276);
		private const BOSS_HITBOX:Rectangle = new Rectangle(11, 149, 532, 400);
		
		private const _darbeArray:Array = ["normal", "average", "underwhelming", "overwhelming", "incredible", "amazing", "mindblowing", "proper", "adequate", "solid", "veryGood", "good", "magnificent", "ordinary", "extraordinary", "unbelievable", "insane", "crazy", "weak", "impossible", "critical", "tremendous", "golden", "classy", "sneaky", "deadly", "bruiser"];
		
		public function GameManager(callback:Function) {
			super(callback);
		}
		
		override protected function init():void {
			super.init();
			
			FlashStageHelper.stage.frameRate = 60;
			_stage = Starling.current.stage;
			_treeSpeed = 30;
			_score = 0;
			_dead = false;
			_boss = null;
			_bossCreationRatio = 0.05;
			_treeCreationRatio = 0.025;
			_adamSpeed = 0;
			_paused = false;
			
			//_gameScene = new gameSceneSprite();
			//StageHelper.add(_gameScene);
			
			_gameScene = new Sprite();
			_stage.addChild(_gameScene);
			
			_gameScene.addChild(Assets.getMovieClip("arkaplan"));
			_gameScene.addChild(Assets.getMovieClip("kesilmisodunlar"));
			
			_treeLayer = new Sprite();
			_gameScene.addChild(_treeLayer);
			
			_adam = Assets.getMovieClip("sagadogru");
			_adamPatlama = Assets.getMovieClip("adamSprite");
			_adamPatlama.loop = false;
			_adamPatlama.stop();
		
			
			//_adam.y = 80;
			//_adam.pivotX = _adamOffset;
			_adam.y = _stage.stageHeight - _adam.height + 5;
			_adam.x = _stage.stageWidth / 2 - _adam.width / 2;
			_gameScene.addChild(_adam);
			_gameScene.addChild(Assets.getMovieClip("cimenler"));
			
			//_playButton = _gameScene.getChildByName("playButton") as SimpleButton;
			//_pauseButton = _gameScene.getChildByName("pauseButton") as SimpleButton;
			//_muteButton = _gameScene.getChildByName("muteButton") as SimpleButton;
			//_unmuteButton = _gameScene.getChildByName("unmuteButton") as SimpleButton;
			
			//_playButton.addEventListener(MouseEvent.CLICK, onPlayPressed);
			//_playButton.addEventListener(TouchEvent.TOUCH_TAP, onPlayPressed);
			//
			//_pauseButton.addEventListener(MouseEvent.CLICK, onPausePressed);
			//_pauseButton.addEventListener(TouchEvent.TOUCH_TAP, onPausePressed);
			//
			//_muteButton.addEventListener(MouseEvent.CLICK, onMutePressed);
			//_muteButton.addEventListener(TouchEvent.TOUCH_TAP, onMutePressed);
			//
			//_unmuteButton.addEventListener(MouseEvent.CLICK, onUnmutePressed);
			//_unmuteButton.addEventListener(TouchEvent.TOUCH_TAP, onUnmutePressed);
			
			//_playButton.visible = false;
			//_pauseButton.visible = false;
			//if (SoundManager.instance.isMuted()) {
			//_unmuteButton.visible = true;
			//_muteButton.visible = false;
			//} else {
			//_muteButton.visible = true;
			//_unmuteButton.visible = false;
			//}
			
			_trees = new Array();
			SoundManager.instance.playTestereCleanSound();
			//
			//_adam = _gameScene.getChildByName("adam") as MovieClip;
			_gameScene.addEventListener(TouchEvent.TOUCH, onClick);
			//_gameScene.addEventListener(TouchEvent.TOUCH_TAP, onClick);
			//
			//var _gameBounds:Rectangle = _gameScene.getChildByName("maskSprite").getBounds(StageHelper.stage);
			//_gameHeight = _gameBounds.height
			//_gameWidth = _gameBounds.width
			//
			_scoreField = createTextField(LocaleUtil.localize("score") + ": " + _score);
			_scoreField.x = 150;
			_scoreField.y = 5;
			_scoreField.hAlign = HAlign.LEFT;
			_gameScene.addChild(_scoreField);
			//_gameScene.getChildByName("deathPopup").visible = false;
			//
			_startTime = getTimer();
			//
			//_accelerometer = new Accelerometer();
			//if (Accelerometer.isSupported) {
			////_accelerometer.addEventListener(AccelerometerEvent.UPDATE, onAccelerometerUpdate);
			//}
			//
			_gameTimer = new Timer(50);
			_gameTimer.addEventListener(TimerEvent.TIMER, onTick);
			_gameTimer.start();
		}
		
		private function onAccelerometerUpdate(e:AccelerometerEvent):void {
			trace(e.accelerationX);
			_adamSpeed -= e.accelerationX;
		}
		
		private function onTick(e:TimerEvent):void {
			if (_paused) {
				return;
			}
			
			if (_trees.length == 0) {
				SoundManager.instance.stopAgacWalkSound();
			}
			//
			//
			//_adam.x += _adamSpeed;
			//
			_score = int(getTimer() - _startTime)
			_scoreField.text = LocaleUtil.localize("score") + ": " + _score;
			_treeSpeed *= 1499 / 1500;
			_treeCreationRatio *= 1500 / 1499;
			//
			if (_treeCreationRatio >= Math.random()) {
				//if (!_boss && _bossCreationRatio >= Math.random()) {
				//var newTree:Tree = new Tree(true);
				//_boss = newTree;
				//_gameScene.gotoAndPlay("boss");
				//SoundManager.instance.playBossSound();
				//} else {
				var newTree:Tree = new Tree(false);
				//}
				//
				if (!SoundManager.instance.isAgacPlaying()) {
					SoundManager.instance.playAgacWalkSound();
				}
				//
				//var treeLayer:MovieClip = _gameScene.getChildByName("treeLayer") as MovieClip;
				//FlashStageHelper.add(newTree.clip, treeLayer);
				_treeLayer.addChild(newTree.clip);
				//
				//var bounds:Rectangle = newTree.clip.getBounds(FlashStageHelper.stage);
				//
				newTree.clip.y = _stage.stageHeight - newTree.clip.height
				var left:Boolean = Math.random() < 0.5;
				if (left) {
					newTree.facingRight = false;
					newTree.clip.x = _stage.stageWidth;
					//
					eaze(newTree.clip).easing(Linear.easeNone).to(_treeSpeed, {x: -newTree.clip.width}).onComplete(onTreeDead, newTree);
					_trees.push(newTree);
				} else {
					newTree.facingRight = true;
					GraphicsUtil.reverseHorizontal(newTree.clip);
					newTree.clip.x -= newTree.clip.width;
					
					eaze(newTree.clip).easing(Linear.easeNone).to(_treeSpeed, {x: _stage.stageWidth}).onComplete(onTreeDead, newTree);
					_trees.push(newTree);
				}
			}
			//
			
			var adamBounds:Rectangle = _adam.getBounds(_gameScene);
			var adamHitBounds:Rectangle = ADAM_HITBOX.clone();
			var sawHitBounds:Rectangle = SAW_HITBOX.clone();
			if (_adam.scaleX < 0) {
				adamHitBounds.offset(ADAM_HITBOX.x, 0);
				sawHitBounds.offset(-SAW_HITBOX.x, 0);
			}
			adamHitBounds.offset(adamBounds.x, adamBounds.y);
			sawHitBounds.offset(adamBounds.x, adamBounds.y);
			
			for each (var tree:Tree in _trees) {
				if (tree.dying) {
					continue;
				}
				
				var treeBounds:Rectangle = tree.clip.getBounds(_gameScene);
				var treeHitBounds:Rectangle = TREE_HITBOX.clone();
				if (tree.clip.scaleX < 0) {
					treeHitBounds.offset(TREE_HITBOX.width - TREE_HITBOX.x, 0);
				}
				treeHitBounds.offset(treeBounds.x, treeBounds.y);
				
				if (sawHitBounds.intersects(treeHitBounds)) {
					tree.dying = true;
					//var treeBounds:Rectangle = tree.clip.getBounds(FlashStageHelper.stage);
					//if (tree.isBoss) {
					//eaze(tree.clip).to(4, {y: _gameHeight + treeBounds.top}).onComplete(onTreeDead, tree);
					//} else {
					if (tree.facingRight) {
						eaze(tree.clip).to(2.5, {y: _stage.stageHeight + tree.clip.height, x: tree.clip.x - tree.clip.height, rotation: -Math.PI / 2}).onComplete(onTreeDead, tree);
					} else {
						eaze(tree.clip).to(2.5, {y: _stage.stageHeight + tree.clip.height, x: tree.clip.x + tree.clip.height, rotation: Math.PI / 2}).onComplete(onTreeDead, tree);
					}
					//}
					var y:Number = _stage.stageHeight - 20 * Math.random();
					var x:Number = _stage.stageWidth / 2 - Math.random() * 50;
					if (_adam.scaleX > 0) {
						x = _stage.stageWidth / 2 + Math.random() * 100;
					}
					var hitScoreText:TextField = createTextField(String(Math.floor(Math.random() * 9002)));
					hitScoreText.x = x;
					hitScoreText.y = y;
					_gameScene.addChild(hitScoreText);
					eaze(hitScoreText).to(2, {y: hitScoreText.width}).onComplete(onHitScoreFinished, hitScoreText);
					
					var randomDarbe:String = _darbeArray[Math.floor(Math.random() * _darbeArray.length)];
					var localizedDarbe:String = LocaleUtil.localize(randomDarbe) + " " + LocaleUtil.localize("blow") + "!";
					var darbeText:TextField = createTextField(localizedDarbe);
					y = _stage.stageHeight - 20 * Math.random();
					x = _stage.stageWidth / 2 + Math.random() * 50;
					if (_adam.scaleX > 0) {
						x = _stage.stageWidth / 2 - Math.random() * 0100;
					}
					darbeText.x = x;
					darbeText.y = y;
					_gameScene.addChild(darbeText);
					eaze(darbeText).to(2.5, {y: darbeText.width}).onComplete(onHitScoreFinished, darbeText);
					SoundManager.instance.playTestereHitSound();
				}
				
				if (adamHitBounds.intersects(treeHitBounds)) {
					//if (_adam.currentLabel == "left") {
					//_adam.gotoAndPlay("patlamasol");
					//} else {
					//_adam.gotoAndPlay("patlamasag");
					//}
					_gameScene.removeChild(_adam);
					_gameScene.addChild(_adamPatlama);
					//_adamPatlama.x = ADAM_PATLAMA.x;
					//_adamPatlama.y = ADAM_PATLAMA.y;
					//_adamPatlama.x += _stage.stageWidth / 2 - _adam.width / 2;
					_adamPatlama.y = 80;
					_adamPatlama.play();
					
					if (_adam.scaleX < 0) {
						GraphicsUtil.reverseHorizontal(_adamPatlama);
					}
					
					_dead = true;
					SoundManager.instance.stopAgacWalkSound();
					SoundManager.instance.stopBossSound();
					_gameTimer.removeEventListener(TimerEvent.TIMER, onTick);
					_gameTimer.stop();
					_gameTimer = null;
					_finishTimer = new Timer(3000, 1);
					_finishTimer.addEventListener(TimerEvent.TIMER, onFinished);
					_finishTimer.start();
					break;
				}
			}
			if (_dead) {
				for each (tree in _trees) {
					eaze(tree.clip).killTweens();
				}
				return;
			}
		}
		
		private function onFinished(e:Event):void {
			//var deathPopup:MovieClip = _gameScene.getChildByName("deathPopup") as MovieClip;
			//deathPopup.visible = true;
			//(deathPopup.getChildByName("deathText") as TextField).text = LocaleUtil.localize("deathText");
			//(deathPopup.getChildByName("scoreText") as TextField).text = LocaleUtil.localize("score") + ": " + _score;
			//(deathPopup.getChildByName("menuButton")).addEventListener(MouseEvent.CLICK, onMenuPressed);
			//(deathPopup.getChildByName("menuButton")).addEventListener(TouchEvent.TOUCH_TAP, onMenuPressed);
		}
		
		//private function onMenuPressed(e:Event):void {
		//destroy();
		//new MainMenuManager(Main.onStartGame);
		//}
		//
		private function onHitScoreFinished(hitScoreText:TextField):void {
			_gameScene.removeChild(hitScoreText);
		}
		
		//
		private function onTreeDead(tree:Tree):void {
			if (tree == _boss) {
				_boss = null;
				//_gameScene.gotoAndPlay("normal");
				SoundManager.instance.stopBossSound();
			}
			_trees.splice(_trees.indexOf(tree), 1);
			tree.destroy();
		}
		
		//
		private function onClick(e:TouchEvent):void {
			if (_dead) {
				return;
			}
			
			var touch:Touch = e.getTouch(_gameScene, TouchPhase.BEGAN);
			
			if (!touch) {
				return;
			}
			if (touch.globalX >= _stage.stageWidth / 2) {
				if (_adam.scaleX < 0) {
					GraphicsUtil.reverseHorizontal(_adam);
				}
			} else {
				if (_adam.scaleX > 0) {
					GraphicsUtil.reverseHorizontal(_adam);
				}
			}
		}
		
		//
		private function createTextField(text:String):TextField {
			var textField:TextField = new TextField(300, 50, text, "Visitor TT1 BRK", 24, 0xff6600);
			return textField;
		}
		
		//
		//private function onUnmutePressed(e:Event):void {
		//SoundManager.instance.setMuted(false);
		//_unmuteButton.visible = false;
		//_muteButton.visible = true;
		//}
		//
		//private function onMutePressed(e:Event):void {
		//SoundManager.instance.setMuted(true);
		//_unmuteButton.visible = true;
		//_muteButton.visible = false;
		//}
		//
		//private function onPausePressed(e:Event):void {
		//SoundManager.instance.pauseAll();
		//_paused = true;
		//_playButton.visible = true;
		//_pauseButton.visible = false;
		//}
		//
		//private function onPlayPressed(e:Event):void {
		//SoundManager.instance.unpauseAll();
		//_paused = false;
		//_playButton.visible = false;
		//_pauseButton.visible = true;
		//}
		
		override protected function destroy(e:Event = null):void {
			//_playButton.removeEventListener(MouseEvent.CLICK, onPlayPressed);
			//_playButton.removeEventListener(TouchEvent.TOUCH_TAP, onPlayPressed);
			//
			//_pauseButton.removeEventListener(MouseEvent.CLICK, onPausePressed);
			//_pauseButton.removeEventListener(TouchEvent.TOUCH_TAP, onPausePressed);
			//
			//_muteButton.removeEventListener(MouseEvent.CLICK, onMutePressed);
			//_muteButton.removeEventListener(TouchEvent.TOUCH_TAP, onMutePressed);
			//
			//_unmuteButton.removeEventListener(MouseEvent.CLICK, onUnmutePressed);
			//_unmuteButton.removeEventListener(TouchEvent.TOUCH_TAP, onUnmutePressed);
			//
			//_gameScene.removeEventListener(MouseEvent.CLICK, onClick);
			//_gameScene.removeEventListener(TouchEvent.TOUCH_TAP, onClick);
			//
			//((_gameScene.getChildByName("deathPopup") as MovieClip).getChildByName("menuButton")).removeEventListener(MouseEvent.CLICK, onMenuPressed);
			//((_gameScene.getChildByName("deathPopup") as MovieClip).getChildByName("menuButton")).removeEventListener(TouchEvent.TOUCH_TAP, onMenuPressed);
			//
			//SoundManager.instance.stopTestereCleanSound();
			//for each (var tree:Tree in _trees) {
			//tree.destroy();
			//}
			//
			//if (_gameTimer) {
			//_gameTimer.removeEventListener(TimerEvent.TIMER, onTick);
			//_gameTimer.stop();
			//_gameTimer = null;
			//}
			//
			//if (_gameScene) {
			//_gameScene.removeEventListener(MouseEvent.CLICK, onClick);
			//_gameScene.removeEventListener(TouchEvent.TOUCH_TAP, onClick);
			//FlashStageHelper.remove(_gameScene);
			//_gameScene = null;
			//}
			
			super.destroy(e);
		}
	
	}

}