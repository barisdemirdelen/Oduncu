package {
	import com.adobe.ane.gameCenter.GameCenterAchievement;
	import com.adobe.ane.gameCenter.GameCenterAchievementEvent;
	import com.adobe.ane.gameCenter.GameCenterAuthenticationEvent;
	import com.adobe.ane.gameCenter.GameCenterController;
	import com.adobe.ane.gameCenter.GameCenterLeaderboardEvent;
	//import com.freshplanet.ane.AirGooglePlayGames.AirGooglePlayGames;
	//import com.freshplanet.ane.AirGooglePlayGames.AirGooglePlayGamesEvent;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Barış Demirdelen
	 */
	public class GameCenterManager {
		
		private static var _instance:GameCenterManager;
		private var _controller:GameCenterController;
		
		public function GameCenterManager() {
			if (_instance) {
				return;
			}
		}
		
		public function initialize():void {
			if (GameCenterController.isSupported) {
				trace("gc supported");
				_controller = new GameCenterController();
				
				_controller.addEventListener(GameCenterLeaderboardEvent.SUBMIT_SCORE_SUCCEEDED, onScoreSubmitted);
				_controller.addEventListener(GameCenterLeaderboardEvent.SUBMIT_SCORE_FAILED, onScoreFailed);
				_controller.addEventListener(GameCenterAuthenticationEvent.PLAYER_AUTHENTICATED, onAuthenticated);
				
				_controller.authenticate();
			}
			//if (AirGooglePlayGames.isSupported) {
				//trace("google play supported");
				//AirGooglePlayGames.getInstance().addEventListener(AirGooglePlayGamesEvent.ON_SIGN_IN_SUCCESS, onGoogleSignInSuccess);
				//AirGooglePlayGames.getInstance().addEventListener(AirGooglePlayGamesEvent.ON_SIGN_IN_FAIL, onGoogleSignInFail);
				//AirGooglePlayGames.getInstance().startAtLaunch();
			//}
		}
		
		//private function onGoogleSignInSuccess(e:AirGooglePlayGamesEvent):void {
			//trace("google play authenticated!");
		//}
		
		//private function onGoogleSignInFail(e:AirGooglePlayGamesEvent):void {
			//trace("google play failed authenticating!");
		//}
		//
		private function onAuthenticated(e:GameCenterAuthenticationEvent):void {
			trace("gc authenticated!");
		}
		
		private function onScoreSubmitted(e:GameCenterLeaderboardEvent):void {
			trace("Success : " + e.toString());
		}
		
		private function onScoreFailed(e:GameCenterLeaderboardEvent):void {
			trace("Fail! : " + e.toString());
		}
		
		public static function get instance():GameCenterManager {
			if (!_instance) {
				_instance = new GameCenterManager();
			}
			return _instance;
		}
		
		public function submitScore(score:int):void {
			if (GameCenterController.isSupported) {
				if (!_controller.authenticated) {
					_controller.authenticate();
				}
				_controller.submitScore(score, "highScore");
			}
			//if (AirGooglePlayGames.isSupported) {
				//trace("senging google play score: " + score);
				//AirGooglePlayGames.getInstance().reportScore("CgkImtX1jeAFEAIQAQ", score);
			//}
		}
		
		public function get controller():GameCenterController {
			return _controller;
		}
	
	}

}