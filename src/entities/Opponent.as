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
		
		private const ROTATION:Number = 2;
		private const MASS:Number = 10;
		
		private const LEFT:uint = 1;
		private const RIGHT:uint = 2;
		
		private var pedal:Number;
		private var pedalMax:Number;
		
		public var body:Body;
		
		private var speed:uint;
		private var nextBuoyNumber:uint;
		private var nextBuoyCorner:uint;
		
		private const TOP_RIGHT:uint = 0;
		private const BOTTOM_RIGHT:uint = 1;
		private const BOTTOM_LEFT:uint = 2;
		private const TOP_LEFT:uint = 3;
		private const TOP_RIGHT_AGAIN:uint = 4;
		
		private const FAST:uint = 3;
		private const MEDIUM:uint = 2;
		private const SLOW:uint = 1;
	
		public function Opponent(x:Number, y:Number, space:Space)
		{
			super(x, y);
			load(GA.BOAT_1 , Tile.WIDTH*2, Tile.HEIGHT*2);
            addAnimation("idle", [0], 1, false);
			
			animate("idle");
			
			pedal = 0.0;
			
			body = new Body(BodyType.DYNAMIC);
			body.shapes.add(new Circle(Tile.WIDTH));
			body.position = new Vec2(x, y);
			body.mass = MASS;
			body.setShapeMaterials(Material.wood());
			body.space = space;
			
			nextBuoyNumber = 0;
			
			pedalMax = 0;
			nextBuoyCorner = TOP_RIGHT;
		}
		
		private function headTo(position:Vec2):uint
		{
			var direction:uint = 0;
			
			var targetX:Number = position.x;
			var targetY:Number = position.y;
			
			var dlat:Number = targetX - x;
			var dlon:Number = targetY - y;
			
			var tc1:Number;
			
			var d:Number = calculateDistance(position);
			
			var heading:Number = Util.radiansToDegrees(Math.atan2(dlon, dlat));
			
			angle += (heading - angle);
			// eventually get smoother turning
			
			//if (heading > angle) {
				//direction = RIGHT;
			//	angle = angle + heading / 5;
			//}
			//else if(heading < angle){
				//direction = LEFT;
			//	angle 
			//}
			return direction;
		}
		
		private function navigate():uint
		{
			var targetBuoy:Buoy = GV.buoys[nextBuoyNumber];
			var direction:uint;
			var d:Number;
			
			var topRight:Vec2 = new Vec2(targetBuoy.body.position.x + 128, targetBuoy.body.position.y -128);
			var bottomRight:Vec2 = new Vec2(targetBuoy.body.position.x + 128, targetBuoy.body.position.y +128);
			var bottomLeft:Vec2 = new Vec2(targetBuoy.body.position.x -128, targetBuoy.body.position.y +128);
			var topLeft:Vec2 = new Vec2(targetBuoy.body.position.x - 128, targetBuoy.body.position.y -128);
			
			speed = NONE;
			direction = 0;
			if ((d = calculateDistance(targetBuoy.body.position)) >= MAX_CIRCLING_DISTANCE)
			{
				direction = headTo(targetBuoy.body.position);
				speed = FAST;
				nextBuoyCorner = TOP_RIGHT;
			}
			else {
				speed = MEDIUM;
				switch(nextBuoyCorner) {
					case TOP_RIGHT:
						// check if made it
						if (calculateDistance(topRight) >= 96) {
							direction = headTo(topRight);
						}
						else {
							nextBuoyCorner++;
						}
						break;
					case BOTTOM_RIGHT:
						// check if made it
						if (calculateDistance(bottomRight) >= 96) {
							headTo(bottomRight);
						}
						else {
							nextBuoyCorner++;
						}
						break;
					case BOTTOM_LEFT:
						// check if made it
						if (calculateDistance(bottomLeft) >= 96) {
							headTo(bottomLeft);
						}
						else {
							nextBuoyCorner++;
						}
						break;
					case TOP_LEFT:
						// check if made it
						if (calculateDistance(topLeft) >= 96) {
							headTo(topLeft);
						}
						else {
							nextBuoyCorner++;
						}
						break;
					case TOP_RIGHT_AGAIN:
						// check if made it
						if (calculateDistance(topRight) >= 96) {
							headTo(topRight);
						}
						else {
							nextBuoyNumber++;
							nextBuoyCorner = TOP_RIGHT;
							
							if (nextBuoyNumber >= GV.buoys.length) {
								GV.game.loseGame();
							}
							nextBuoyNumber = nextBuoyNumber % GV.buoys.length;
						}
						break;
				}
			}
			
			// if aggressive and nearby opponent or player is ranked closely, then bump
			return direction;
		}
		
		private function calculateDistance(position:Vec2):Number
		{
			return Vec2.distance(body.position, position);
		}
		
		override public function update():void
		{
			super.update();
			
			x = body.position.x;
			y = body.position.y;
		
			switch (speed)
			{
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
			body.velocity.y = pedal * -Math.sin(Util.degreesToRadians(-angle));
			
			switch (navigate())
			{
				case LEFT: 
					angle -= (ROTATION * pedal / 300) + 1.5;
					break;
				case RIGHT: 
					angle += (ROTATION * pedal / 300) + 1.5;
					break;
			}
			
			if (angle < 0) {
				angle += 360;
			}
			angle = angle % 361;
		}
	}

}