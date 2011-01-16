package com.madsystems.state
{
	import flash.events.Event ;
	
	public interface IState
	{
		function run():void ;
		function next( input:Event ):String ;
	}
}
