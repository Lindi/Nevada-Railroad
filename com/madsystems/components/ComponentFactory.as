package com.madsystems.components
{
	import com.madsystems.components.image.BitmapFactory;
	import com.madsystems.components.map.MapFactory;
	import com.madsystems.components.slideshow.SlideshowFactory;
	import com.madsystems.components.transition.TransitionFactory;
	import com.madsystems.components.caption.CaptionFactory ;
	import com.madsystems.components.loop.LoopFactory;
	
	import flash.display.DisplayObjectContainer;
	
	public class ComponentFactory
	{
	
		protected static var main:DisplayObjectContainer ;
		
		public function ComponentFactory(  ) {
			var factory:Class = SlideshowFactory ;
			factory = BitmapFactory ;
			factory = MapFactory ;
			factory = TransitionFactory ;
			factory = CaptionFactory ;
			factory = LoopFactory ;
			//	Add additional components ...
		}	
		
		public function initiatlize( container:DisplayObjectContainer ):ComponentFactory {
			main = container ;
			return this ;
		}
		public static var factories:Object = new Object( );
		
		public static function add( id:String, factory:Object ):void {
			if ( !factories[ id ] )
				factories[ id ] = factory ;
		}
		
		public static function create( component:XML ):Object {
			var type:String = ( component.name().localName as String ) ;
			var factory:ComponentFactory = ( factories[ type ] as ComponentFactory ) ;
			if ( factory )
				return factory.create( component ) ;
			return null ;
		}
		
		public static function getFactory( id:String ):ComponentFactory {
			return factories[ id ] ;
		}
		
		protected function create( xml:XML ):Object { return null ;}		
	}
}