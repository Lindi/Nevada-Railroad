package com.madsystems.components.button
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	internal class Button extends Sprite 
	{
		
		public function Button( states:Array )
		{
			
			for each ( var state:Bitmap in states ) {
				addChild( state );
			}		
			
			var listener:Function =
				function ( event:MouseEvent ):void {
					if ( alpha == 1 ) {
						if ( event.type == MouseEvent.MOUSE_DOWN )
							state.alpha = 0 ;
						else if ( event.type == MouseEvent.MOUSE_UP )
							state.alpha = 1 ;
					}
				}
			addEventListener( MouseEvent.MOUSE_DOWN, listener ) ;
			addEventListener( MouseEvent.MOUSE_UP, listener ) ;
		}
	}
}