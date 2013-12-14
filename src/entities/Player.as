package entities 
{
	import flash.geom.Vector3D;
	import org.axgl.AxPoint;
	import org.axgl.AxSprite;
	import org.axgl.Ax;
	import org.axgl.input.AxKey;
	import org.axgl.AxU;
	import org.axgl.AxVector;
	import org.flashdevelop.utils.FlashConnect;
	
	/**
	 * ...
	 * @author Chris Cacciatore
	 */
	public class Player extends AxSprite 
	{
		private const ROTATION:Number = Math.PI/4;
		
		private var pedal:Number;
		
		public function Player(x:Number, y:Number) 
		{
			super(x, y, GA.BOAT);
			
			pedal = 0.0;
			
			drag = new AxVector(100.0, 100.0, 0.0);
			
			origin = new AxPoint(Tile.WIDTH / 2, Tile.HEIGHT / 2);
			
			maxVelocity.x = 200;
			maxVelocity.y = 200;
		}
		
		override public function update():void {
			super.update();
			if (Ax.keys.down(AxKey.RIGHT) || Ax.keys.down(AxKey.D)) {
				angle += ROTATION;
			}
			else if (Ax.keys.down(AxKey.LEFT) || Ax.keys.down(AxKey.A)) {
				angle -= ROTATION;
			}
			
			if (Ax.keys.down(AxKey.SPACE)) {
				pedal = 50;
			}
			else {
				pedal = 0;
			}
			
			acceleration.x = pedal * Math.cos(Util.degreesToRadians(-angle));
			acceleration.y = pedal * -Math.sin(Util.degreesToRadians(-angle));
			
			FlashConnect.trace(acceleration);
			FlashConnect.trace(angle);
		}
	}

}