package  
{
	/**
	 * ...
	 * @author Chris Cacciatore
	 */
	public class Util 
	{
		public static function degreesToRadians(angle:Number):Number {
			return angle * (Math.PI) / 180;
		}
		
		public static function radiansToDegrees(radians:Number):Number {
			return radians * 180 / Math.PI;
		}
	}

}