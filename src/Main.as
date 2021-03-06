package 
{
	import org.axgl.Ax;
	import states.GameState;
	/**
	 * ...
	 * @author Chris Cacciatore
	 */
	public class Main extends Ax {		
		public function Main() {
			GV.currentStage = GA.TEST_STAGE;
			super(states.GameState, 800, 600, 1, 60, true);
		}

		override public function create():void {
			Ax.unfocusedFramerate = 60;
			debuggerEnabled = true;
			debugger.active = true;
		}
	}
}