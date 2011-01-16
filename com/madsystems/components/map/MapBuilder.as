package com.madsystems.components.map
{
	import com.madsystems.components.Builder;
	import com.madsystems.components.ComponentFactory;
	import flash.display.Bitmap;
	import flash.display.DisplayObjectContainer;
	
	
	internal class MapBuilder extends Builder
	{
		private var main:DisplayObjectContainer ;
		
		override public function create( object:Object ):Object {
			var id:String = ( object.id as String ) ;
			if ( components[ id ] is Map ) 
				return components[ id ] ;
			this.main = ( object.container as DisplayObjectContainer ) ;
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
					if ( route.children().length())
						array.push( arguments.callee( route.children(), [] ));
					else {
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
			var image:XML = ( component.image as XMLList )[0] ; 
			var bitmap:Bitmap = ComponentFactory.create( image ) as Bitmap;
			map = new Map( main, routes, bitmap );
			
			//	Return the map 
			return map ;
			//return null;	
		}
	}
}