package {
	import aze.motion.eaze;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.events.TouchEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import sound.SoundManager;
	
	/**
	 * ...
	 * @author Barış Demirdelen
	 */
	public class GameManager extends BurgerManager {
		
		private var _gameScene:MovieClip;
		private var _adam:MovieClip;
		
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
		
		private const _darbeArray:Array = ["normal hit!", "average hit!", "underwhelming hit!", "overwhelming hit!", "incredible hit!", "amazing hit!", "mindblowing hit!", "proper hit!", "adequate hit!", "solid hit!", "very good hit!", "good hit!", "magnificent hit!", "ordinary hit!", "extraordinary hit!", "unbelievable hit!", "insane hit!", "crazy hit!", "weak hit!", "impossible hit!", "critical hit!", "tremendous hit!", "golden hit!", "classy hit!", "sneaky hit!", "deadly hit!", "bruiser hit!"];
		
		public function GameManager(callback:Function) {
			super(callback);
		}
		
		override protected function init():void {
			super.init();
			
			_treeSpeed = 30;
			_score = 0;
			_dead = false;
			_boss = null;
			_bossCreationRatio = 0.05;
			_treeCreationRatio = 0.01;
			_paused = false;
			
			_gameScene = new gameSceneSprite();
			StageHelper.add(_gameScene);
			
			_playButton = _gameScene.getChildByName("playButton") as SimpleButton;
			_pauseButton = _gameScene.getChildByName("pauseButton") as SimpleButton;
			_muteButton = _gameScene.getChildByName("muteButton") as SimpleButton;
			_unmuteButton = _gameScene.getChildByName("unmuteButton") as SimpleButton;
			
			_playButton.addEventListener(MouseEvent.CLICK, onPlayPressed);
			_playButton.addEventListener(TouchEvent.TOUCH_TAP, onPlayPressed);
			
			_pauseButton.addEventListener(MouseEvent.CLICK, onPausePressed);
			_pauseButton.addEventListener(TouchEvent.TOUCH_TAP, onPausePressed);
			
			_muteButton.addEventListener(MouseEvent.CLICK, onMutePressed);
			_muteButton.addEventListener(TouchEvent.TOUCH_TAP, onMutePressed);
			
			_unmuteButton.addEventListener(MouseEvent.CLICK, onUnmutePressed);
			_unmuteButton.addEventListener(TouchEvent.TOUCH_TAP, onUnmutePressed);
			
			_playButton.visible = false;
			_pauseButton.visible = false;
			if (SoundManager.instance.isMuted()) {
				_unmuteButton.visible = true;
				_muteButton.visible = false;
			} else {
				_muteButton.visible = true;
				_unmuteButton.visible = false;
			}
			
			
			_trees = new Array();
			SoundManager.instance.playAgacWalkSound();
			SoundManager.instance.playTestereCleanSound();
			
			_adam = _gameScene.getChildByName("adam") as MovieClip;
			_gameScene.addEventListener(MouseEvent.CLICK, onClick);
			_gameScene.addEventListener(TouchEvent.TOUCH_TAP, onClick);
			
			_gameHeight = _gameScene.height;
			_gameWidth = _gameScene.width;
			
			_textFormat = new TextFormat(new VisitorTT1BRK().fontName, 24, 0xff6600);
			_scoreField = createTextField("Score: " + _score);
			_scoreField.x = 20;
			_scoreField.y = 20;
			_gameScene.addChild(_scoreField);
			_gameScene.getChildByName("deathPopup").visible = false;
			
			_startTime = getTimer()
			
			_gameTimer = new Timer(50);
			_gameTimer.addEventListener(TimerEvent.TIMER, onTick);
			_gameTimer.start();
		}
		
		private function onUnmutePressed(e:Event):void {
			SoundManager.instance.setMuted(false);
			_unmuteButton.visible = false;
			_muteButton.visible = true;
		}
		
		private function onMutePressed(e:Event):void {
			SoundManager.instance.setMuted(true);
			_unmuteButton.visible = true;
			_muteButton.visible = false;
		}
		
		private function onPausePressed(e:Event):void {
			SoundManager.instance.pauseAll();
			_paused = true;
			_playButton.visible = true;
			_pauseButton.visible = false;
		}
		
		private function onPlayPressed(e:Event):void {
			SoundManager.instance.unpauseAll();
			_paused = false;
			_playButton.visible = false;
			_pauseButton.visible = true;
		}
		
		private function onTick(e:TimerEvent):void {
			if (_paused) {
				return;
			}
			
			_score = int(getTimer() - _startTime)
			_scoreField.text = "Score: " + _score;
			_treeSpeed *= 1499 / 1500;
			_treeCreationRatio *= 1500 / 1499;
			
			//trace("tree speed: " + _treeSpeed + " tree creation ratio: " + _treeCreationRatio);
			
			if (_treeCreationRatio >= Math.random()) {
				if (!_boss && _bossCreationRatio >= Math.random()) {
					var newTree:Tree = new Tree(true);
					_boss = newTree;
					_gameScene.gotoAndPlay("boss");
					SoundManager.instance.playBossSound();
				} else {
					newTree = new Tree(false);
				}
				
				var treeLayer:MovieClip = _gameScene.getChildByName("treeLayer") as MovieClip;
				StageHelper.add(newTree.clip, treeLayer);
				
				var bounds:Rectangle = newTree.clip.getBounds(StageHelper.stage);
				
				var left:Boolean = Math.random() < 0.5;
				if (left) {
					newTree.clip.x = _gameWidth + bounds.width + 10;
					
					eaze(newTree.clip).to(_treeSpeed, {x: -bounds.width - 10}).onComplete(onTreeDead, newTree);
					_trees.push(newTree);
				} else {
					newTree.clip.scaleX *= -1;
					newTree.clip.x = -bounds.width - 10;
					
					eaze(newTree.clip).to(20, {x: _gameWidth}).onComplete(onTreeDead, tree);
					_trees.push(newTree);
				}
			}
			
			for each (var tree:Tree in _trees) {
				if (tree.dying) {
					continue;
				}
				if (_adam.getChildByName("hit").hitTestObject(tree.clip.getChildByName("hitboxSprite"))) {
					tree.dying = true;
					var treeBounds:Rectangle = tree.clip.getBounds(StageHelper.stage);
					eaze(tree.clip).to(2, {y: _gameHeight + treeBounds.height}).onComplete(onTreeDead, tree);
					var y:Number = _gameHeight - 100 * Math.random();
					var x:Number = _gameWidth / 2 - Math.random() * 100;
					if (_adam.currentLabel == "right") {
						x = _gameWidth / 2 + Math.random() * 200;
					}
					var hitScoreText:TextField = createTextField(String(Math.floor(Math.random() * 9002)));
					hitScoreText.x = x;
					hitScoreText.y = y;
					_gameScene.addChild(hitScoreText);
					eaze(hitScoreText).to(2, {y: -50}).onComplete(onHitScoreFinished, hitScoreText);
					
					var randomDarbe:String = _darbeArray[Math.floor(Math.random() * _darbeArray.length)];
					var darbeText:TextField = createTextField(randomDarbe);
					y = _gameHeight - 100 * Math.random();
					x = _gameWidth / 2 + Math.random() * 100;
					if (_adam.currentLabel == "right") {
						x = _gameWidth / 2 - Math.random() * 200;
					}
					darbeText.x = x;
					darbeText.y = y;
					_gameScene.addChild(darbeText);
					eaze(darbeText).to(2.5, {y: -50}).onComplete(onHitScoreFinished, darbeText);
					SoundManager.instance.playTestereHitSound();
				}
				if (_adam.getChildByName("hitBack").hitTestObject(tree.clip.getChildByName("hitboxSprite"))) {
					if (_adam.currentLabel == "left") {
						_adam.gotoAndPlay("patlamasol");
					} else {
						_adam.gotoAndPlay("patlamasag");
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
			_gameScene.getChildByName("deathPopup").visible = true;
			((_gameScene.getChildByName("deathPopup") as MovieClip).getChildByName("scoreText") as TextField).text = "Score: " + _score;
			((_gameScene.getChildByName("deathPopup") as MovieClip).getChildByName("menuButton")).addEventListener(MouseEvent.CLICK, onMenuPressed);
			((_gameScene.getChildByName("deathPopup") as MovieClip).getChildByName("menuButton")).addEventListener(TouchEvent.TOUCH_TAP, onMenuPressed);
		}
		
		private function onMenuPressed(e:Event):void {
			destroy();
			new MainMenuManager(Main.onStartGame);
		}
		
		private function onHitScoreFinished(hitScoreText:TextField):void {
			_gameScene.removeChild(hitScoreText);
		}
		
		private function onTreeDead(tree:Tree):void {
			if (tree == _boss) {
				_boss = null;
				_gameScene.gotoAndPlay("normal");
				SoundManager.instance.stopBossSound();
			}
			_trees.splice(_trees.indexOf(tree), 1);
			tree.destroy();
		}
		
		private function onClick(e:Event):void {
			if (_dead) {
				return;
			}
			var stageX:Number;
			if (e is MouseEvent) {
				var mouseEvent:MouseEvent = e as MouseEvent;
				stageX = mouseEvent.stageX;
			}
			if (e is TouchEvent) {
				var touchEvent:TouchEvent = e as TouchEvent;
				stageX = touchEvent.stageX;
			}
			if (stageX <= StageHelper.stage.fullScreenWidth / 2) {
				_adam.gotoAndPlay("left");
			} else {
				_adam.gotoAndPlay("right");
			}
		}
		
		private function createTextField(text:String):TextField {
			var textField:TextField = new TextField();
			textField.defaultTextFormat = _textFormat;
			textField.embedFonts = true;
			textField.text = text;
			textField.width = 300;
			textField.height = 50;
			textField.selectable = false;
			return textField;
		}
		
		override protected function destroy(e:Event = null):void {
			_playButton.removeEventListener(MouseEvent.CLICK, onPlayPressed);
			_playButton.removeEventListener(TouchEvent.TOUCH_TAP, onPlayPressed);
			
			_pauseButton.removeEventListener(MouseEvent.CLICK, onPausePressed);
			_pauseButton.removeEventListener(TouchEvent.TOUCH_TAP, onPausePressed);
			
			_muteButton.removeEventListener(MouseEvent.CLICK, onMutePressed);
			_muteButton.removeEventListener(TouchEvent.TOUCH_TAP, onMutePressed);
			
			_unmuteButton.removeEventListener(MouseEvent.CLICK, onUnmutePressed);
			_unmuteButton.removeEventListener(TouchEvent.TOUCH_TAP, onUnmutePressed);
			
			_gameScene.removeEventListener(MouseEvent.CLICK, onClick);
			_gameScene.removeEventListener(TouchEvent.TOUCH_TAP, onClick);
			
			((_gameScene.getChildByName("deathPopup") as MovieClip).getChildByName("menuButton")).removeEventListener(MouseEvent.CLICK, onMenuPressed);
			((_gameScene.getChildByName("deathPopup") as MovieClip).getChildByName("menuButton")).removeEventListener(TouchEvent.TOUCH_TAP, onMenuPressed);
			
			SoundManager.instance.stopTestereCleanSound();
			for each (var tree:Tree in _trees) {
				tree.destroy();
			}
			
			if (_gameTimer) {
				_gameTimer.removeEventListener(TimerEvent.TIMER, onTick);
				_gameTimer.stop();
				_gameTimer = null;
			}
			
			if (_gameScene) {
				_gameScene.removeEventListener(MouseEvent.CLICK, onClick);
				_gameScene.removeEventListener(TouchEvent.TOUCH_TAP, onClick);
				StageHelper.remove(_gameScene);
				_gameScene = null;
			}
			
			super.destroy(e);
		}
	
	}

}