package example;

import haxe.Timer;
import haxe.unit.Assert;
import haxe.unit.Test;
import js.Error;

/**
 * ...
 * @author Eduardo Pons - eduardo@thelaborat.org
 */
class TestDebug extends Test
{

	public var force : Bool;
	
	/**
	 * Init.
	 */
	override function OnTestCreate():Void 
	{
		trace("TestDebug> Test Created.");
		verbose = true;
		force = false;
	}
	
	@Test("Let's check not null")
	@TestDescription("Will force null and assert. Should fail both.", "Author")
	function testForceNotNull(a:Assert):Void
	{
		if (force) { a.True(true); a.Done(); return; }
		a.NotNull(null, "Null checking 1!");
		a.NotNull(null, "Null checking 2!");
	}
	
	@Test("Let's check null")
	@TestDescription("Will force null and assert. Should fail only 2", "Author")
	function testForceNull(a:Assert):Void
	{
		if (force) { a.True(true); a.Done(); return; }
		a.Null(null, "Null checking 1!");
		a.NotNull(null, "Null checking 2!");
	}
	
	
	@TestAsync("Let's async test.")
	@TestDescription("Will call a method asynchronously and delay the result.", "Author")
	function testAsyncTrue(a:Assert):Void
	{
		Timer.delay(function()
		{
			if (force) { a.True(true); a.Done(); return; }
			a.True(false, "True checking!");
			a.Done(); //Must call done to signal async end.			
		},1000);
	}
	
	@TestAsync("Let's async timeout!!",1.0)
	@TestDescription("Will call a method asynchronously and delay the result. Should fail because delay is bigger than timeout.", "Author")
	function testAsyncTrueTimeout(a:Assert):Void
	{
		if (force) { a.True(true); a.Done(); return; }
		Timer.delay(function()
		{
			a.True(true, "True checking but in vain!");
			a.Done(); //Must call done to signal async end.			
		},3000);
	}
	
	@TestAsync("Long victory!")
	@TestDescription("Will call a method asynchronously and delay the result. Will succeed.", "Author")
	function testAsyncTrueVictory(a:Assert):Void
	{
		Timer.delay(function()
		{			
			a.True(true, "True checking!");
			a.Done(); //Must call done to signal async end.			
		},5000);
	}
	
	@Test("Let's throw some error!")
	@TestDescription("Will force an error throw! Should fail!", "Author")
	function testForceError(a:Assert):Void
	{
		if (force) { a.True(true); a.Done(); return; }
		throw new Error("LOL Fail!");
	}
}