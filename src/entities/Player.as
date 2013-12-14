package entities 
{
	import flash.geom.Vector3D;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.shape.Circle;
	import nape.space.Space;
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
		private var body:Body;
		
		public function Player(x:Number, y:Number, space:Space) 
		{
			super(x, y, GA.BOAT);
			
			pedal = 0.0;
			
			origin = new AxPoint(Tile.WIDTH / 2, Tile.HEIGHT / 2);
			
			body = new Body(BodyType.DYNAMIC);
			body.shapes.add(new Circle(Tile.WIDTH / 2));
			body.position = new Vec2(x, y);
			body.space = space;
		}
		
		override public function update():void {
			super.update();
			
			x = body.position.x;
			y = body.position.y;
			
			if (Ax.keys.down(AxKey.RIGHT) || Ax.keys.down(AxKey.D)) {
				angle += ROTATION;
			}
			else if (Ax.keys.down(AxKey.LEFT) || Ax.keys.down(AxKey.A)) {
				angle -= ROTATION;
			}
			
			if (Ax.keys.down(AxKey.SPACE)) {
				pedal = 150;
			}
			else {
				pedal = 0;
			}

			body.velocity.x = pedal * Math.cos(Util.degreesToRadians(-angle));
			body.velocity.y = pedal * -Math.sin(Util.degreesToRadians( -angle));
		}
	}

}