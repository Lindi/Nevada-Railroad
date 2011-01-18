package com.madsystems.components.map
{
	import com.madsystems.components.Component;
	import com.madsystems.state.event.StateEvent;
	
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import fl.transitions.easing.None;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;;
			
	internal class Map extends Component
	{
		public var paths:Array ;
		private var map:Bitmap ;
		private var index:int = 0 ;
		private var sprite:Sprite = new Sprite() ;
		private var tween:Object = new Object( );
		//private var tiles:Tiles ;
		private var point:Point ;
		//private var w:int ;
		//private var h:int ;
		private var speed:Number ;
		private var zoom:Number ;
		public var scale:Number ;
		private var location:Point ;
		
		internal static const MAP_WINDOW_WIDTH:int = 1920 ;
		internal static const MAP_WINDOW_HEIGHT:int = 1080 ;
		private var MAP_WIDTH:int ;
		private var MAP_HEIGHT:int ;
		
		public function Map( files:Array, map:Bitmap, width:Number, height:Number, speed:Number = .25 )//, url:String, w:int, h:int )
		{
			super( );
			this.map = map ;
			this.speed = speed ;
			this.zoom = 1 ;
			MAP_WIDTH = width ;
			MAP_HEIGHT = height ;			
			this.scale = Math.min( 1, Map.MAP_WINDOW_WIDTH/MAP_WIDTH );
			addEventListener( StateEvent.RUN, run ) ;
			addEventListener( StateEvent.NEXT, next );
			addEventListener( Event.ENTER_FRAME, frame );			


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
			tween.animate = new Tween( {}, "", None.easeNone, 0, 1, speed, true ) ;
			( tween.animate as Tween ).addEventListener( TweenEvent.MOTION_CHANGE, animate );
			( tween.animate as Tween ).addEventListener( TweenEvent.MOTION_FINISH, animate );
			( tween.animate as Tween ).start( );
		}
		override public function run( event:Event ):void {
			
			trace( parent );
			trace( "run("+event+")" );
			if ( !contains( map ))
				addChildAt( map, 0 );
			if ( !contains( sprite ))
				addChild( sprite );
			//	Add the map and sprite to the display list
			//	Note that the map should be separate from this
			//	so that we can dim a path
			//	Start the tween
			//	if ( tween )
				//	tween.start( );
				//setZoom( scale );
		}
		
		override public function next( event:Event ):void {
			//	Stop the tween
			//tween.stop( ) ;
		}
		
		
		private function animate( event:TweenEvent ):void 
		{	
			sprite.graphics.clear( );
			
			var t:Number = ( ( tween.animate as Tween ).time / ( tween.animate as Tween ).duration );
			var object:Object ;
			
			//	Draw the paths that are already done
			var j:int= 0 ;
			while ( j < index ) 
				draw( 1, paths[ j++ ] ); 
			
		
			if ( event.type == TweenEvent.MOTION_FINISH ) {
				( tween.animate as Tween ).stop( ); ( tween.animate as Tween ).rewind( ); 
				if ( !drawn( paths[ index ] ))
					( tween.animate as Tween ).start( );
			}
			
			
			location =  draw( t, paths[ index ] );
		}	
		
		private function frame( event:Event ):void {
//			if ( Math.abs( scale - zoom ) > .005 )
				//this.zoom += ( this.scale - this.zoom ) * .325 ;
//			else zoom = scale ;
			//trace( "animate("+zoom+")");			
			//trace( "frame("+this.zoom+")");			
			//trace( "foo("+this.foo+")");
			//trace( "zoom("+this.zoom+")");			
			trace( "scale("+( this.scale == 2 )+")");	
			return ;		
			//trace( "("+this+")");			

			if ( location ) {
				var point:Point = location ;
				
				//	Scale the sprite and the map
				sprite.scaleX = sprite.scaleY = zoom ;
				map.scaleX = map.scaleY = zoom ;
				
				//	Calculate the map offset
				var dx:Number = ( Map.MAP_WINDOW_WIDTH/2 - point.x ) * zoom ;
				var dy:Number = ( Map.MAP_WINDOW_HEIGHT/2 - point.y ) * zoom ;

				//	Tween the map position 
				sprite.x += ( dx - sprite.x ) * .125 ;
				sprite.y += ( dy - sprite.y ) * .125 ;
				
				//	Keep the map from scrolling off the screen 
				sprite.x = ( Math.min( Math.max( Math.floor( sprite.x ), Map.MAP_WINDOW_WIDTH - MAP_WIDTH ), 0 )) ;
				sprite.y = ( Math.min( Math.max( Math.floor( sprite.y ), Map.MAP_WINDOW_HEIGHT - MAP_HEIGHT ), 0 )) ;

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
		
		public function setZoom( scale:Number ):void {
			this.scale = scale ;
//			this.scale = scale ;
//			trace("setZoom("+this.scale+")");
//			trace("setZoom("+this.zoom+")");
//			return ;
//			this.foo = 2 ;//scale ;
//			this.boo = 2 ;
//			return ;
//			//return ;
//			//this.scale = scale ;
//			if ( !tween.zoom ) {
//				tween.zoom = new Tween( {}, "", None.easeNone, zoom, scale, .25, true ) ;
//				( tween.zoom as Tween ).addEventListener( TweenEvent.MOTION_CHANGE, change );
//				( tween.zoom as Tween ).addEventListener( TweenEvent.MOTION_FINISH, change );
//			}
//			( tween.zoom as Tween ).stop( );
//			( tween.zoom as Tween ).rewind( );
//			( tween.zoom as Tween ).begin = zoom ;
//			( tween.zoom as Tween ).finish = scale ;
//			( tween.zoom as Tween ).start( );
		}
		
		private function change( event:TweenEvent ):void {
			zoom = ( event.target as Tween ).position ;
			trace( zoom )
		}
		public function track( id:String, enabled:Boolean ):void {
			trace("track("+id+","+enabled+")");
			//return ;
			var path:Path = ( function ( array:Array ):Path {
				var path:Path ;
				for ( var i:int = 0; i < array.length; i++ ) {
					var object:Object = array[ i];
					if ( object is Array ) {
						path = arguments.callee( object );
					} else if ( object is Path ) {
						if (( object as Path ).id == id )
							path = ( object as Path );
					}
				}
				return path ;
			})( this.paths ) ;
			
			if ( path )
				path.enabled = enabled ;
		}
		
		private function draw( t:Number, object:* ):Point {
			var point:Point ;
			if ( object is Array ) {
				for ( var i:int = 0; i < object.length; i++ ) {
					var path:Path = ( object[ i ] as Path );
					if ( !path.enabled ) continue ;
					var p:Point = ( path.draw( t ) as Point ).clone();
					if ( point ) {
						//if ( path.enabled ) {
							point.x += ( p.x - point.x )/2 ;
							point.y += ( p.y - point.y )/2 ; // = point.add( matrix.transformPoint( p.subtract( point )));
						//}
					} else {
						point = p ;	
						//trace( "[ "+i+" ] " + point ) ;
					}
				}
			} else if ( object is Path ) {
				point = (( object as Path ).draw( t ) as Point ).clone();
			}
			return point ;
		}	
	}
}