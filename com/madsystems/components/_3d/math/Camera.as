package com.madsystems.components._3d.math
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import __AS3__.vec.Vector ;

	public class Camera
	{
		//	Eye point
		public var eye:Vector3D ;
		
		//	Direction vectory
		public var d:Vector3D ;
		
		//	Up vector
		public var u:Vector3D ;
		
		//	Side vector
		public var r:Vector3D ;
		
		//	Camera frustum
		public var frustum:Frustum ;
		
		public function Camera( frustum:Frustum ) {
			this.frustum = frustum ;
			this.eye = frustum.eye ;
			this.d = frustum.d ;
			this.u = frustum.u ;
			this.r = frustum.r ;
		}
		
		
		public function lookAt( point:Vector3D ):void {
			//	Use Gram-Schmidt orthogonalization to determine
			//	the component of the direction vector that 
			//	is perpendicular to the unit vector k
			frustum.eye = eye ;
			var k:Vector3D = point.subtract( frustum.eye ); 
			k.normalize();
			frustum.d = k ;
			
			//	Calculate the up vector using Gram-Schmidt orthogonalization
			var j:Vector3D = k.clone( );
			j.scaleBy( Vector3D.Y_AXIS.dotProduct(k) ) ;
			j = Vector3D.Y_AXIS.subtract( j );
			j.normalize();
			frustum.u = j ;
			
			//	Calculate the side vector using the cross product
			var i:Vector3D = k.crossProduct( j ); 
			frustum.r = i ;
			
		}
		
		public function transform():Matrix3D {
			//	Negate the direction vector 
			//	Open GL uses a negated direction vector
			//	to ensure that rotations are pure and don't
			//	involve a reflection about the z-axis
			var d:Vector3D = frustum.d ;
			d.negate( );
			var u:Vector3D = frustum.u ;
			var r:Vector3D = frustum.r.clone() ;
			
			
			//	Assemble the camera transform matrix
			//	Note that columns and rows are reversed in Flash
			//	To do a world to view transform, we'd set rows
			//	in a row major form matrix; however, here we set
			//	columns for a world to view transform and rows
			//	for a view to world transform
			var data:Vector.<Number> = new Vector.<Number>(16,true);
			data[0] = r.x ;
			data[1] = r.y ;
			data[2] = r.z ;
			data[3] = 0 ;
			data[4] = u.x ;
			data[5] = u.y ;
			data[6] = u.z ;
			data[7] = 0 ;
			data[8] = d.x ;
			data[9] = d.y ;
			data[10] = d.z ;
			data[11] = 0 ;
			data[12] = 0 ;
			data[13] = 0 ;
			data[14] = 0 ;
			data[15] = 1 ;
			var matrix:Matrix3D = new Matrix3D( data ) ;
			
			//	Calculate the translation vector
			//	by multiplying a clone of the eye vector
			//	by the transpose of the current transform matrix
			var t:Vector3D = new Vector3D( );
			t.x = r.dotProduct( eye ) ;
			t.y = u.dotProduct( eye ) ;
			t.z = d.dotProduct( eye ) ;
			t.negate( );
			matrix.appendTranslation( t.x, t.y, t.z );
			
			//	Return the matrix
			return matrix ;
		}
	}
}


