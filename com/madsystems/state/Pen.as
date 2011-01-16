package com.madsystems.components.map
{
	import flash.display.Sprite;
	import fl.transitions.Tween ;
	import fl.transitions.TweenEvent ;
	import fl.transitions.easing.* ;
	import flash.display.Graphics ;
	import flash.geom.Point ;
	import flash.events.Event ;

	internal class Pen extends Sprite
	{
		private var marks:Array ;
		private var tween:Tween ;
		public var location:Point ;
		private var i:int ;
		
	
		/**
		 * sketch
		 * 
		 * Start asynchronous sketching with the tween instance
		 * 
		 * @returns - a reference to the Pen instance
		 **/ 
		public function sketch( marks:Array ):void
		{
			if ( !this.marks )
				this.marks = marks ;
			i = 0 ;
			if ( !tween )  {
				
				//	Note, the interval should probably be passed in as a
				//	constructor parameter.  That way, we can have faster 
				//	and slower drawing pens
				tween = new Tween( {}, "", None.easeNone, 0, 1, .0625, true ) ;
				tween.addEventListener( TweenEvent.MOTION_CHANGE, animate );
				tween.addEventListener( TweenEvent.MOTION_FINISH, animate );
			}
			tween.stop( );
			tween.rewind( );
			tween.start( );
		}
		
		/**
		 * draw
		 * 
		 * Start synchronoous sketching 
		 * 
		 **/ 
		public function draw( marks:Array, g:Graphics = null ):void {
			var j:int= 0 ;
			while ( j < marks.length )
				this.location = mark( marks[ j++], 1, g );		
		}
		
		/**
		 * animate
		 * 
		 * Tween instance callback
		 * 
		 **/ 
		private function animate( event:TweenEvent ):void
		{
			graphics.clear( );
			stage.invalidate();
			var t:Number = ( tween.time / tween.duration );
			var j:int= 0 ;
			while ( j < i )
				mark( this.marks[ j++ ], 1 );
			if ( i < this.marks.length )
			{
				if ( event.type == TweenEvent.MOTION_FINISH )
				{
					mark( this.marks[ i ], 1 );
					tween.stop( );
					if ( ++i < this.marks.length  )
					{
						tween.rewind( );
						tween.start( );
					} else {
						
						dispatchEvent( new Event( RouteEvent.DRAWING_COMPLETE, true ));
					}
				} else 
				{
					var p:Point = mark( this.marks[ i ], t ); 
					if ( p ) 
						location = p;
				}
			}
		}
		
		/**
		 * mark
		 * 
		 * As in draw.
		 * 
		 * @param - mark: an object that describes a line or a curve
		 * @param - t: a parameter between 0 and 1
		 * @param - g: a graphics object reference
		 * 
		 **/ 
		private function mark( mark:Object, t:Number, g:Graphics = null ):Point
		{
			if ( mark )
			{
				if ( !g ) g = this.graphics ;
				var p:Point ;
				if ( mark.hasOwnProperty("line"))
					p = drawLine( mark.line, t, g );
				else if ( mark.hasOwnProperty("curve"))
					p = drawBezier( mark.curve, t, g );
				return p ;
			}
			return null ;
		}
		
		/**
		 * getPosition
		 * 
		 * @returns Returns the current position of the pen.
		 **/ 
		public function getPosition( mark:Object ):Point {
			if ( mark.hasOwnProperty("line"))
				return ( mark.line as Array )[0] as Point;
			else if ( mark.hasOwnProperty("curve"))
				return ( mark.curve as Array )[0] as Point;
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
		private static function drawBezier( curve:Array, t:Number, graphics:Graphics ):Point
		{
			if ( !graphics || !curve )
				return null ;
			if ( isNaN( t ))
				return null ;
			if ( curve.length != 3 )
				return null ;
			var a:Point = curve[ 0] as Point ;
			var b:Point = curve[ 1] as Point ;
			var c:Point = curve[ 2] as Point ;
			var p:Point = new Point( a.x + ( b.x - a.x ) * t, a.y + ( b.y - a.y ) * t );
			var q:Point = new Point( b.x + ( c.x - b.x ) * t, b.y + ( c.y - b.y ) * t );
			graphics.lineStyle( 4, 0xffffff, 1 );
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
		private static function drawLine( line:Array, t:Number, graphics:Graphics, alpha:Number = 1 ):Point
		{
			if ( isNaN( t ))
				t = 1 ;
			if ( !graphics || !line )
				return null ;
			if ( isNaN( t ))
				return null ;
			if ( line.length != 2 )
				return null ;
			var a:Point = line[ 0] as Point ;
			var b:Point = line[ 1] as Point ;
			var p:Point = new Point( a.x + ( b.x - a.x ) * t, a.y + ( b.y - a.y ) * t );
			graphics.lineStyle( 4, 0xffffff, 1 );
			graphics.moveTo( a.x, a.y );
			graphics.lineTo( p.x, p.y );
			return p ;
		}
	}
}