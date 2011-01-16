package com.madsystems.components.map
{
	
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.EventDispatcher ;


	public class SvgParser extends EventDispatcher
	{
		public var marks:Array = [] ;
		public var url:String ;
	
		public function SvgParser( url:String )
		{
			super( );
			this.url = url;
		}
		/**
		 * load
		 * 
		 * Load the route data and parse it when
		 * it's done loading
		 **/ 
		public function load( ):void {
			
			//	Load the svg file
			var loader:URLLoader = new URLLoader();
			loader.addEventListener( Event.COMPLETE,
				function ( event:Event ):void
				{  
					//	Build the paths
					var xml:XML = new XML(loader.data);
					build( xml );
					loader.removeEventListener( Event.COMPLETE, arguments.callee );
				});
				
			//	Silently handle errant files
			loader.addEventListener( IOErrorEvent.IO_ERROR,
				function ( event:IOErrorEvent ):void {
					( event.target as URLLoader ).removeEventListener
						( IOErrorEvent.IO_ERROR, arguments.callee );
				});
				
				
			try {
				loader.load(new URLRequest(url));
			} catch (error:Error) {
				trace("Unable to load requested document.");
			}
		}
		

		/**
		 * build
		 * 
		 * @param	the xml tree that represents the route data
		 * as loaded from the xml file.
		 **/ 
		public function build( xml:XML ):void 
		{			
			(function ( list:XMLList ):void
			{
				for each ( var node:XML in list )
				{
					if ( node.children().length())
						arguments.callee( node.children());
					else {
						var path:Array = parse( node );
						if ( path ) marks.push( path );
					}
				}
			})( xml.children() );
			
			dispatchEvent( new Event( Event.COMPLETE ));			

		}

		
		



		

		private function parse( node:XML ):Array
		{
			if( node.nodeKind() == "text" )
				return null ;
			if ( !node )
				return null ;
			switch ( node.name().localName )
			{
				case "line":
					return line( node );
				case "polyline":
				case "polygon":
					return polyline( node );
				case "path":
					return path( node );
			}
			return null ;
		}
		private function line( xml:XML ):Array
		{
			var line:Array = new Array( );
			var x1:Number = Number( xml.@x1 );
			var x2:Number = Number( xml.@x2 );
			var y1:Number = Number( xml.@y1 );
			var y2:Number = Number( xml.@y2 );
			return [{ line: [ new Point( x1, y1), new Point( x2, y2 )] }];
		}
		private function polyline( xml:XML ):Array
		{
			var args:String = xml.@points ;
			var points:Array = [] ;
			var mark:Array = [] ;
			for ( var j:int = 0; ( j = args.substr( 1 ).search( /[^\d\.]/ ))  != -1; )
			{
				var p:Point  = new Point( );
				p.x = Number( clean( args.substr( 0, j + 1 ))); 
				args = args.substr( j+1 );
				j = args.substr( 1 ).search( /[^\d\.]/ ) ;
				p.y = Number( clean( args.substr( 0, ( j != -1 ? j + 1 : args.length )))); 
				args = args.substr( j+1 );
				points.push( p );
				
				if ( points.length > 3 )
				{
					var line:Array = [] ;
					while ( points.length )
						line.push( points.pop());
					mark.push( {line: line} );
				}
			}
			return mark ;
		}
		private function clean( n:String ):String
		{
			while( n.substr( 0, 1 ).search(/[^\d\.\-]/) != -1 )
				n = n.substr( 1 );
			return n ;
		}

		private function path( xml:XML ):Array
		{
			if ( !xml )
				return null ;
			var points:Array = [] ;
			var marks:Array = [] ;
			var path:String = xml.@d ; 
			var i:int ;
			var p:Point ;
			var q:Point ;
			var x:String ;
			var y:String ;

			while ( path.length && ( i = path.search( /[MmLlCcSszVvHh]/ )) != -1 )
			{	
				var cmd:String = path.substr( i, 1 );
				path = path.substr( i+1 );
				i = path.search( /[MmLlCcSszVvHh]/ );
				var args:String = path.substr( 0, i );
				path = path.substr( i );
				
				var j:int ;
				var curve:Array = [] ;
				switch ( cmd ) {
					case "M":
					case "m":
						if ( cmd == "m" && points.length )
							p = ( points[ 0 ] as Point ).clone( );
						else p = new Point( );
						while ( points.length )
							delete points.pop();

						j = args.substr( 1 ).search( /[^\d\.]/ );
						x = clean( args.substr( 0, j+1 ));
						y = clean( args.substr( j+1 ));
						p.x+= Number( x );
						p.y+= Number( y ) ;
						points.unshift( p );
						break ;
					case "L":
					case "l":
						if ( cmd == "l" && points.length )
							p = ( points[ 0 ] as Point ).clone( );
						else p = new Point( );
						j = args.substr( 1 ).search( /[^\d\.]/ );
						x = clean( args.substr( 0, j+1 )) ;
						p.x+= Number( x );
						y = clean( args.substr( j+1 )) ;
						p.y+= Number( y );
						marks.push( { line: [ ( points[ 0 ] as Point ).clone( ), p ] });
						points.unshift( p );
						break ;
					case "H":
					case "h":
						p = ( points[ 0 ] as Point ).clone( );
						x = clean( args );
						if ( cmd == "h" && points.length )
							p.x+= Number( x );
						else p.x = Number( x );
						marks.push( { line: [ ( points[ 0 ] as Point ).clone( ), p ] });
						points.unshift( p );
						break ;
					case "V":
					case "v":
						p = ( points[ 0 ] as Point ).clone( );
						y = clean( args );
						if ( cmd == "v" && points.length )
							p.y+= Number( y );
						else p.y = Number( y );
						marks.push( { line: [ ( points[ 0 ] as Point ).clone( ), p ] });
						points.unshift( p );	
						break ;
					case "T":
					case "t":
					case "S":
					case "s":
						//	reflect the last curve's control point around
						//	the last curve's last anchor point
					if ( points.length )
							p = ( points[ 0 ] as Point );//.clone(); 
						else p = new Point( );
						q = p ;
						if ( points.length > 1 )
							q = ( points[ 1 ] as Point );//.clone();
						points.unshift( new Point( p.x + ( p.x - q.x ), p.y + ( p.y - q.y )));
					case "Q":
					case "q":
					case "C":
					case "c":
						//	Curve points are resolved relative to the first anchor point
						//	If the command is a reflection command, the anchor point is the
						//	second item in the list, otherwise it's the last pen position
						if ( cmd == "s" || cmd == "S" || cmd == "t" || cmd == "T" )
							q = ( points[ 1 ] as Point );
						else q = ( points[ 0 ] as Point );
						
						//	Go through each number in the command
						for ( j = 0; ( j = args.substr( 1 ).search( /[^\d\.]/ ))  != -1; )
						{
							p = new Point( );
							x = args.substr( 0, j + 1 );
							if (( cmd == "q" || cmd == "c" || cmd == "s" || cmd == "t" ) && points.length )
								p.x = q.x +  Number( clean( x ));
							else p.x = Number( clean( x ));
							args = args.substr( j+1 );
							j = args.substr( 1 ).search( /[^\d\.]/ ) ;
							y = args.substr( 0, ( j != -1 ? j + 1 : args.length )) ; 
							if (( cmd == "q" || cmd == "c" || cmd == "s" || cmd == "t" ) && points.length )
								p.y = q.y  + Number( clean( y ));
							else p.y = Number( clean( y ));
							args = args.substr( j+1 );
							points.unshift( p );
						}

						//	Empty the stack into the new curve
						while ( curve.length )
							delete curve.pop();
						j = points.length ;
						
						//continue ;
						var n:int = ( j - ( 3 + int( cmd == "c" || cmd == "C" || cmd == "s" || cmd == "S" )));
						while ( points.length > n )
							curve.unshift( points.shift());
						//trace( 'curve ' + curve );
						var quadratics:Array = reduce.apply( null, curve );
						while ( quadratics.length )
							marks.push( { curve: quadratics.shift( )});

//							drawing.curve.push( quadratics.shift());
						points.unshift(( curve[ curve.length-2 ] as Point ).clone( ));
						points.unshift(( curve[ curve.length-1 ] as Point ).clone( ));
						break ;
				}
			}
			//	Clean the points array
			while ( points.length )
				delete points.pop();
			return marks ;
		}
		
		internal static function intersect( p1:Point, p2:Point, p3:Point, p4:Point ):Point 
		{
			var dx1:Number = p1.x - p2.x ; 	
			var dx2:Number = p3.x - p4.x ;
			var dy1:Number = p1.y - p2.y ;
			var dy2:Number = p3.y - p4.y ;
			var px1:Boolean = Math.abs( dx1 ) < .0001 ;
			var px2:Boolean = Math.abs( dx2 ) < .0001 ;
			var py1:Boolean = Math.abs( dy1 ) < .01 ;
			var py2:Boolean = Math.abs( dy2 ) < .01 ;
			if ( px1 && px2 || py1 && py2 )
				return new Point(( p1.x + p2.x + p3.x + p4.x )/ 4, ( p1.y + p2.y + p3.y + p4.y )/ 4);
				
			//	Calculate the intersection using determinants
			//	http://en.wikipedia.org/wiki/Line-line_intersection
			var a:Number = ( p1.x * p2.y - p2.x * p1.y );
			var b:Number = ( p3.x * p4.y - p4.x * p3.y ) ;
			var d:Number = ( dx1 * dy2 - dy1 * dx2 ) ;
			var x:Number = ( a * dx2 - b * dx1 ) / d ;
			var y:Number = ( a * dy2 - b * dy1 ) / d ;
			return new Point( x, y );
		}
	
		internal static function midpoint(a:Point, b:Point):Point
		{
			return new Point( (a.x + b.x)/2, (a.y + b.y)/2 );
		}
		
		internal static function split(p0:Point, p1:Point, p2:Point, p3:Point):Object
		{
			var p01:Point = midpoint(p0, p1);
			var p12:Point = midpoint(p1, p2);
			var p23:Point = midpoint(p2, p3);
			var p02:Point = midpoint(p01, p12);
			var p13:Point = midpoint(p12, p23);
			var p03:Point = midpoint(p02, p13);
			return { left: [p0,  p01, p02, p03],
				right:[p03, p13, p23, p3] };
		}
	
	
		internal static function reduce( a:Point, b:Point, c:Point, d:Point ):Array 
		{
			var curves:Array = [[a,b,c,d]] ;
			var k:int = 1 ;
			var i:int = 0 ;
			while ( i < curves.length )
			{
				
				var curve:Array = curves[ i];
				var p:Point = intersect.apply( null, curve );
				var dx:Number ;
				var dy:Number ;
				if ( p )
				{
					a = curve[ 0] as Point ;
					b = curve[ 1] as Point ;
					c = curve[ 2] as Point ;
					d = curve[ 3] as Point ;
					
					// find distance between the midpoints
					dx = (a.x + d.x + p.x * 4 - (b.x + c.x) * 3) * .125;
					dy = (a.y + d.y + p.y * 4 - (b.y + c.y) * 3) * .125;
					var dd:Number = dx*dx + dy*dy ;
					if ( dd < k ) {
						curves.splice( i, 1 );
						curves.splice( i++, 0, [a, p, d] );
						continue ;
					}
				}
				// Subdivide curve
				var cubic:Object = split(a, b, c, d);
				curves.splice( i, 1 );
				curves.splice( i, 0, cubic.left );
				curves.splice( i+1, 0, cubic.right );
			}
			return curves ;
		}
	
	}
}





