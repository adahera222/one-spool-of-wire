package entities 
{
	import flash.geom.Vector3D;
	import flash.profiler.Telemetry;
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
	import nape.phys.Material;
	import com.greensock.TweenMax;
	
	/**
	 * ...
	 * @author Chris Cacciatore
	 */
	public class Player extends AxSprite 
	{
		private const ROTATION:Number = 2;
		private const MASS:Number = 10;
		
		private var pedal:Number;
		
		public var body:Body;
		
		private var wake:Wake;
		
		public function Player(x:Number, y:Number, space:Space) 
		{
			super(x, y);
			
			load(GA.BOAT, Tile.WIDTH*2, Tile.HEIGHT*2);
            addAnimation("idle", [0], 1, false);
			
			animate("idle");
			
			pedal = 0.0;
			
			body = new Body(BodyType.DYNAMIC);
			body.shapes.add(new Circle(Tile.WIDTH));
			body.position = new Vec2(x, y);
			body.mass = MASS;
			body.setShapeMaterials(Material.wood());
			body.space = space;
			
			//wake = new Wake(x - 64, y);
			//GV.game.add(wake);
		}
		
		override public function update():void {
			super.update();
			
			x = body.position.x;
			y = body.position.y;
			
			if (Ax.keys.down(AxKey.SPACE)) {
				pedal += 5;
			}
			else {
				pedal -= 2;
			}
			
			pedal = AxU.clamp(pedal, 0, 300);
			
			body.velocity.x = pedal * Math.cos(Util.degreesToRadians(-angle));
			body.velocity.y = pedal * -Math.sin(Util.degreesToRadians( -angle));
			
			if (Ax.keys.down(AxKey.RIGHT) || Ax.keys.down(AxKey.D)) {
				angle += 1+ROTATION * pedal/300;
			}
			else if (Ax.keys.down(AxKey.LEFT) || Ax.keys.down(AxKey.A)) {
				angle -= 1+ROTATION * pedal/300;
			}
			
			if (angle < 0) {
				angle += 360;
			}
			angle = angle % 361;
			
			//wake.alpha = pedal / 300;
 
			//wake.x = x - 64;
			//wake.y = y;
			//wake.x = x - 64;// + (Math.cos(Util.degreesToRadians(angle)) * (wake.x - x) - Math.sin(Util.degreesToRadians(angle)) * (wake.y - origin.y));
			//wake.y = origin.y + (Math.sin(Util.degreesToRadians(angle)) * (wake.y - origin.y) + Math.cos(Util.degreesToRadians(angle)) * (wake.y-origin.y));
			
			//wake.angle = angle;
			
			/*var radians:Number = Util.degreesToRadians(angle);
			var vector_from_pivot_to_object:Vec2 = new Vec2(wake.x - x, wake.y - y);

			var nx:Number = vector_from_pivot_to_object.x * Math.cos(radians);
			var ny:Number = vector_from_pivot_to_object.y * Math.sin(radians);

			wake.x = x + nx;
			wake.y = y + ny;
			
			FlashConnect.trace(wake.x + " x");
			FlashConnect.trace(wake.y + " y");*/
		}
	}

}