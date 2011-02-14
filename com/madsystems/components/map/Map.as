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
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.Timer;

			
	internal class Map extends Component
	{
		public var paths:Array ;
		public var maps:Array ;
		private var index:int = 0 ;
		//internal var sprite:Sprite ;
		private var zoom:Number ;
		private var scroll:Boolean ;
		private var filter:BlurFilter = new BlurFilter( 12, 12, 1 );
		private var matrix:Matrix = new Matrix( );
			
		//	The target zoom
		private var scale:Number ;
		private var overlays:IOverlays  ;
		private var autoStart:Boolean ;
		private var position:Point = new Point( );
		private var sprites:Array ;
		private var autoStop:Boolean ;
		private var timer:Timer = new Timer( 20 );
		
		internal static const MAP_WINDOW_WIDTH:int = 1920 ;
		internal static const MAP_WINDOW_HEIGHT:int = 1080 ;
		private var MAP_WIDTH:int ;
		private var MAP_HEIGHT:int ;
		
		public function Map( files:Array, maps:Array, width:Number, height:Number, scroll:Boolean = true, overlays:IOverlays = null, autoStart:Boolean = true, autoStop:Boolean = true )
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
			this.autoStop = autoStop ;
			
			//	Listen for state events
			addEventListener( StateEvent.RUN, run ) ;
			addEventListener( StateEvent.NEXT, next );
			
			
			//	Center things if we're not scrolling them
			var x:Number = ( Map.MAP_WINDOW_WIDTH - width )/2 ;
			var y:Number = ( Map.MAP_WINDOW_HEIGHT - height)/2 ;
			
			//trace( "width " + width + " x " + x + " height " + height + " y " + y ) ;
			
			//	The paths will draw on this 
			//	Do we need to add this sprite to the display list
			//	if we're rendering it to a bitmap
			sprites = new Array( );
			var sprite:Sprite ;
//			sprite = addChild( new Sprite( )) as Sprite ;
//			if ( !scroll ) {
//				sprite.x = x ;
//				sprite.y = y ;
//			}
//			sprite.filters = [ filter ] ;
//			sprite.transform.colorTransform = new ColorTransform( 1, 0, 0, .7 );
//			sprites.push( sprite ) ;



			sprite = new Sprite( );
			if ( !scroll ) {
				sprite.x = x ;
				sprite.y = y ;
			}
			sprites.push( addChild( sprite ));
			
			//	Center the maps if we're not scrolling
			for each ( var map:DisplayObject in maps ) {
				map.x = x ; map.y = y ;
			}
			
			//	Add the overlays on top
			if ( overlays is DisplayObject )
				addChild( overlays as DisplayObject );
			
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
			
			//	Listen for the timer
			//timer.addEventListener( TimerEvent.TIMER, frame );
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
							percent: element.percent,
							erase: element.erase,
							id: element.id
						};
						for each ( var path:Array in element.paths ) {
							if ( !path.length )
								continue ;
							array.push( new Path( path, sprites, properties ));
						}
					}
				}
				return array ;
			})( json, [] ) ;
		}


		public function reset( reset:Boolean ):void {
			//if ( reset ) {
				//	Clear the sprite
				for each ( var sprite:Sprite in sprites )
					sprite.graphics.clear();
				
				//	Reset the index	
				index = 0 ;
				
				//	Reset the paths
				(function( paths:Array ):void {
					for each ( var path:* in paths ) {
						if ( path is Array )
							arguments.callee( path as Array );
						else ( path as Path ).reset( ) ;					
					}
				})( this.paths );
				
				
				//visible = true ;
				alpha = 1 ;
			//}
			
		}
		
//		public function predraw( ):void {
//			for each ( var sprite:Sprite in sprites )
//				sprite.graphics.clear();
//			var object:Object ;
//			var j:int= 0 ;
//			while ( j < index ) 
//				draw( 1, paths[ j++ ] );
//			
//		}
//		public function unwind( ):void {
//			
//			//	Reset the paths
//			//	This should be conditional
//			var p:Array = [];
//			p.push
//			(
//				(function ( paths:Array, bin:Array ):Array {
//					while ( paths.length ) {
//						var path:* = paths.pop();
//						if ( path is Array ) {
//							return arguments.callee( path, bin );
//						} else {
//							bin.unshift( path );
//							//( path as Path ).length = 3 ;
//							( path as Path ).erase = true ;
//							( path as Path ).reset() ;
//						}					
//					}
//					return bin ;
//				})( this.paths, [] )
//			)
//			this.paths = p ;
//			index = 0 ;
//		}
		override public function run( event:Event ):void {
			trace("run("+event+")");
			if ( autoStart )
				play( event );
		}
		
		public function play( event:Event = null ):void {
			trace("play("+id+")");
			//timer.start() ;
			start( paths[ index ] );
			if ( overlays && event )
				( overlays as Component ).run( event );	
			if ( !hasEventListener( Event.ENTER_FRAME )) 
				addEventListener( Event.ENTER_FRAME, frame );
		}
		
		
		override public function next( event:Event ):void {
			if ( autoStop ) {
				stop( );	
			}
		}
		
		public function stop( event:Event = null ):void {
			trace("stop("+id+","+autoStop+")");
			if ( overlays && event )
				( overlays as Component ).next( event );	
			if ( hasEventListener( Event.ENTER_FRAME ))
				removeEventListener( Event.ENTER_FRAME, frame );
			//timer.stop( );
		}
		
		private function frame( event:Event ):void {
			if ( marked( paths[ index ])) {
				dispatchEvent( new Event( Event.COMPLETE ));
				removeEventListener( Event.ENTER_FRAME, frame );
				return ;
			}
				
			for each ( var sprite:Sprite in sprites )
				sprite.graphics.clear();
			var object:Object ;
			var j:int= 0 ;
			while ( j < index ) 
				draw( 1, paths[ j++ ] );
				
			//	Draw by arc length
			var point:Point =  arc( paths[ index ] );
			if ( point ) {
				
				
				//	Pan and zoom the map if scrolling is enabled
				if ( scroll ) {
					//	Modify this to get rid of map ripple	
					
					if ( Math.abs( scale - zoom ) < .0001 )
						zoom = scale ;
					else zoom += ( scale - zoom ) * .0625 ;


					//	Scale the point
					point.x *= zoom ; point.y *= zoom ;

					var dx:Number = ( Map.MAP_WINDOW_WIDTH/2 - point.x ) ;
					var dy:Number = ( Map.MAP_WINDOW_HEIGHT/2 - point.y ) ;
	
					//	Tween the map position 
					position.x += ( dx - position.x ) * .125 ;
					position.y += ( dy - position.y ) * .125 ;
					
					//	Keep the map from scrolling off the screen 
					position.x = Math.min( Math.floor( position.x ), 0 ); 
					position.y = Math.min( Math.floor( position.y ), 0 ); 
					position.x = int( Math.max( position.x, Map.MAP_WINDOW_WIDTH - MAP_WIDTH * zoom ));
					position.y = int( Math.max( position.y, Map.MAP_WINDOW_HEIGHT - MAP_HEIGHT * zoom ));
					
					//	Move the sprites
					for each ( sprite in sprites ) {
						sprite.x = position.x ;
						sprite.y = position.y ;
						sprite.scaleX = sprite.scaleY = zoom ;
					}

					//	Move the map
					for each ( var map:DisplayObject in maps ) {
						map.x = position.x ;
						map.y = position.y ;
						map.scaleX = 
						map.scaleY = zoom ;
					}
					//	Draw the overlays
						if ( overlays )
							overlays.overlay( zoom, position ) ;//overlays, point, sprites[ sprites.length - 1] as Sprite ) ;
					}
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
		
		public function fade( alpha:Number, id:String ):void {
			
			var path:Path = ( function ( paths:Array ):Path {
				for each ( var path:* in paths ) {
					if ( path is Array ) 
						return arguments.callee( path ) ;
					if ( path is Path ) {
						if (( path as Path ).id == id )
							return path ;
					}
				}
				return null ;
			})( this.paths );
				
			//	Tween the propeprty	
			var tween:Tween = new Tween( {}, "", None.easeIn, path.alpha, alpha, 1, true ) ;
			var listener:Function = function ( event:TweenEvent ):void {
				path.alpha = tween.position;
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