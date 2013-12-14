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
	
	/**
	 * ...
	 * @author Chris Cacciatore
	 */
	public class Buoy extends AxSprite 
	{
		private const MASS:Number = 1000.0;
		private var body:Body;
		
		public function Buoy(x:Number, y:Number, space:Space) 
		{
			super(x, y, GA.BUOY);
			
			origin = new AxPoint(Tile.WIDTH / 2, Tile.HEIGHT / 2);
			
			body = new Body(BodyType.DYNAMIC);
			body.shapes.add(new Circle(Tile.WIDTH / 2));
			body.position = new Vec2(x, y);
			body.setShapeMaterials(Material.rubber());
			body.mass = MASS;
			body.space = space;
		}
		
		override public function update():void {
			super.update();
			
			x = body.position.x;
			y = body.position.y;
		}
		
	}

}