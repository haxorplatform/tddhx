package;
import example.TestDebug;
import haxe.unit.Test;

/**
 * ...
 * @author Eduardo Pons - eduardo@thelaborat.org
 */
class Main
{

	static function main()
	{
		trace("Main> Init.");
		
		var t0 : TestDebug;
		
		t0 = new TestDebug();
		//t0.force = true;
		t0.Run("Test Debug force["+t0.force+"]", function(p_success:Bool):Void
		{
			trace(">>> success["+p_success+"]");
		});
		
	}
	
}