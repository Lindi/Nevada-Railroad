package com.madsystems.components
{
	import com.madsystems.components.image.BitmapFactory ;
	import com.madsystems.components.map.MapFactory ;
	import com.madsystems.components.caption.CaptionFactory ;
	import com.madsystems.components.loop.LoopFactory ;
	import com.madsystems.components.button.ButtonFactory ;
	import com.madsystems.components.gallery.GalleryFactory ;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.filesystem.*;
	
	public class ComponentFactory
	{
	
		protected static var Nevada:DisplayObjectContainer ;
		public static var factories:Object 
		
		//	Blech.  We'd properly encapsulate this if we weren't in a hurry
		public var dispatcher:EventDispatcher = new EventDispatcher( );
		
		public function ComponentFactory(  ) {
			
			
			
//			var factory:Class = BitmapFactory ;
//			factory = MapFactory ;
//			factory = CaptionFactory ;
//			factory = LoopFactory ;
//			factory = ButtonFactory ;
//			factory = GalleryFactory ;
			//	Add additional components ...
		}	
		public static function getInstance( ):ComponentFactory {
			factories = new Object( ) ;
			factories[ "image" ] = new BitmapFactory( );
			factories[ "map" ] = new MapFactory( );
			factories[ "caption" ] = new CaptionFactory( );
			factories[ "loop" ] = new LoopFactory( );
			factories[ "button" ] = new ButtonFactory( );
			factories[ "gallery" ] = new GalleryFactory( );
			
			//	We can do this because we only call this function from one
			//	place in the application
			return ( new ComponentFactory() );
		}

		public function initiatlize( container:DisplayObjectContainer ):ComponentFactory {
			Nevada = container ;
			for each ( var factory:ComponentFactory in factories ) {
				if ( factory is IEventDispatcher )
					( factory as IEventDispatcher ).addEventListener( Event.COMPLETE, complete );
			}
			return this ;
		}
		
		
		public static function add( id:String, factory:Object ):void {
			log( "add("+id+","+factory+")" );
			if ( !factories[ id ] )
				factories[ id ] = factory ;
		}
		
		private function complete( event:Event ):void {
			dispatcher.dispatchEvent( event.clone());
		}
		public static function create( component:XML ):Object {
			//	log( component.toXMLString());
			var type:String = ( component.name().localName as String ) ;
			//	log( type );
			var factory:ComponentFactory = ( factories[ type ] as ComponentFactory ) ;
			//	log( factory );
			if ( factory )
				return factory.create( component ) ;
			return null ;
		}
		
		public static function getFactory( id:String ):ComponentFactory {
			return factories[ id ] ;
		}
		
		protected function create( xml:XML ):Object { return null ;}		

		private static function log( message:* ):void {
			var myFile:File = File.desktopDirectory.resolvePath("nevada-log.txt");
		    var fileStream:FileStream = new FileStream();
		    fileStream.open(myFile, FileMode.READ);
		    var text:String = fileStream.readUTFBytes(fileStream.bytesAvailable);
		    fileStream.close();
			text = text + "\n" + ( new Date( )).toTimeString() + "\t" + String( message );
		    fileStream.open(myFile, FileMode.WRITE);
		    fileStream.writeUTFBytes( text );
		    fileStream.close();
		}
	}
}