package states 
{
	import entities.Player;
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
	
	/**
	 * ...
	 * @author Chris Cacciatore
	 */
	public class GameState extends AxState 
	{
		private var TILEMAP_COLLIDER:AxCollider;
		private var collidables:AxGroup;
		
		private var player:Player;
		
		override public function create():void {			
			var reader:TiledReader = new TiledReader;
			var map:TiledMap = reader.loadFromEmbedded(GV.currentStage);
			
			var tmpTilemap:AxTilemap;
			var tmpTileLayer:TiledTileLayer;
			
			collidables = new AxGroup();
			
			TILEMAP_COLLIDER = new AxCollider();
			
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
								add(player = new Player(object.x, object.y - Tile.WIDTH));
								break;
							case "buoy":
								// add a buoy
								//add(new Buoy(object.x, object.y - Tile.WIDTH));
						}
					}
				} else if(layer.name == "Collision"){
					var collides:AxTilemap = new AxTilemap();
					tmpTileLayer = layer as TiledTileLayer;
					
					collides.build(tmpTileLayer.data, GA.TILESET, Tile.WIDTH, Tile.WIDTH);
					collides.visible = false;
					collidables.add(collides);
				}
			}
			
			Ax.camera.bounds = new AxRect(0, 0, map.width * Tile.WIDTH, map.height * Tile.HEIGHT);
			Ax.camera.follow(player);
			FlashConnect.trace("GameState created.");
		}
		
		override public function update():void {
			super.update();
			if (Ax.keys.pressed(AxKey.P)) {
				Ax.pushState(new PauseState());
			}

			//Ax.collide(player, collidables, null, TILEMAP_COLLIDER);
		}
		
	}

}