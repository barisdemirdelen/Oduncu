package {
	import flash.filesystem.File;
	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.textures.Texture;
	import starling.utils.AssetManager;
	
	/**
	 * ...
	 * @author Barış Demirdelen
	 */
	public class Assets {
		
		public static var assetManager:AssetManager;
		
		private static var _readyFunction:Function;
		
		public static function initialize(callback:Function) : void {
			_readyFunction = callback;
			assetManager = new AssetManager();
			assetManager.enqueue(File.applicationDirectory.resolvePath("images"));
			assetManager.loadQueue(onProgress);
		}
		
		private static function onProgress(ratio:Number):void {
			if (ratio == 1.0) {
				_readyFunction();
			}
		}
		
		public static function getMovieClip(textureName:String):MovieClip {
			var textures:Vector.<Texture> = assetManager.getTextures(textureName);
			var movieClip:MovieClip = new MovieClip(textures, 30);
			
			if (movieClip.numFrames > 1) {
				Starling.juggler.add(movieClip);
				movieClip.play();
			}
			
			return movieClip;
		}
	
	}

}