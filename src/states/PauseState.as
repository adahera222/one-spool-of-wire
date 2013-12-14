package states 
{
	import org.axgl.util.AxPauseState;
	import org.axgl.Ax;
	import org.axgl.input.AxKey;
	
	/**
	 * ...
	 * @author Chris Cacciatore
	 */
	public class PauseState extends AxPauseState 
	{
		override public function update():void {
			super.update();
			if (Ax.keys.pressed(AxKey.P)) {
				Ax.popState();
			}
		}
	}

}