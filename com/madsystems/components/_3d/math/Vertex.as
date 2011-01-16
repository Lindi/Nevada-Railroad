package com.madsystems.components._3d.math
{
	import flash.geom.Vector3D;
	
	public class Vertex extends Vector3D
	{
		public var visible:Boolean = true ;
		
		public function Vertex(x:Number=0.0, y:Number=0.0, z:Number=0.0, w:Number=0.0)
		{
			super(x, y, z, w);
		}
	}
}