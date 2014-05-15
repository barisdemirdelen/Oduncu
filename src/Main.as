package {
	import flash.desktop.NativeApplication;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import starling.core.Starling;
	import starling.utils.RectangleUtil;
	import starling.utils.ScaleMode;
	
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
			FlashStageHelper.stage = stage;
			LocaleUtil.initialize();
			
			Starling.handleLostContext = true;
			var viewPort:Rectangle = RectangleUtil.fit(new Rectangle(0, 0, 800, 400), new Rectangle(0, 0, stage.fullScreenWidth, stage.fullScreenHeight), ScaleMode.NO_BORDER);
			var starling:Starling = new Starling(StarlingMain, stage, viewPort);
			starling.stage.stageWidth = 800;
			starling.stage.stageHeight = 400;
			starling.antiAliasing = 1;
			starling.start();
		}
		
		public static function onStarlingReady():void {
			Assets.initialize(onAssetsReady);
		}
		
		private static function onAssetsReady():void {
			startAnimation();
			//new GameManager(initMenu);
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
			NativeApplication.nativeApplication.exit();
		}
	
	}

}