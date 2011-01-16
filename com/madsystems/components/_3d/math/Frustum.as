package com.madsystems.components._3d.math
{
	import __AS3__.vec.Vector;
	
	
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;

	public class Frustum
	{
		//	Near and far
		public var near:Number ;
		public var far:Number ;
		
		//	Camera eye point/position
		public var eye:Vector3D ;
		
		//	Orthonormal frustum frame basis vectors
		//	Obviously, they should be normalized.  Duh.
		public var d:Vector3D ;
		public var u:Vector3D ;
		public var r:Vector3D ;
		
		//	The distance from the eye point to the view plane
		public var z:Number ;

		
		//	Width and Height
		public var width:Number ;
		public var height:Number ;
		
		//	Field of view
		public var fov:Number ;
		
		//	Perspective matrix.
		//	This won't change
		private var perspective:Matrix3D ;
		public var screen:Matrix3D ;
		
		public var planes:Vector.<Plane> = new Vector.<Plane>();
		

		public function Frustum( fov:Number, eye:Vector3D, d:Vector3D, u:Vector3D, 
								 r:Vector3D, width:Number, height:Number ) 
		{
			this.fov = fov ;
			this.z = 1.0/Math.tan((fov/2) * (Math.PI/180.0));
			this.eye = eye ;
			this.d = d ;
			this.u = u ;
			this.r = r ;
			this.near = z * 5 ; //near ;
			this.far = z * 20 ; //far ;
			this.width = width ;
			this.height = height ;
			update( );
		}
		
		public function update( ):void 
		{
			var vertex:Vector.<Vector3D> = computeVertices();
			planes = new Vector.<Plane>(6,true);
			//	Near plane
			planes[0] = new Plane(vertex[0], vertex[3], vertex[1]);
			//	Far plane
			planes[1] = new Plane(vertex[5], vertex[4], vertex[6]);
			//	Left plane
			planes[2] = new Plane(vertex[4], vertex[0], vertex[7]);
			//	Right plane
			planes[3] = new Plane(vertex[1], vertex[5], vertex[2]);
			//	Top plane
			planes[4] = new Plane(vertex[3], vertex[2], vertex[7]);
			//	Bottom plane
			planes[5] = new Plane(vertex[1], vertex[0], vertex[5]);	
		}
		
		private function computeVertices():Vector.<Vector3D> 
		{	
			var d:Vector3D = this.d.clone() ;
			d.scaleBy( near );
			
			var u:Vector3D = this.u.clone();
			u.scaleBy( height/2 );
			
			var r:Vector3D = this.r.clone() ;
			r.scaleBy( width/2 );
			
			var vertex:Vector.<Vector3D> = new Vector.<Vector3D>(8,true);
			vertex[0] = d.subtract(u).subtract(r);
			vertex[1] = d.subtract(u).add(r) ;
			vertex[2] = d.add(u).add(r);
			vertex[3] = d.add(u).subtract(r);
			
			for (var i:int = 0, ip:int = 4; i < 4; ++i, ++ip)
			{
				var v:Vector3D = ( vertex[i] as Vector3D ).clone();
				v.scaleBy( far/near );
				vertex[ip] =  v.add( eye );
				vertex[i] = ( vertex[i] as Vector3D ).add(eye);
			}			
			
			return vertex ;
		}

		
		public function transform():Matrix3D 
		{
			if ( perspective )
				return perspective ;
			var recipZ:Number = 1.0/(near-far);
			var a:Number = width / height ;
			var data:Vector.<Number> = new Vector.<Number>(16,true);
			data[0] = z / a ;
			data[5] = z ;
			data[10] = (near+far)*recipZ ;
			data[14] = 2*near*far*recipZ ;
			data[11] = -1 ;
			perspective = new Matrix3D( data );
			data = new Vector.<Number>(16);
			data[0] = width/2 ;
			data[5] = height/2 ;
			data[10] = .5 ;
			data[12] = width/2 ;
			data[13] = height/2 ;
			data[14] = .5;
			data[15] = 1 ;
			screen = new Matrix3D( data );
			return perspective ;
		}
	}
	
}
