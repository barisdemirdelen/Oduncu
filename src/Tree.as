package {
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author Barış Demirdelen
	 */
	public class Tree {
		
		private var _clip:MovieClip;
		private var _isBoss:Boolean = false;
		private var _dying:Boolean = false;
		
		public function Tree(boss:Boolean = false) {
			if (boss) {
				_clip = new bossSprite();
				_isBoss = true;
			} else {
				_clip = new treeSprite();
				
				var randomAnimationId:int = Math.floor(Math.random() * 8 + 1);
				_clip.gotoAndPlay("anim" + randomAnimationId);
			}
			_clip.tree = this;
		}
		
		public function destroy():void {
			if (_clip) {
				_clip.parent.removeChild(_clip);
				_clip = null;
			}
		}
		
		public function get clip():MovieClip {
			return _clip;
		}
		
		public function set clip(value:MovieClip):void {
			_clip = value;
		}
		
		public function get isBoss():Boolean {
			return _isBoss;
		}
		
		public function get dying():Boolean {
			return _dying;
		}
		
		public function set dying(value:Boolean):void {
			_dying = value;
		}
	
	}

}