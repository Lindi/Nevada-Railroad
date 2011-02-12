package com.madsystems.components.map
{
	import flash.geom.Point;
	import flash.display.DisplayObject ;

	internal class TrailMarkers extends Overlays
	{
		public function TrailMarkers( overlays:Array )
		{
			super( overlays );
		}
		
		override public function overlay(zoom:Number, location:Point):void
		{
			scaleX = scaleY = zoom ;
			x = location.x ;
			y = location.y ;
			graphics.clear();
			for ( var i:int = 0; i < overlays.length; i++ ) {
				var overlay:Object = overlays[ i];
				var x0:Number = overlay.x - overlays[0].x ;
				var y0:Number = overlay.y - overlays[0].y ;
				var dx:Number = location.x - overlays[0].x ;
				var dy:Number = location.y - overlays[0].y ;
				var show:Boolean = ( zoom >= overlay.zoom ) ;
				show = show &&  (( dx * dx + dy * dy ) > ( x0 * x0 + y0 * y0 )); 
				overlay.alpha += ( Number( show ) - overlay.alpha ) * .5 ;
				( overlay.loader as DisplayObject ).alpha = overlay.alpha ;
				if ( show ) {
					//( overlay.loader as DisplayObject ).y = overlay.y - ( overlay.loader as DisplayObject ).height/2 ; 
					graphics.beginFill( overlay.color, overlay.alpha ) ;
					graphics.drawCircle( overlay.x, overlay.y, 5 );
					graphics.endFill( );
				}
			}
		}
	}
}