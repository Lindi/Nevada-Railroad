package com.madsystems.state
{
	import flash.events.Event;
	
	public interface Condition
	{
		function test( event:Event ):Boolean ;
	}
}