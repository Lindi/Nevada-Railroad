package com.madsystems.state.event
{
	import flash.events.Event;

	public class StateEvent extends Event
	{
		public static const RUN:String = "run" ;
		public static const NEXT:String = "next" ;
		
		public function StateEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event {
			return new StateEvent( type );
		}
	}
}