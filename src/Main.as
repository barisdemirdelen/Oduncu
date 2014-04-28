package {
	import flash.desktop.NativeApplication;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.events.TouchEvent;
	import flash.text.TextField;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author Barış Demirdelen
	 */
	public class Main extends Sprite {
		
		public function Main():void {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.DEACTIVATE, deactivate);
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			StageHelper.stage = stage;
			startAnimation();
		}
		
		public static function startAnimation():void {
			new IntroAnimationManager(initMenu);
		}
		
		public static function initMenu():void {
			new MainMenuManager(onStartGame);
		}
		
		public static function onStartGame(e:TimerEvent = null):void {
			new GameManager(initMenu);
		}
		
		private function deactivate(e:Event):void {
			//NativeApplication.nativeApplication.exit();
		}
	
	}

}