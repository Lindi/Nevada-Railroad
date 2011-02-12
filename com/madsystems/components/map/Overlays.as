package com.madsystems.components.map
{
	import com.madsystems.components.Component;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.geom.Point;
	
	internal class Overlays extends Component implements IOverlays
	{
		protected var overlays:Array ;
		
		public function Overlays( overlays:Array )
		{
				this.overlays = overlays ;
		}
		
		override public function run( event:Event ):void {
			//	Add the overlays to the parent object
			for each ( var overlay:Object in overlays )
				addChild( overlay.loader as DisplayObject );	
		}
		
		override public function next( event:Event ):void {
			//	Remove the overlays from the parent object
			for each ( var overlay:Object in overlays )
				removeChild( overlay.loader as DisplayObject );	
			
		}
		
		public function overlay( zoom:Number, location:Point ):void {
			
			x = location.x ;
			y = location.y ;
			scaleX = scaleY = zoom ; 
			
//			for each ( var overlay:Object in overlays ) {
//				
//				//	Scale the loader 
//				( overlay.loader as DisplayObject ).scaleX =
//				( overlay.loader as DisplayObject ).scaleY = zoom ;
//				
//				//	Move the loader
//				( overlay.loader as DisplayObject ).x =
//					overlay.loader.x * zoom + location.x ;
//				( overlay.loader as DisplayObject ).x =
//					overlay.loader.y * zoom + location.y ;
//					
//			}	
		}
	}
}

