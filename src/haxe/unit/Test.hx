package haxe.unit;
import haxe.macro.Expr.ImportExpr;
import haxe.rtti.CType.MetaData;
import haxe.rtti.Meta;
import js.Error;
import haxe.Timer;

/**
 * Class that implements testing features using Haxe's metadata information.
 * @author Eduardo Pons - eduardo@thelaborat.org
 */
class Test
{

	/**
	 * List of tests.
	 */
	public var tests	: Array<MetaData>;
	
	/**
	 * Test length.
	 */
	public var length(get, never):Int;
	private function get_length():Int { return tests.length; } 
	
	/**
	 * Success Count
	 */
	public var success  : Int;
	
	/**
	 * Fail Count
	 */
	public var fail 	: Int;
	
	/**
	 * Timeout Count
	 */
	public var timeout  : Int;
	
	/**
	 * Array of metadata of this instance.
	 */
	public var metadata(get, never) : Array<MetaData>;
	private function get_metadata():Array<MetaData>
	{
		if (m_metadata != null) return m_metadata;
		var ml : Array<Dynamic> = m_metadata = [];
		
		//fetches the RTTI and execute the functions		
		var c : Class<Dynamic>	 		  	= Type.getClass(this);				
		var cl : Array<Class<Dynamic>> 		= [];
		while (c != null) { cl.push(c); c = cast Type.getSuperClass(c); }
		cl.pop(); 	  //Removes base because it has no metas
		cl.reverse(); //Make it start in base classes and go up.
		for (it in cl)
		{
			var d : Array<Dynamic> = cast Meta.getFields(it);
			untyped __js__ ("for (var f in d) { var md = { field: f, data: d[f]==null ? {} : d[f] }; ml.push(md); }"); 
		}
		return m_metadata;
	}
	private var m_metadata : Array<MetaData>;
	
	/**
	 * Flag that indicates the testing will be output on console.
	 */
	public var verbose : Bool;
	
	/**
	 * Buffer of tests to be executed.
	 */
	private var m_buffer : Array<MetaData>;
	private var m_on_complete : Bool->Void;
	
	/**
	 * Init.
	 */
	public function new():Void 
	{		
		success  = 0;
		fail     = 0;
		timeout  = 0;
		tests	 = [];
		m_buffer = [];
		verbose  = false;
		var ml : Array<Dynamic> = metadata;						
		for (m in ml) { var is_test   : Bool = (m.data.Test != null) || (m.data.TestAsync != null); if (is_test) tests.push(m); }		
		OnTestCreate();
	}
	
	/**
	 * Callback called when this test instance is created.
	 */
	private function OnTestCreate():Void { }
	
	/**
	 * Callback called when testing is finished.
	 * @param	p_success
	 */
	private function OnTestComplete(p_success:Bool):Void { }
		
	/**
	 * Run All Tests.
	 * @param	p_title
	 */
	public function Run(p_title:String,p_on_complete:Bool->Void=null):Void
	{		
		m_on_complete = p_on_complete;
		success = 0;
		fail    = 0;
		timeout = 0;
		m_buffer = tests.copy();
		if(verbose)trace("======= " + p_title+" - "+length+" tests =======");
		UnqueueTest();
	}	
	
	/**
	 * Creates the closest possible stub for the informed type.
	 * @param	p_type
	 * @return
	 */
	public function Stub(p_type : Class<Dynamic>=null):Dynamic
	{	
		var t : Class<Dynamic> = p_type;
		if (t == null) return { };	
		return Type.createInstance(p_type, []);
	}
	
	/**
	 * Unqueues a test and execute it.
	 */
	private function UnqueueTest():Void
	{
		if (m_buffer == null) return;
		if (m_buffer.length <= 0)
		{			
			m_buffer = null;
			var is_success :Bool = (fail <= 0) && (timeout <= 0);
			OnTestComplete(is_success);
			if(verbose)trace("======= success["+success+"] fail["+fail+"] timeout["+timeout+"] =======");
			if (m_on_complete != null) m_on_complete(is_success);			
			return;
		}
		
		RunTest(m_buffer.shift());
		
	}
	
	/**
	 * Executes a single test for a given testing metadata.
	 * @param	p_meta
	 */
	private function RunTest(p_meta:Dynamic):Void
	{
		var m : Dynamic = p_meta;		
		var f : String  = m.field;
		var is_async  	 : Bool    			= m.data.TestAsync != null;
		var test_meta 	 : Array<Dynamic>   = is_async ? m.data.TestAsync : m.data.Test;
		var test_name 	 : String 			= test_meta[0] == null ? f  : test_meta[0];
		
		var test_timeout : Int	 			= test_meta[1] == null ? -1 : test_meta[1];
		test_timeout = Std.int(test_timeout * 1000);
		
		var test_desc 	 : Array<String>	= m.data.TestDescription == null ? ["",""] : m.data.TestDescription;
		
		var test_func 	: Dynamic 			= Reflect.getProperty(this, f);
		
		var desc 	  	 : String			= test_desc[0];
		
		if (test_desc[1] != "") desc += " author["+test_desc[1]+"]";
		
		var is_error   : Bool = false;
		var is_timeout : Bool = false;			
		var is_finished: Bool = false;
		
		var a			: Assert		= null;
		var assert_func : Assert->Void	= null;
		
		if(verbose)trace("- "+ test_name+" - "+desc); 
		
		if (is_async)
		{				
			if (test_timeout >= 0)
			{				
				Timer.delay(function()
				{
					if (is_error) 	 return;
					if (is_finished) return;
					is_timeout = true;
					TestTimeout(m);					
					UnqueueTest();
				}, test_timeout);
			}
			
			assert_func =
			function(p_assert:Assert):Void
			{
				if (is_timeout) return;
				if (is_error)   return;		
				is_finished = true;
				TestComplete(m, a);
				UnqueueTest();
			}
		}
		
		a = new Assert(assert_func);
		
		try
		{			
			Reflect.callMethod(this, test_func, [a]);			
		}
		catch (err:Error)
		{
			is_error = true;
			TestError(m, err);
			UnqueueTest();
			return;			
		}
		
		if (!is_async)
		{
			TestComplete(m, a);
			UnqueueTest();
		}
		
	}
	
	/**
	 * 
	 * @param	p_test
	 */
	private function TestTimeout(p_test:Dynamic):Void
	{
		timeout++;
		fail++;		
		if(verbose) trace("[f] Timeout");		
	}
	
	/**
	 * 
	 * @param	p_test
	 * @param	p_error
	 */
	private function TestError(p_test : Dynamic, p_error:Error):Void
	{
		fail++;	
		if(verbose)trace("[e] " + p_error.name+" [" + p_error.message + "]");
	}
	
	/**
	 * 
	 * @param	p_test
	 * @param	p_assert
	 */
	private function TestComplete(p_test : Dynamic, p_assert:Assert):Void
	{		
		if (p_assert.valid) { success++; if (verbose) trace("[s]");  } 
		else 
		{ 
			fail++; 
			if (verbose) { for(s in p_assert.fails) trace("[f] " + s); }
		}
	}
}