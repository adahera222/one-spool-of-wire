package  
{
	import entities.Player;
	import states.GameState;
	/**
	 * ...
	 * @author Chris Cacciatore
	 */
	public class GV 
	{
		public static var currentStage:Class;
		public static var player:Player;
		
		public static var nextBuoyPlayerNumber:uint;
		public static var countBuoys:uint;
		
		public static var buoys:Array;
		
		public static var game:GameState;
	}

}