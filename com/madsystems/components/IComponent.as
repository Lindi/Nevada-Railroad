package com.madsystems.components
{
	import flash.events.Event ;
	
	public interface IComponent
	{
		function run( event:Event ):void ;
		function next( event:Event ):void ;
	}
}