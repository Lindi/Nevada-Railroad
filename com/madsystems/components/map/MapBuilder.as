package com.madsystems.components.map
{
	import com.madsystems.components.Builder;
	import com.madsystems.components.Component;
	import com.madsystems.components.ComponentFactory;
	
	internal class MapBuilder extends Builder
	{
		private var factory:OverlayFactory = new OverlayFactory( );
		
		override public function create( object:Object ):Object {
			var id:String = ( object.id as String ) ;
			if ( components[ id ] ) 
				return components[ id ] ;
			return null ;
		}
		override public function build( component:XML ):Object {
			
			// 	Return the Bitmap if we've already made it
			var id:String = component.@id.toString();
			if ( components[ id ] ) 
				return components[ id ] ;
				
			//	Are we creating a regular map or mines?
			var type:String = component.@type.toString() ;
			var map:Object ;
							
			if ( type == "mines" ) {
				map = new Mines((( component.overlays as XMLList )[0] as XML ).copy(), component.@reverse.toString( ), component.@autoPlay.toString( ));
			} else {
				//	Create the array of json files to be loaded by the map
				var routes:Array = (function ( list:XMLList, array:Array ):Array {
					for each ( var route:XML in list ) {
						if ( route.children().length()) {
							array.push( arguments.callee( route.children(), [] ));
						} else {
							var url:String = route.@url.toString();
							var color:Number = Number( route.@color.toString() );
							var thickness:Number = Number( route.@thickness.toString() );
							var arclength:Number = Number( route.@arclength.toString() );
							var percent:Number = Number( route.@percent.toString( ));
							var erase:Boolean = ( route.@erase.toString( ) == "true" ? true : false );
							var id:String = route.@id.toString( );
							array.push( { url: url, color: color, thickness: thickness, id: id, arclength: arclength, percent: percent, erase: erase });
						}
					}
					return array ;
				})( component.routes.*, [] ) ;
	
					
				//	Create the map backgrounds
				var maps:Array = new Array( );
				for each ( var graphic:XML in component.background.* ) {
					maps.push( ComponentFactory.create( graphic ));
				}
				
				//	Parse the dimension properties
				var width:Number = Number( component.@width.toString( ));
				var height:Number = Number( component.@height.toString( ));
				var speed:Number = Number( component.@speed.toString( ));
				var scroll:Boolean = ( component.@scroll ? ( component.@scroll.toString( ) == "true" ? true : false ) : false ) ;
				var autoStart:Boolean = ( ( component.attribute("autoStart") as XMLList ).length() ? ( component.@autoStart.toString( ) == "true" ? true : false ) : true ) ;
				var autoStop:Boolean = ( ( component.attribute("autoStop") as XMLList ).length() ? ( component.@autoStop.toString( ) == "false" ? false : true ) : true ) ;


				if (( component.overlays as XMLList ).length()) {
					var overlays:IOverlays = ( factory.create(( component.overlays as XMLList )[0] as XML) as IOverlays );
					map = new Map( routes, maps, width, height, scroll, overlays, autoStart, autoStop );
				} else map = new Map( routes, maps, width, height, scroll, null, autoStart, autoStop );

			}
			( map as Component ).id = component.@id.toString( );
			components[ component.@id ] = map ;
			return map ;
		}
	}
}