package entities 
{
	import org.axgl.AxSprite;
	
	/**
	 * ...
	 * @author Chris Cacciatore
	 */
	public class Wake extends AxSprite 
	{
		
		public function Wake(x:Number, y:Number) 
		{
			super(x, y);
			
			load(GA.WAKE, 64, 64);
			addAnimation("idle", [0]);
			
			animate("idle");
		}
		
	}

}