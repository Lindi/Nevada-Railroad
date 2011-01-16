package com.madsystems.components.map
{
	import com.madsystems.components.Component;
	import com.madsystems.state.event.StateEvent;
	
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import fl.transitions.easing.None;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.geom.Rectangle;;
			
	internal class Map extends Component
	{
		public var paths:Array ;
		internal var map:Bitmap ;
		private var index:int = 0 ;
		private var sprite:Sprite = new Sprite() ;
		private var tween:Tween ;
		private var tiles:Tiles ;
		private var point:Point ;
		private var w:int ;
		private var h:int ;
		private var speed:Number ;
		private var zoom:Number ;
				
		internal static const MAP_WINDOW_WIDTH:int = 1920 ;
		internal static const MAP_WINDOW_HEIGHT:int = 1080 ;
		
		public function Map( main:DisplayObjectContainer, files:Array, map:Bitmap, speed:Number = .0625 )//, url:String, w:int, h:int )
		{
			super( main );
			//	tiles = main.addChild( new Tiles( url )) as Tiles ;
			show( this );	
			addChild( map ) ;
			addChild( sprite );
			this.map = map ;
			this.speed = speed ;
			this.zoom = 1 ;
//			this.w = w ;
//			this.h = h ;
			
			
			
			//	Keep track of the number of loaders
			var loaders:int ;
			
			//	Keep track of the loaded json
			var json:Array = new Array( );
			
			//	Create a listener that decrements the counter
			//	when each loader has completed work
			var listener:Function =
				function ( event:Event ):void {
					( event.target as EventDispatcher )
						.removeEventListener( event.type, arguments.callee );
					if (!( --loaders )) {
						init( json );
					}
				}
				
			//	Load the JSON paths
			//	What happens to the memory here?
			//	We're creating an "anonymous" loader
			json = ( function ( files:Array, array:Array ):Array {
				for each ( var file:* in files ) {
					 
				 	if ( file is Array ) {
				 		array.push( arguments.callee( file, [] ));
				 	} else {
						var loader:JsonLoader = ( new JsonLoader());
						loader.addEventListener( Event.COMPLETE, listener );
						++loaders ;
						file.paths = loader.load( file.url as String, file.reverse );
				 		array.push( file );
				 	}
				}
		 		return array ; 
			})( files, [] );			
		}
		
		private function init( json:Array ):void {
			
			this.paths = ( function ( elements:Array, array:Array ):Array {
				for each ( var element:* in elements ) {
					if ( element is Array )
						array.push( arguments.callee( element, [] ));
					else {
						
						var properties:Object =
						{
							url: element.url,
							reverse: element.reverse,
							color: element.color,
							thickness: element.thickness,
							id: element.id
						};
						for each ( var path:Array in element.paths ) 
							array.push( new Path( path, sprite, properties ));
					}
				}
				return array ;
			})( json, [] ) ;
			
			//	Create the tween
			tween = new Tween( {}, "", None.easeNone, 0, 1, speed, true ) ;
			tween.addEventListener( TweenEvent.MOTION_CHANGE, animate );
			tween.addEventListener( TweenEvent.MOTION_FINISH, animate );
			tween.start( );
		}
		override protected function run( event:StateEvent ):void {
			//	Start the tween
			tween.start( );
			
		}
		
		override protected function next( event:StateEvent ):void {
			//	Stop the tween
			tween.stop( ) ;
		}
		
		
		private function animate( event:TweenEvent ):void 
		{	
			sprite.graphics.clear( );
			
			var t:Number = ( tween.time / tween.duration );
			var object:Object ;
			var j:int= 0 ;
			while ( j < index ) 
				draw( 1, paths[ j++ ] ); 
			
		
			if ( event.type == TweenEvent.MOTION_FINISH ) {
				tween.stop( ); tween.rewind( ); 
				if ( !drawn( paths[ index ] ))
					tween.start( );
			}
			var o:Object = draw( t, paths[ index ] );
			var point:Point = o.point ;
			if ( point ) {
				zoom += ( o.zoom - zoom ) * .125 ;
				//zoom = Math.min( 1, zoom ) ;
				
				//	Scale the sprite and the map
				sprite.scaleX = sprite.scaleY = zoom ;
				map.scaleX = map.scaleY = zoom ;
				
				//	Calculate the map offset
				var dx:Number = ( Map.MAP_WINDOW_WIDTH/2 - point.x ) * zoom ;
				var dy:Number = ( Map.MAP_WINDOW_HEIGHT/2 - point.y ) * zoom ;

				//	Tween the map position 
				sprite.x += ( dx - sprite.x ) * .125;
				sprite.y +=  ( dy - sprite.y ) * .125 ;
				
				//	Keep the map from scrolling off the screen 
				sprite.x = Math.min( Math.max( Math.floor( sprite.x ), Map.MAP_WINDOW_WIDTH - map.width ), 0 ) ;
				sprite.y = Math.min( Math.max( Math.floor( sprite.y ), Map.MAP_WINDOW_HEIGHT - map.height ), 0 ) ;

				//	tiles.render( new Point( sprite.x, sprite.y ));
				map.x = sprite.x ;
				map.y = sprite.y ;
			}
		}	
		
		private function drawn( object:* ):Boolean {
			var drawn:Boolean = true ;
			if ( object is Array ) {
				for ( var i:int = 0; i < object.length; i++ ) {
					var path:Path = ( object[ i ] as Path );
					drawn = ( path.drawn() && drawn ) ;
				}
			} else if ( object is Path ) {
				drawn = ( object as Path ).drawn( );
			}
			if ( drawn )
				return ( ++index >= paths.length ) ;
			return false ;
		}
		
		
		private function draw( t:Number, object:* ):Object {
			var point:Point ;
			var zoom:Number = 1;
			var matrix:Matrix = new Matrix( .5,0,0,.5 ); 
			if ( object is Array ) {
				var rectangle:Rectangle = new Rectangle( );
				for ( var i:int = 0; i < object.length; i++ ) {
					var path:Path = ( object[ i ] as Path );
					rectangle = rectangle.union( path.rectangle );
					var p:Point = path.draw( t );
					if ( point )
						point = point.add( matrix.transformPoint( p.subtract( point )));
					else point = p ;
				}
				var w:Number = Math.max( rectangle.width, Map.MAP_WINDOW_WIDTH ) ;// Math.max( rectangle.width, Map.MAP_WINDOW_WIDTH );
				var h:Number = Math.max( rectangle.height, Map.MAP_WINDOW_HEIGHT );
				zoom = Math.min( 1, Math.min( Map.MAP_WINDOW_WIDTH/ w, Map.MAP_WINDOW_HEIGHT/ h ));
				//return point ;
			} else if ( object is Path ) {
				point = ( object as Path ).draw( t );
			}
			if ( point ) {
				point.x *= zoom ;
				point.y *= zoom ;
			}
			return { point: point, zoom: zoom } ;
		}	
	}
}