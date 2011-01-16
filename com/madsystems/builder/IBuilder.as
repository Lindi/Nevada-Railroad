package com.madsystems.builder
{
	import flash.display.DisplayObjectContainer;
	
	public interface IBuilder
	{
		function create( object:Object ):Object ;
		function build( xml:XML ):Object ;
	}
}