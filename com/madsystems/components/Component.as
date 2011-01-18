package com.madsystems.components
{
	import flash.events.Event 
	import flash.display.Sprite;;	

	public class Component extends Sprite
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