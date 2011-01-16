package com.madsystems.components._3d.math
{
	import flash.geom.Utils3D;
	import flash.geom.Vector3D;

	public class Plane
	{
		public var normal:Vector3D ;
		public var d:Number ;
		
		public function Plane( p:Vector3D, q:Vector3D, r:Vector3D )
		{
			setPoints( p, q, r );
		}
		/**
		 * setPoints
		 * 
		 * Calculates the plane normal from three points in the plane
		 * and sets the plane normal with a plane constant of zero (is that right?)
		 **/ 
		public function setPoints( p:Vector3D, q:Vector3D, r:Vector3D ):void {
			var u:Vector3D = q.subtract(p );
			var v:Vector3D = r.subtract(p );
			normal = u.crossProduct(v) ;
			normal.normalize( );
			d = normal.dotProduct( p );
		}
		/**
		 * whichSide
		 * 
		 * Returns +1 if the point is on the positive side of the plane
		 * Returns -1 if the point is on the negative side of the plane
		 * Returns 0 if the point is on the plane ;
		 **/ 
		public function whichSide( p:Vector3D ):int {
			var distance:Number = distanceTo( p );
			if ( distance > 0 )
				return 1 ;
			if ( distance < 0 )
				return -1 ;
			return 0 ;
				
		}
		
		/**
		 * test
		 * 
		 * Returns true if the vertex is on the positive side
		 * of the plane, and false if not
		 **/ 
		public function test( vertex:Vector3D ):Boolean {
			if ( normal is Vector3D && d is Number )
				return normal.dotProduct( vertex ) - d >= 0 ;
			return false ;
		}
		
		/**
		 * distanceTo
		 * 
		 * Returns the distance from the point to the plane
		 **/ 
		public function distanceTo( point:Vector3D ):Number {
			if ( normal is Vector3D && d is Number )
				return normal.dotProduct( point ) - d ;
			return undefined ;
		}
		
	}
}