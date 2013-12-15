package entities 
{
	import nape.phys.Body;
	import nape.phys.Material;
	import nape.space.Space;
	import org.axgl.AxSprite;
	import org.axgl.AxPoint;
	import nape.phys.BodyType
	import nape.shape.Circle;
	import nape.geom.Vec2;
	import org.axgl.AxU;
	import org.axgl.Ax;
	import org.axgl.input.AxKey;
	import Array;
	import org.flashdevelop.utils.FlashConnect;
	/**
	 * ...
	 * @author Chris Cacciatore
	 */
	public class Buoy extends AxSprite 
	{
		private const MASS:Number = 30.0;
		private const MAX_CIRCLING_DISTANCE:Number = 275.0;
		private const SAMPLE_RATE:Number = 0.1;
		private const MIN_SAMPLE_SIZE:uint = 16;
		
		public var body:Body;
		
		private var circlingPoints:Array;
		private var dtSample:Number;
		private var circled:Boolean;
		public var order:uint;
		
		public function Buoy(x:Number, y:Number, space:Space, order:uint) 
		{
			super(x, y, GA.BUOY);
			
			origin = new AxPoint(Tile.WIDTH / 2, Tile.HEIGHT / 2);
			
			body = new Body(BodyType.DYNAMIC);
			body.shapes.add(new Circle(Tile.WIDTH / 2));
			body.position = new Vec2(x, y);
			body.setShapeMaterials(Material.rubber());
			body.mass = MASS;
			body.space = space;
			
			circlingPoints = new Array();
			circled = false;
			dtSample = 0.0;
			
			this.order = order;
		}
		
		override public function update():void {
			super.update();
			
			x = body.position.x;
			y = body.position.y;
			
			updateStateIfPlayerNear();
			
			if (body.velocity.x > 0) {
				body.velocity.x -= 1.5;
			}
			else if (body.velocity.x < 0) {
				body.velocity.x += 1.5;
			}
			
			if (body.velocity.y > 0) {
				body.velocity.y -= 1.5;
			}
			else if (body.velocity.x < 0) {
				body.velocity.y += 1.5;
			}
		}
		
		private function updateStateIfPlayerNear():void {
			dtSample += Ax.dt;
			// only test for being circled if we haven't already been circled, we are the next in line to be circled, and it is time to sample
			if(!circled && GV.buoys[GV.nextBuoyPlayerNumber] == this && dtSample >= SAMPLE_RATE){
				if (calculateDistance(GV.player.body.position) < MAX_CIRCLING_DISTANCE) {
					circlingPoints.push(GV.player.body.position.copy());
					if (circlingPoints.length >= MIN_SAMPLE_SIZE){
						circled = isEclosed();
					}
					
					if (circled) {
						grow(1, 2, 2);
						GV.nextBuoyPlayerNumber++;
						FlashConnect.trace("Buoy " + order + " circled.");
					}
				}
				else {
					circlingPoints = new Array();
				}
				dtSample = 0.0;
			}
		}
		
		/* http://www.ecse.rpi.edu/Homepages/wrf/Research/Short_Notes/pnpoly.html */
		private function isEclosed():Boolean {
			var enclosed:Boolean = false;
			var p1:Vec2;
			var p2:Vec2;
			for (var i:uint = 0, j:uint = circlingPoints.length - 1; i < circlingPoints.length; j = i++) {
				p1 = circlingPoints[i];
				p2 = circlingPoints[j];
				
				if (((p1.y > y) != (p2.y > y)) && (x < (p2.x - p1.x) * (y - p1.y) / (p2.y - p1.y) + p1.x)) {
					enclosed = !enclosed;
				}
			}
			return enclosed;
		}
		
		private function calculateDistance(position:Vec2):Number {
			return Vec2.distance(body.position, position);
		}
		
	}

}