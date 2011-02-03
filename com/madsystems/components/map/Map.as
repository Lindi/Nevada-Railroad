package com.madsystems.components.map
{
	import com.madsystems.components.Component;
	import com.madsystems.state.event.StateEvent;
	
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import fl.transitions.easing.None;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
			
	internal class Map extends Component
	{
		public var paths:Array ;
		public var maps:Array ;
		private var index:int = 0 ;
		internal var sprite:Sprite ;
		private var zoom:Number ;
		private var scroll:Boolean ;

		//	The target zoom
		private var scale:Number ;
		private var overlays:Array ;
		private var autoStart:Boolean ;
		
		internal static const MAP_WINDOW_WIDTH:int = 1920 ;
		internal static const MAP_WINDOW_HEIGHT:int = 1080 ;
		private var MAP_WIDTH:int ;
		private var MAP_HEIGHT:int ;
		
		public function Map( files:Array, maps:Array, width:Number, height:Number, scroll:Boolean = true, overlays:Array = null, autoStart:Boolean = true )
		{
			super( );
			MAP_WIDTH = width ;
			MAP_HEIGHT = height ;			
			this.scale = Math.min( 1, Map.MAP_WINDOW_WIDTH/MAP_WIDTH );
			this.maps = maps ;
			this.zoom = 1 ;
			this.overlays = overlays ;
			this.scroll = scroll ;
			this.autoStart = autoStart ;
			
			//	Listen for state events
			addEventListener( StateEvent.RUN, run ) ;
			addEventListener( StateEvent.NEXT, next );
			
			//	The paths will draw on this 
			sprite = addChild( new Sprite( )) as Sprite ;

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
						file.paths = loader.load( file.url as String );
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
							arclength: element.arclength,
							id: element.id
						};
						for each ( var path:Array in element.paths ) 
							array.push( new Path( path, sprite, properties ));
					}
				}
				return array ;
			})( json, [] ) ;
		}


		public function reset( reset:Boolean ):void {
			if ( reset ) {
				//	Reset the index	
				index = 0 ;
				
				//	Reset the paths
				//	This should be conditional
				(function ( paths:Array ):void {
					for each ( var path:* in paths ) {
						if ( path is Array )
							arguments.callee( path );
						else ( path as Path ).reset() ;					
					}
				})( paths );
				
				//	Reset the alpha for maps which we've faded
				alpha = 1 ;
			}
			
		}
		
		override public function run( event:Event ):void {
			trace("run("+event+")");
			if ( autoStart )
				play( );
		}
		
		public function play( ):void {
			if ( !hasEventListener( Event.ENTER_FRAME ))
				addEventListener( Event.ENTER_FRAME, frame );
			//	Start the map
			start( paths[ index ] );	
		}
		
		
		override public function next( event:Event ):void {
			removeEventListener( Event.ENTER_FRAME, frame );
		}
		
		private function frame( event:Event ):void {
			if ( marked( paths[ index ])) {
				dispatchEvent( new Event( Event.COMPLETE ));
				return ;
			}
				
			sprite.graphics.clear( );
			var object:Object ;
			var j:int= 0 ;
			while ( j < index ) 
				draw( 1, paths[ j++ ] );
				
			//	Draw by arc length
			var point:Point =  arc( paths[ index ] );
			
			if ( !scroll )
				return ;
				
			zoom += ( scale - zoom ) * .0625 ;
			if ( point ) {
				
				//	Draw the overlays
				if ( overlays )
					overlay( overlays, point ) ;
				
				//	Scale the point
				point.x *= zoom ; point.y *= zoom ;
				
				//	Scale the sprite and the map
				sprite.scaleX = sprite.scaleY = zoom ;
				
				//	Scale the maps
				for each ( var map:DisplayObject in maps ) {
					if ( map is Map ) {
						( map as Map ).sprite.scaleX = zoom ;
						( map as Map ).sprite.scaleY = zoom ;
					} else {
						map.scaleX = map.scaleY = zoom ;
					}
				}
				
				//	Calculate the map offset
				var dx:Number = ( Map.MAP_WINDOW_WIDTH/2 - point.x ) ;
				var dy:Number = ( Map.MAP_WINDOW_HEIGHT/2 - point.y ) ;

				//	Tween the map position 
				sprite.x += ( dx - sprite.x ) * .125 ;
				sprite.y += ( dy - sprite.y ) * .125 ;
				
				//	Keep the map from scrolling off the screen 
				sprite.x = Math.min( Math.floor( sprite.x ), 0 ); 
				sprite.y = Math.min( Math.floor( sprite.y ), 0 ); 
				sprite.x = Math.max( sprite.x, Map.MAP_WINDOW_WIDTH - MAP_WIDTH * zoom );
				sprite.y = Math.max( sprite.y, Map.MAP_WINDOW_HEIGHT - MAP_HEIGHT * zoom );
				
				for each ( map in maps ) {
					if ( map is Map ) {
						( map as Map ).sprite.x = sprite.x ;
						( map as Map ).sprite.y = sprite.y ;
					} else {
						map.x = sprite.x ;
						map.y = sprite.y ;
					}
				}
			}
		}
		private function overlay( overlays:Array, location:Point ):void {
			//	Kill the line style
			sprite.graphics.lineStyle( );
			
			//	Go through each overlay
			//	If the current zoom is greater than 
			//	or equal to the current zoom threshold
			//	and the current location is close enough
			//	the location point, display it
			//	Hide each currently visible overlay
			//	that doesn't meet those conditions
			for ( var i:int = 0; i < overlays.length; i++ ) {
				var overlay:Object = overlays[ i];
				var x0:Number = overlay.x - overlays[0].x ;
				var y0:Number = overlay.y - overlays[0].y ;
				var dx:Number = location.x - overlays[0].x ;
				var dy:Number = location.y - overlays[0].y ;
				var show:Boolean = ( zoom >= overlay.zoom ) ;
				show = show &&  (( dx * dx + dy * dy ) > ( x0 * x0 + y0 * y0 )); 
				overlay.alpha += ( Number( show ) - overlay.alpha ) * .5 ;
				( overlay.image.bitmap as DisplayObject ).alpha = overlay.alpha ;
				( overlay.image.bitmap as DisplayObject ).x = overlay.image.x ; // * zoom ;
				( overlay.image.bitmap as DisplayObject ).y = overlay.y - ( overlay.image.bitmap as DisplayObject ).height/2 ; //overlay.image.y ; // * zoom ;
				sprite.graphics.beginFill( overlay.color, overlay.alpha ) ;
				sprite.graphics.drawCircle( overlay.x, overlay.y, 5 );
				sprite.graphics.endFill( );
				if ( show && !sprite.contains( overlay.image.bitmap as DisplayObject ))
					sprite.addChild( overlay.image.bitmap as DisplayObject );
				else if ( !show && sprite.contains( overlay.image.bitmap as DisplayObject ))
					sprite.removeChild( overlay.image.bitmap  as DisplayObject );
			}
		}
		
		private function arc( object:* ):Point {
			var point:Point ;
			if ( object is Array ) {
				for ( var i:int = 0; i < object.length; i++ ) {
					var path:Path = ( object[ i ] as Path );
					var p:Point = ( path.arc(  ) as Point ).clone();
					if ( !path.enabled ) 
						continue ;
					if ( point ) {
						point.x += ( p.x - point.x )/2 ;
						point.y += ( p.y - point.y )/2 ; 
					} else {
						point = p ;	
					}
				}
			} else if ( object is Path ) {
				point = (( object as Path ).arc(  ) as Point ).clone();
			}
			return point ;
		}

		private function marked( object:* ):Boolean {
			var marked:Boolean = true ;
			if ( object is Array ) {
				for ( var i:int = 0; i < object.length; i++ ) {
					var path:Path = ( object[ i ] as Path );
					marked = ( path.marked( ) && marked ) ;
				}
			} else if ( object is Path ) {
				marked = ( object as Path ).marked( );
			}
			if ( !marked )
				return false ;
			if ( ++index < paths.length ) {
				start( paths[ index ] );
				return false ;
			}
			return true ;
			
		}
		
		private function start( object:* ):void {
			if ( object is Array ) {
				var type:String  ;
				for ( var i:int = 0; i < object.length; i++ ) {
					var event:String = "route-start-" + ( object[i] as Path ).id ;
					if ( event != type ) {
						dispatchEvent( new Event( event ));
						type = event ;
					}
				}
			} else if ( object is Path ) {
				event = "route-start-" + ( object as Path ).id ;
				if ( event != type ) {
					dispatchEvent( new Event( event ));
					type = event ;
				}
			}			
		}
		
		public function fade( alpha:Number ):void {
			var map:DisplayObject = this ;
			var tween:Tween = new Tween( {}, "", None.easeIn, map.alpha, alpha, 1, true ) ;
			var listener:Function = function ( event:TweenEvent ):void {
				map.alpha = tween.position;
				if ( event.type == TweenEvent.MOTION_FINISH ) {
					( event.target as Tween ).removeEventListener
						( TweenEvent.MOTION_CHANGE, arguments.callee );
					( event.target as Tween ).removeEventListener
						( TweenEvent.MOTION_FINISH, arguments.callee );
					tween.stop( );
				}
			}
			tween.addEventListener( TweenEvent.MOTION_CHANGE, listener ) ;
			tween.addEventListener( TweenEvent.MOTION_FINISH, listener ) ;
			tween.start();			
		}

		private function drawn( object:* ):Boolean {
			var drawn:Boolean = true ;
			if ( object is Array ) {
				for ( var i:int = 0; i < object.length; i++ ) {
					var path:Path = ( object[ i ] as Path );
					drawn = ( path.drawn( ) && drawn ) ;
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
			trace("setZoom("+scale+")");
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
					var p:Point = ( path.draw( t ) as Point ).clone();
					if ( !path.enabled ) 
						continue ;
					if ( point ) {
						point.x += ( p.x - point.x )/2 ;
						point.y += ( p.y - point.y )/2 ; 
					} else {
						point = p ;	
					}
				}
			} else if ( object is Path ) {
				point = (( object as Path ).draw( t ) as Point ).clone();
			}
			return point ;
		}	
	}
}