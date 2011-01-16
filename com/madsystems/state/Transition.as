package com.madsystems.state
{
	import com.madsystems.state.event.StateEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class Transition
	{
		public var components:Object = new Object( ) ;
		
		public function next( input:Event ):void {
			for each ( var component:EventDispatcher in components )
				component.dispatchEvent( new StateEvent( StateEvent.NEXT ));
		}
	}
}