package com.madsystems.components.map
{
	import com.madsystems.components.ComponentFactory;

	internal class OverlayFactory 
	{
		public function OverlayFactory( ) {}
		
		internal function create( xml:XML ):Object {
			//	Create the map overlays
			var overlays:Array = new Array( );
			switch ( xml.@type.toString( )){
				case "trail":
				for each ( var overlay:XML in xml.* ) 
				{
					//	Copy the attributes	
					var object:Object = new Object( );
					object.x = Number( overlay.@x.toString( ));
					object.y = Number( overlay.@y.toString( ));
					object.color = Number( overlay.@color.toString( ));
					object.zoom = Number( overlay.@zoom.toString( ));
					object.alpha = 0 ;
						
					//	Create the overlay swf	
					var swf:XML = ( overlay.swf as XMLList )[0] as XML ;
					object.loader = ComponentFactory.create( swf );
					
					//	Add the overlay object to the overlay array
					overlays.push( object );
				}
				return new TrailMarkers( overlays );
				default:
					for each ( swf in xml.* ) 
					{
						//	Copy the attributes	
						object = new Object( );
							
						//	Create the overlay swf	
						object.loader = ComponentFactory.create( swf );
						
						//	Add the overlay object to the overlay array
						overlays.push( object );
					}
					return new Overlays( overlays );
			}
		}
	}
}