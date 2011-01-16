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
		private var s:Number ;
		private var index:int  ;
		private var length:Number ;
		public var location:Point ;
		private var thickness:int ;
		private var color:Number ;
		public var rectangle:Rectangle = new Rectangle( );
		
		public function Path( paths:Array, sprite:Sprite, properties:Object )
		{
			this.paths = paths ;
			if ( properties.reverse )
				paths.reverse();
			this.sprite = sprite ;
			this.location = new Point( );
			this.s = s ;
			this.thickness = ( properties.hasOwnProperty( "thickness" ) ? int( properties.thickness ) : 1 ) ;
			this.color = ( properties.hasOwnProperty( "color" ) ? Number( properties.color ) : 0xffffff ) ;
		}
		
		public function drawn( ):Boolean {			
			if ( index >= paths.length )
				return true ;
			++index ;
			return false ;
		}
		
		public function draw( p:Number ):Point {
			var j:int= 0 ;
			while ( j < index )
				mark( paths[ j++ ], 1 );
			var point:Point = mark( paths[ index ], p );
			if ( location ) {
				rectangle.width = Math.abs( point.x - rectangle.x );
				rectangle.height = Math.abs( point.y - rectangle.y );
			} else {
				rectangle.x = point.x ;
				rectangle.y = point.y ;
			}
			location = point ;
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
					return drawLine( path.line, t, g );
				else if ( path.hasOwnProperty("curve"))
					return drawBezier( path.curve, t, g );
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
		private function drawBezier( curve:Array, t:Number, graphics:Graphics ):Point
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
			var q:Point = new Point( b.x + ( c.x - b.x ) * t, b.y + ( c.y - b.y ) * t );
			graphics.lineStyle( thickness, color, 1 );
			graphics.moveTo( a.x, a.y );
			graphics.curveTo( p.x, p.y, q.x, q.y );
			return q ;
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
		private function drawLine( line:Array, t:Number, graphics:Graphics, alpha:Number = 1 ):Point
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