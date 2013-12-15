package states 
{
	import entities.Player;
	import flash.events.GameInputEvent;
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
	import entities.Buoy;
	import entities.Opponent;
	import org.axgl.util.AxTimer;
	import org.axgl.AxU;
	import org.axgl.camera.AxCamera;
	import com.greensock.TweenMax;
	import com.greensock.easing.BounceInOut;
	import com.greensock.easing.ElasticOut;
	
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
		
		private var gameDone:Boolean;
		
		private var swayTween:TweenMax;
		
		private var transitionX:Boolean;
		private var transitionY:Boolean;
		
		public function GameState() {
			space = new Space(null);
			
			GV.game = this;
		}
		
		override public function create():void {			
			var reader:TiledReader = new TiledReader;
			var map:TiledMap = reader.loadFromEmbedded(GV.currentStage);
			
			var tmpTilemap:AxTilemap;
			var tmpTileLayer:TiledTileLayer;
			
			GV.nextBuoyPlayerNumber = 0;
			GV.buoys = new Array();
			gameDone = false;
			
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
								add(GV.player = player = new Player(object.x, object.y - Tile.WIDTH, space));
								break;
							case "buoy":
								// add a buoy
								var buoy:Buoy = new Buoy(object.x, object.y - Tile.WIDTH, space, parseInt(object.properties.get("order")));
								add(buoy);
								GV.buoys.push(buoy);
								break;
							case "opponent":
								// add an opponent
								add(new Opponent(object.x, object.y - Tile.WIDTH, space));
								break;
						}
					}
				}
			}
			
			GV.buoys.sortOn("order");
			
			var mapHeight:Number = map.height * map.tileHeight;
			var mapWidth:Number = map.width * map.tileWidth;
			
			walls = new Body(BodyType.KINEMATIC);
			walls.shapes.add( new Polygon( Polygon.rect(0-Tile.WIDTH*2, 0, BOUNDS_THICKNESS-Tile.WIDTH, mapHeight)));
			walls.shapes.add( new Polygon( Polygon.rect(mapWidth, 0, BOUNDS_THICKNESS, mapHeight)));
			walls.shapes.add( new Polygon( Polygon.rect(0, 0-Tile.HEIGHT*3, mapWidth, BOUNDS_THICKNESS)));
			walls.shapes.add( new Polygon( Polygon.rect(0, mapHeight, mapWidth, BOUNDS_THICKNESS)));
			walls.space = space;
			
			Ax.camera.bounds = new AxRect(0, 0, map.width * Tile.WIDTH, map.height * Tile.HEIGHT);
			//Ax.camera.follow(player);
			
			swayTween = TweenMax.to(Ax.camera, 1.2, { y:Ax.camera.y + 7, ease:BounceInOut, yoyo:true, repeat: -1 } );
			
			transitionX = false;
			transitionY = false;
			
			FlashConnect.trace("GameState created.");
		}
		
		override public function update():void {
			super.update();
			if (Ax.keys.pressed(AxKey.P)) {
				Ax.pushState(new PauseState());
			}
			
			if (!gameDone && gameIsWon()) {
				FlashConnect.trace("Stage complete!");
				this.addTimer(3, reallyWinGame);
				gameDone = true;
			}
			space.step( 1 / 60 );
			
			if ((player.x + player.width > Ax.camera.x + 800) && !transitionX) {
				transitionX = true;
				TweenMax.to(Ax.camera, 1.5, { x:800, ease:ElasticOut, onComplete:function() { transitionX = false; } } );
			}
			else if ((player.x < Ax.camera.x && player.x > 64) && !transitionX) {
				transitionX = true;
				TweenMax.to(Ax.camera, 1.5, { x: Ax.camera.x - 800,ease:ElasticOut, onComplete:function() { transitionX = false; } });
			}
			
			if ((player.y + Tile.HEIGHT > Ax.camera.y + 600) && !transitionY) {
				transitionY = true;
				TweenMax.to(Ax.camera, 1.5, { y: Ax.camera.y + 600, ease:ElasticOut, onComplete:startSwayAgain} );
			}
			else if ((player.y < Ax.camera.y && player.y > 64) && !transitionY) {
				transitionY = true;
				TweenMax.to(Ax.camera, 1.5, { y: Ax.camera.y - 600, ease:ElasticOut, onComplete:startSwayAgain } );
			}
		}
		
		public function startSwayAgain():void {
			transitionY = false;
			swayTween.kill();
			swayTween = TweenMax.to(Ax.camera, 1.2, {y:Ax.camera.y+7,ease:BounceInOut, yoyo:true, repeat:-1});
		}
		
		private function gameIsWon():Boolean {
			return GV.nextBuoyPlayerNumber > GV.buoys.length-1;
		}
		
		public function loseGame():void {
			if (!gameDone) {
				FlashConnect.trace("You lose!");
				this.addTimer(3, reallyLoseGame);
				gameDone = true;
			}
		}
		
		public function reallyLoseGame():void {
			Ax.switchState(new GameState());
		}
		
		public function reallyWinGame():void {
			incrementStage();  
			Ax.switchState(new GameState());
		}
		
		private function incrementStage():void {
			if (GV.currentStage == GA.TEST_STAGE) {
				GV.currentStage = GA.TEST_STAGE;
			}
		}
		
	}

}