package {
	import com.adobe.ane.gameCenter.GameCenterAchievement;
	import com.adobe.ane.gameCenter.GameCenterAchievementEvent;
	import com.adobe.ane.gameCenter.GameCenterAuthenticationEvent;
	import com.adobe.ane.gameCenter.GameCenterController;
	import com.adobe.ane.gameCenter.GameCenterLeaderboardEvent;
	
	/**
	 * ...
	 */
	public class GameCenterManager {
		
		private static var _instance:GameCenterManager;
		private var _controller:GameCenterController;
		
		public function GameCenterManager() {
			if (_instance) {
				return;
			}
		}
		
		public static function get isSupported():Boolean {
			return GameCenterController.isSupported;
		}
		
		public function initialize():void {
			if (GameCenterController.isSupported) {
				trace("gc supported");
				_controller = new GameCenterController();
				
				_controller.addEventListener(GameCenterLeaderboardEvent.SUBMIT_SCORE_SUCCEEDED, onScoreSubmitted);
				_controller.addEventListener(GameCenterLeaderboardEvent.SUBMIT_SCORE_FAILED, onScoreFailed);
				_controller.addEventListener(GameCenterAchievementEvent.SUBMIT_ACHIEVEMENT_SUCCEEDED, onAchievementSubmitted);
				_controller.addEventListener(GameCenterAchievementEvent.SUBMIT_ACHIEVEMENT_FAILED, onAchievementFailed);
				_controller.addEventListener(GameCenterAuthenticationEvent.PLAYER_AUTHENTICATED, onAuthenticated);
				
				_controller.authenticate();
			}
			//if (AirGooglePlayGames.isSupported) {
			//AirGooglePlayGames.getInstance().addEventListener(AirGooglePlayGamesEvent.ON_SIGN_IN_SUCCESS, onGoogleSignInSuccess);
			//AirGooglePlayGames.getInstance().addEventListener(AirGooglePlayGamesEvent.ON_SIGN_IN_FAIL, onGoogleSignInFail);
			//AirGooglePlayGames.getInstance().startAtLaunch();
			//trace("google play supported");
			//}
		}
		
		//private function onGoogleSignInSuccess(e:AirGooglePlayGamesEvent):void {
		//trace("google play authenticated!");
		//}
		//
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
		
		private function onAchievementSubmitted(e:GameCenterAchievementEvent):void {
			trace("Success : " + e.toString());
		}
		
		private function onAchievementFailed(e:GameCenterAchievementEvent):void {
			trace("Fail! : " + e.toString());
		}
		
		public static function get instance():GameCenterManager {
			if (!_instance) {
				_instance = new GameCenterManager();
			}
			return _instance;
		}
		
		public function showLeaderboardView():void {
			if (GameCenterController.isSupported) {
				_controller.showLeaderboardView("highScore");
			}
		}
		
		public function submitScore(score:int):void {
			if (GameCenterController.isSupported) {
				if (!_controller.authenticated) {
					_controller.authenticate();
				}
				trace("submitting gc score");
				_controller.submitScore(score, "highScore");
			}
			//if (AirGooglePlayGames.isSupported) {
				//trace("submitting google play score: " + score);
				//AirGooglePlayGames.getInstance().reportScore("CgkImtX1jeAFEAIQAQ", score);
			//}
		}
		
		public function submitAchievement(score:int):void {
			if (GameCenterController.isSupported) {
				if (!_controller.authenticated) {
					_controller.authenticate();
				}
				trace("submitting gc achievement");
				_controller.submitAchievement("reach" + score, 100);
			}
			//if (AirGooglePlayGames.isSupported) {
			//trace("senging google play score: " + score);
			//AirGooglePlayGames.getInstance().reportScore("CgkImtX1jeAFEAIQAQ", score);
			//}
		}
	
	}

}