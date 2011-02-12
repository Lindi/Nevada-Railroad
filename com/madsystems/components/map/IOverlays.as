package com.madsystems.components.map
{
	import flash.geom.Point;
	
	internal interface IOverlays
	{
		function overlay( zoom:Number, location:Point ):void ;
	}
}