package com.madsystems.components.background
{
	import com.madsystems.components.Builder;
	import com.madsystems.components.ComponentFactory;
	
	import flash.display.Bitmap;
	import flash.events.EventDispatcher;
	import flash.filesystem.*;

	internal class BackgroundBuilder extends Builder
	{
		private var dispatcher:EventDispatcher = new EventDispatcher( );
		private var index:int = 0 ;
		private var loaders:Array = new Array( );

		override public function build( component:XML ):Object {
			
			//	Return the Bitmap if we've already made it
			var id:String = component.@id.toString() as String ;
			var background:Background = ( components[ id ] as Background ) ;
			if ( background ) 
				return background ;
		
			//	Create the image and return the background
			var image:XML = ( component.image as XMLList )[0] as XML ; //( component.image.* as XMLList )[0] as XML ;
			var bitmap:Bitmap = ( ComponentFactory.create( image ) as Bitmap );
			var speed:int = ( component.@speed ? int( component.@speed.toString()) : 2 );
			background = components[ id ] = new Background( bitmap, speed );
			return background ;
		}
	}
}