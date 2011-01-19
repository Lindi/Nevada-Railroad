package com.madsystems.components.map
{
	import com.madsystems.components.Builder;
	import com.madsystems.components.ComponentFactory;
	
	import flash.display.Bitmap;
	
	
	internal class MapBuilder extends Builder
	{
		
		override public function create( object:Object ):Object {
			var id:String = ( object.id as String ) ;
			if ( components[ id ] is Map ) 
				return components[ id ] ;
			return null ;
		}
		override public function build( component:XML ):Object {
			
			// 	Return the Bitmap if we've already made it
			var id:String = component.@id.toString();
			var map:Map = ( components[ component.@id ] as Map ) ;
			if ( map ) 
				return map ;
				

			//	Create the array of json files to be loaded by the map
			var routes:Array = (function ( list:XMLList, array:Array ):Array {
				for each ( var route:XML in list ) {
					if ( route.children().length()) {
						array.push( arguments.callee( route.children(), [] ));
					} else {
						var url:String = route.@url.toString();
						var reverse:Boolean = ( route.@reverse.toString() == "true" );
						var color:Number = Number( route.@color.toString() );
						var thickness:Number = Number( route.@thickness.toString() );
						var id:String = route.@id.toString( );
						array.push( { url: url, reverse: reverse, color: color, thickness: thickness, id: id });
					}
				}
				return array ;
			})( component.routes.*, [] ) ;

				
			//	Create the map
			var maps:Array = new Array( );
			for each ( var graphic:XML in component.background.* ) {
				maps.push( ComponentFactory.create( graphic ));
			}
			var width:Number = Number( component.@width.toString( ));
			var height:Number = Number( component.@height.toString( ));
			var speed:Number = Number( component.@speed.toString( ));
			components[ component.@id ] = map = new Map( routes, maps, width, height, speed );
			return map ;
		}
	}
}