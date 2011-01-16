package com.madsystems.components.map
{
	import flash.events.Event;
	import flash.geom.Point;

	internal class RouteEvent extends Event
	{
		internal var position:Point ;
		
		//	Called when ...
		internal static const DRAW:String = "draw" ;
		
		//	Called when the route is done drawing
		internal static const DRAWING_COMPLETE:String = "drawing_complete" ;
		
		//	Called when the route data has loaded
		internal static const LOADED:String = "route_data_loaded" ;
		
		
		public function RouteEvent(type:String, position:Point, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			//trace("RouteEvent("+type+""+position+")");
			this.position = position ;
		}
		
	}
}