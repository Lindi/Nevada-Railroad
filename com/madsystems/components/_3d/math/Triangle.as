package com.madsystems.components._3d.math
{
	public class Triangle
	{
		public var index:Array = new Array(3) ;
		public var edges:Array = new Array(3);
		public var visible:Boolean = true ;
		
		public function Triangle(a:int, b:int, c:int)
		{
			index[0] = a ;
			index[1] = b ;
			index[2] = c ;
		}
		public function clone():Triangle {
			return new Triangle( index[0], index[1], index[2] );
		}
		public function toString():Object {
			return index.toString();
		}
		public function valueOf():Object {			
			var val:int = 0 ;
			var tmp:uint ;
			var string:String = index.toString();
			while ( string.length ) {
				val = ( val << 4 ) + string.substr(0,1).charCodeAt(0);
				if ( Boolean(tmp = ( val & 0xf0000000 ))) {
					val = val ^ ( tmp >> 24 );
					val = val ^ tmp;
				}
				string = string.substr(1);
			}
			return new Number(val);
		}
	}
}