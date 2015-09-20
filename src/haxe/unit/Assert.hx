package haxe.unit;

/**
 * ...
 * @author Eduardo Pons - eduardo@thelaborat.org
 */
class Assert
{
	/**
	 * Flag that indicates the assertion is still valid.
	 */
	public var valid : Bool;
	
	/**
	 * Number of assertions made.
	 */
	public var count : Int;
	
	/**
	 * List of assertion fails.
	 */
	public var fails : Array<String>;
	
	private var m_on_complete : Assert->Void;
	/**
	 * CTOR.
	 */
	public function new(p_on_complete : Assert->Void=null) 
	{
		valid = true;
		count = 0;
		fails = [];
		m_on_complete = p_on_complete;
	}
	
	public function Done():Void
	{
		if (m_on_complete != null) m_on_complete(this);
	}
	
	public function Fail(p_msg:String=""):Void
	{
		valid = false;
		fails.push(p_msg);
	}
	
	public function True	(a:Bool, 	msg:String = ""):Assert				{ count++; if (!a) 	   		{ Fail(msg); } return this; }
	public function False	(a:Bool, 	msg:String = ""):Assert				{ count++; if (a) 	   		{ Fail(msg); } return this; }
	public function Null	(a:Dynamic, msg:String = ""):Assert				{ count++; if (a != null) 	{ Fail(msg); } return this; }
	public function NotNull (a:Dynamic, msg:String = ""):Assert				{ count++; if (a == null) 	{ Fail(msg); } return this; }
	public function Equal	(a:Dynamic, b:Dynamic, msg:String = ""):Assert	{ count++; if (a != b) 		{ Fail(msg); } return this; }
	public function NotEqual(a:Dynamic, b:Dynamic, msg:String = ""):Assert	{ count++; if (a == b) 		{ Fail(msg); } return this; }
	
}