package {
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.events.TouchEvent;
	import flash.utils.Timer;
	import sound.SoundManager;
	
	/**
	 * ...
	 * @author Barış Demirdelen
	 */
	public class MainMenuManager extends BurgerManager {
		
		private var _mainMenu:MovieClip;
		private var _startButton:SimpleButton
		private var _oynakTimer:Timer;
		
		public function MainMenuManager(callBack:Function) {
			super(callBack);
		}
		
		override protected function init():void {
			super.init();
			_mainMenu = new mainMenuSprite();
			StageHelper.add(_mainMenu);
			
			_startButton = _mainMenu.getChildByName("startButton") as SimpleButton;
			_startButton.addEventListener(TouchEvent.TOUCH_TAP, onStartClick);
			_startButton.addEventListener(MouseEvent.CLICK, onStartClick);
		}
		
		private function onStartClick(e:Event):void {
			_startButton.removeEventListener(TouchEvent.TOUCH_TAP, onStartClick);
			_startButton.removeEventListener(MouseEvent.CLICK, onStartClick);
			
			SoundManager.instance.playTestereTurnOnSound();
			
			var header:MovieClip = _mainMenu.getChildByName("txtHeader") as MovieClip;
			header.gotoAndPlay("oynak");
			_oynakTimer = new Timer(1000, 1);
			_oynakTimer.addEventListener(TimerEvent.TIMER_COMPLETE, destroy);
			_oynakTimer.start();
		}
		
		override protected function destroy(e:Event = null):void {
			if (_oynakTimer) {
				_oynakTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, destroy);
				_oynakTimer.stop();
				_oynakTimer = null;
			}
			
			if (_mainMenu) {
				StageHelper.stage.removeChild(_mainMenu);
				_mainMenu = null;
			}
			
			super.destroy(e);
		}
	
	}

}