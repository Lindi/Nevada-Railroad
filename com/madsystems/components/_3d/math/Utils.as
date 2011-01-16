package com.madsystems.components._3d.math
{
	public class Utils
	{
		public static var EPSILON:Number = .000001 ;
		
		public static function isZero( number:Number ):Boolean {
			return Math.abs( number ) < EPSILON ;
		}
		public static function areEqual( a:Number, b:Number ):Boolean {
			return isZero(a-b);
		}
	}
}