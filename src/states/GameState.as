package states 
{
	import entities.Player;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.shape.Circle;
	import nape.shape.Polygon;
	import nape.space.Space;
	import org.axgl.AxGroup;
	import org.axgl.AxState;
	import org.axgl.tilemap.AxTilemap;
	import org.axgl.collision.AxCollider;
	import io.arkeus.tiled.TiledReader;
	import io.arkeus.tiled.TiledTileLayer;
	import io.arkeus.tiled.TiledLayer;
	import org.axgl.Ax;
	import io.arkeus.tiled.TiledObjectLayer;
	import org.axgl.input.AxKey;
	import org.flashdevelop.utils.FlashConnect;
	import org.axgl.AxRect;
	import io.arkeus.tiled.TiledObject;
	import io.arkeus.tiled.TiledMap;
	import nape.phys.BodyType;
	
	/**
	 * ...
	 * @author Chris Cacciatore
	 */
	public class GameState extends AxState 
	{
		private const BOUNDS_THICKNESS:Number = 64;

		private var space:Space;
		private var player:Player;
		private var walls:Body;
		
		public function GameState() {
			space = new Space(null);
		}
		
		override public function create():void {			
			var reader:TiledReader = new TiledReader;
			var map:TiledMap = reader.loadFromEmbedded(GV.currentStage);
			
			var tmpTilemap:AxTilemap;
			var tmpTileLayer:TiledTileLayer;
			
			for each(var layer:TiledLayer in map.layers.getAllLayers()) {
				if (layer.name == "Background") {
					tmpTilemap = new AxTilemap();
					tmpTileLayer = layer as TiledTileLayer;
					
					tmpTilemap.build(tmpTileLayer.data, GA.TILESET, Tile.WIDTH, Tile.HEIGHT);
					tmpTilemap.visible = true;
					add(tmpTilemap);
				
				} else if (layer is TiledObjectLayer) {
					for each(var object:TiledObject in (layer as TiledObjectLayer).objects) {
						switch(object.type) {
							case "player":
								// add the main player
								add(player = new Player(object.x, object.y - Tile.WIDTH, space));
								break;
							case "buoy":
								// add a buoy
								//add(new Buoy(object.x, object.y - Tile.WIDTH));
						}
					}
				}
			}
			
			var mapHeight:Number = map.height * map.tileHeight;
			var mapWidth:Number = map.width * map.tileWidth;
			
			walls = new Body(BodyType.KINEMATIC);
			walls.shapes.add( new Polygon( Polygon.rect(0-Tile.WIDTH*2, 0, BOUNDS_THICKNESS-Tile.WIDTH, mapHeight)));
			walls.shapes.add( new Polygon( Polygon.rect(mapWidth, 0, BOUNDS_THICKNESS, mapHeight)));
			walls.shapes.add( new Polygon( Polygon.rect(0, 0-Tile.HEIGHT*2, mapWidth, BOUNDS_THICKNESS)));
			walls.shapes.add( new Polygon( Polygon.rect(0, mapHeight+Tile.HEIGHT*2, mapWidth, BOUNDS_THICKNESS)));
			walls.space = space;
			
			Ax.camera.bounds = new AxRect(0, 0, map.width * Tile.WIDTH, map.height * Tile.HEIGHT);
			Ax.camera.follow(player);
			FlashConnect.trace("GameState created.");
		}
		
		override public function update():void {
			super.update();
			if (Ax.keys.pressed(AxKey.P)) {
				Ax.pushState(new PauseState());
			}
			
			space.step( 1 / 60 );
		}
		
	}

}