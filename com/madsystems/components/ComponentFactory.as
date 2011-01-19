package com.madsystems.components
{
	import com.madsystems.components.caption.CaptionFactory;
	import com.madsystems.components.image.BitmapFactory;
	import com.madsystems.components.loop.LoopFactory;
	import com.madsystems.components.map.MapFactory;
	import com.madsystems.components.slideshow.SlideshowFactory;
	import com.madsystems.components.transition.TransitionFactory;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	public class ComponentFactory
	{
	
		protected static var main:DisplayObjectContainer ;
		
		//	Blech.  We'd properly encapsulate this if we weren't in a hurry
		public var dispatcher:EventDispatcher = new EventDispatcher( );
		
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
			for each ( var factory:ComponentFactory in factories ) {
				if ( factory is IEventDispatcher )
					( factory as IEventDispatcher ).addEventListener( Event.COMPLETE, complete );
			}
			return this ;
		}
		public static var factories:Object = new Object( );
		
		public static function add( id:String, factory:Object ):void {
			if ( !factories[ id ] )
				factories[ id ] = factory ;
		}
		
		private function complete( event:Event ):void {
			dispatcher.dispatchEvent( event.clone());
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