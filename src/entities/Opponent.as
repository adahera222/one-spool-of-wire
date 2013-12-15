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
	import nape.phys.Material;
	
	/**
	 * ...
	 * @author Chris Cacciatore
	 */
	public class Opponent extends AxSprite 
	{
		
		private const MAX_CIRCLING_DISTANCE:Number = 200.0;
		private const SAMPLE_RATE:Number = 0.2;
		private const MIN_SAMPLE_SIZE:uint = 16;
		private const STEERING_EPSILON:Number = 5;
		
		private var circlingPoints:Array;
		private var dtSample:Number;
		private var circled:Boolean;
		
		private const ROTATION:Number = 2;
		private const MASS:Number = 1;
		
		private const LEFT:uint = 1;
		private const RIGHT:uint = 2;
		
		private var pedal:Number;
		private var pedalMax:Number;
		
		public var body:Body;
		
		private var speed:uint;
		private var nextBuoyNumber:uint;
		
		private const FAST:uint = 3;
		private const MEDIUM:uint = 2;
		private const SLOW:uint = 1;
		
		public function Opponent(x:Number, y:Number, space:Space) 
		{
			super(x, y, GA.BOAT_1);
			
			pedal = 0.0;
			
			origin = new AxPoint(Tile.WIDTH / 2, Tile.HEIGHT / 2);
			
			body = new Body(BodyType.DYNAMIC);
			body.shapes.add(new Circle(Tile.WIDTH / 2));
			body.position = new Vec2(x, y);
			body.mass = MASS;
			body.setShapeMaterials(Material.wood());
			body.space = space;
			
			nextBuoyNumber = 2;
			
			pedalMax = 0;
		}
		
		private function navigate():uint {
			var targetBuoy:Buoy = GV.buoys[nextBuoyNumber];
			var direction:uint = 0;
			var d:Number;
			
			speed = NONE;
			if ((d = calculateDistance(targetBuoy.body.position)) >= MAX_CIRCLING_DISTANCE) {
				var targetX:Number = targetBuoy.body.position.x;
				var targetY:Number = targetBuoy.body.position.y;
				
				var dlat:Number = targetX - x;
				var dlon:Number = targetY - y;
				
				var tmpY:Number = Math.sin(dlon) * Math.cos(targetX);
				var tmpX:Number = Math.cos(x) * Math.sin(targetY) - Math.sin(x) * Math.cos(targetX) * Math.cos(dlon);
				
				var tc1:Number;
				if(tmpY > 0){
					if (tmpX > 0)
						tc1 = Math.atan(tmpY / tmpX);
						if(Math.abs(angle - tc1) > 15){
							direction = LEFT;
						}
					if (tmpX < 0)
						tc1 = 180 - Math.atan( -tmpY / tmpX);
						if(Math.abs(angle - tc1) > 15){
							direction = RIGHT;
						}
					if (tmpX == 0){
						tc1 = 90;
					}
				}
				if(tmpY < 0){
					if (tmpX > 0){
						tc1 = -Math.atan( -tmpY / tmpX);
						if(Math.abs(angle - tc1) > 15){
							direction = LEFT;
						}
					}
					if (tmpX < 0){
						tc1 = Math.atan(tmpY / tmpX) - 180;
						if(Math.abs(angle - tc1) > 15){
							direction = RIGHT;
						}
					}
					if (tmpX == 0){
						tc1 = 270;
					}
				}
				if(tmpY == 0){
					if (tmpX > 0)
						tc1 = 0;
					if (tmpX < 0)
						tc1 = 180;
				}
				speed = FAST;
			}
			// if not in range of next buoy, then get closer
			// else move to upper right corner
			// else move to lower right corner
			// else move to lower left corner
			// else move to upper left corner
			// else move to upper right corner
			
			// if aggressive and nearby opponent or player is ranked closely, then bump
			return direction;
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
						nextBuoyNumber++;
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
		
		override public function update():void {
			super.update();
			
			x = body.position.x;
			y = body.position.y;
			
			switch(speed) {
				case FAST:
					pedal += 50;
					pedalMax = 300;
					break;
				case MEDIUM:
					pedal += 25;
					pedalMax = 200;
					break;
				case SLOW:
					pedal += 10;
					pedalMax = 100;
				default:
					pedal -= 2;
			}
			
			pedal = AxU.clamp(pedal, 0, pedalMax);
			
			body.velocity.x = pedal * Math.cos(Util.degreesToRadians(-angle));
			body.velocity.y = pedal * -Math.sin(Util.degreesToRadians( -angle));
			
			switch(navigate()) {
				case LEFT:
					angle -= ROTATION * pedal / 300;
					break;
				case RIGHT:
					angle += ROTATION * pedal / 300;
					break;
			}
		}
	}

}