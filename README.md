# Test Driven Haxe

Test Driven Development using Haxe.  
Create test classes and run a suit of tests, validating the final results.  
Supports both `sync` and `async` testing with small code footprint.
Use the `Metadata` feature of Haxe to tag which methods are tests and also add extra information like Description and Author for better team coordination.  
  
# Install
`haxelib install git tddhx https://github.com/haxorplatform/tddhx`  
  
# Usage
To create test classes the procedure is really simple:  
```haxe
class MyTestSuite : Test
{
  @Test("This is a sync test.")
  @TestDescription("This some test I've made as example.","Eduardo")
  function testFirst(a : Assert)
  {
    a.True(false,"This assert failed!");
  }
  
  @TestAsync("This is an async test.")
  @TestDescription("This some test where the Timer emulates an async call.","Eduardo")
  function testSecond(a : Assert)
  {
    Timer.delay(function() 
    { 
      a.True(true,"Assertion failed!"); 
      a.Done(); //Must be called to signal this async test ended.
    },1000);
  }
  
  @TestAsync("This is an async test with timeout.",1.0)
  @TestDescription("This some test where the Timer emulates an async call.","Eduardo")
  function testThird(a : Assert)
  {
    Timer.delay(function() 
    { 
      //Will execute but the error timeout will take precedence.
      a.True(true,"Assertion failed!"); 
      a.Done(); //Must be called to signal this async test ended.
    },2000); //2s but timeout is 1s
  }
}
```  
After creating your test class.  
```haxe
class Main
{
  static function main()
  {
    var t : MyTestSuite = new MyTestSuite();
    t.Run("Test Suite Title",
    function(p_success:Bool):Void
    {
      trace("Test Suite "+(p_success ? "Succeeded" : "Failed"));
    });
  }
}
```









