package com.madsystems.components
{
	import flash.display.Sprite;
	import flash.events.Event;

	public class Component extends Sprite implements IComponent
	{	
		public var id:String ;
			
		/**
		 * run
		 * 
		 * Default abstract method.  The run method is invoked
		 * by the controlling state in order to activate the component
		 **/ 
		public function run( event:Event ):void {}
		
		/**
		 * next
		 * 
		 * Default abstract method.  The next method is invoked
		 * by the controlling state in order to de-activate the component
		 **/ 
		public function next( event:Event ):void {}
		
	}
}