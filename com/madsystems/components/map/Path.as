package com.madsystems.components.map
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Path
	{
		private var sprite:Sprite ;
		private var paths:Array ;
		//private var s:Number ;
		private var index:int = 0 ;
		
		//	The length that was drawn on the last curve
		private var length:Number ;
		
		//	The arc length
		private var s:Number ; //1000 ;
		
		
		
		public var location:Point ;
		private var thickness:int ;
		private var color:Number ;
		public var id:String ;
		public var enabled:Boolean = true ;
		public var rectangle:Rectangle = new Rectangle( );
		
		public function Path( paths:Array, sprite:Sprite, properties:Object )
		{
			this.paths = paths ;
			if ( properties.reverse )
				paths.reverse( );
			this.id = properties.id ;
			this.sprite = sprite ;
			this.location = new Point( );
			this.length = this.s = ( properties.arclength? properties.arclength : 5 ) ;
			this.thickness = ( properties.hasOwnProperty( "thickness" ) ? int( properties.thickness ) : 1 ) ;
			this.color = ( properties.hasOwnProperty( "color" ) ? Number( properties.color ) : 0xffffff ) ;
		}
		
		
		private function reverse( paths:Array ):void {
			paths.reverse() ;
			for each ( var path:Object in paths ) {
				if ( path.hasOwnProperty("curve"))
					( path.line as Array ).reverse( );
				else if ( path.hasOwnProperty("line"))
					( path.curve as Array ).reverse( );
			}
		}


		public function drawn( ):Boolean {			
			if ( index >= paths.length )
				return true ;
			++index ;
			return false ;
		}
		
		public function marked( ):Boolean {
			return ( index >= paths.length );
		}
		
		public function arc(  ):Point  
		{	
			//	Draw what's been drawn already
			var j:int= 0 ;
			while ( j < index )
				mark( paths[ j++ ], 1 );
			if ( j < paths.length ) {
				do {
					var ds:Number = Math.min( length, paths[ j ].length );
					var t:Number = ds / paths[ j ].length ;
					location = mark( paths[ j ], t ) ;
					if ( ds == paths[ j ].length ) {
						length -= paths[ j++ ].length ;
					}
				} while ( j < paths.length && length > paths[ j ].length )
			}
			length += s ;
			index = j ;
			return location ;
			
		}
		
		
		public function draw( p:Number ):Point {
			
			var j:int= 0 ;
			while ( j < index )
				mark( paths[ j++ ], 1 );
			location = mark( paths[ index ], p );
			return location ;
		
		}
		/**
		 * mark
		 * 
		 * As in draw.
		 * 
		 * @param - path: an object that describes a line or a curve
		 * @param - t: a parameter between 0 and 1
		 * @param - g: a graphics object reference
		 * 
		 **/ 
		private function mark( path:Object, t:Number, g:Graphics = null ):Point
		{
			if ( path )
			{
				if ( !g ) g = sprite.graphics ;
				if ( path.hasOwnProperty("line"))
					return drawLine( path.line, g, t );
				else if ( path.hasOwnProperty("curve"))
					return drawBezier( path.curve, g, t );
			}
			return location ;
		}
		
		/**
		 * getPosition
		 * 
		 * @returns Returns the current position of the pen.
		 **/ 
		public function getPosition( path:Object ):Point {
			if ( path.hasOwnProperty("line"))
				return ( path.line as Array )[0] as Point;
			else if ( path.hasOwnProperty("curve"))
				return ( path.curve as Array )[0] as Point;
			return null ;
		}
	
		/**
		 * drawBezier
		 * 
		 * @param - curve: an array of three points describing
		 * a quadratic bezier curve
		 * @param - t: a parameter between 0 and 1
		 * @param - graphics: a graphics object reference
		 * 
		 * @returns The current position of the pen on the curve
		 **/ 
		private function drawBezier( curve:Array, graphics:Graphics, t:Number ):Point
		{
			if ( !graphics || !curve )
				return null ;
			if ( isNaN( t ))
				return null ;
			if ( curve.length != 3 )
				return null ;
			var a:Object = curve[ 0] as Object ;
			var b:Object = curve[ 1] as Object ;
			var c:Object = curve[ 2] as Object ;
			var p:Point = new Point( a.x + ( b.x - a.x ) * t, a.y + ( b.y - a.y ) * t );
			var q:Point = new Point( p.x + ( c.x - p.x ) * t, p.y + ( c.y - p.y ) * t );
			graphics.lineStyle( thickness, color, 1 );
			graphics.moveTo( a.x, a.y );
			graphics.curveTo( p.x, p.y, q.x, q.y );
			var r:Point = new Point( );
			r.x = (( 1 - t ) * ( 1 - t ) * a.x ) + ( 2 * ( 1 - t ) * t * b.x ) + ( t * t * c.x );
			r.y = (( 1 - t ) * ( 1 - t ) * a.y ) + ( 2 * ( 1 - t ) * t * b.y ) + ( t * t * c.y );
			return r ;
		}
		
		/**
		 * drawLine
		 * 
		 * @param - line: an array of two points describing the line
		 * @param - t: a parameter between 0 and 1
		 * @param - graphics: a graphics object reference
		 * 
		 * @returns The current position of the pen on the curve
		 **/ 
		private function drawLine( line:Array, graphics:Graphics, t:Number ):Point
		{
			if ( isNaN( t ))
				t = 1 ;
			if ( !graphics || !line )
				return null ;
			if ( isNaN( t ))
				return null ;
			if ( line.length != 2 )
				return null ;
			var a:Object = line[ 0] as Object ;
			var b:Object = line[ 1] as Object ;
			var p:Point = new Point( a.x + ( b.x - a.x ) * t, a.y + ( b.y - a.y ) * t );
			graphics.lineStyle( thickness, color, 1 );
			graphics.moveTo( a.x, a.y );
			graphics.lineTo( p.x, p.y );
			return p ;
		}
	}
}