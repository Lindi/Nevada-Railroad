package com.madsystems.components.slideshow
{
	import com.madsystems.builder.IBuilder;
	import com.madsystems.components.Builder;
	import com.madsystems.components.ComponentFactory;

	public class SlideshowFactory extends ComponentFactory {
		
		private var builder:Builder ;
	
		override protected function create( component:XML ):Object {
			if ( !builder )
				builder = new SlideshowBuilder( );
			var id:String = component.@id.toString();
			var object:Object = builder.create( { id: id } );
			if ( object )
				return object ;
			return builder.build( component ) ;
		}

		ComponentFactory.add("slideshow", new SlideshowFactory( ));
	}
}



import com.madsystems.components.Builder;
import com.madsystems.components.slideshow.Slideshow ;
import com.madsystems.components.ComponentFactory;
import flash.display.Bitmap;
import flash.display.DisplayObjectContainer;
import com.madsystems.builder.IBuilder;

class SlideshowBuilder extends Builder
{
	private var slideshow:Slideshow ;
	
	override public function create( object:Object ):Object {
		var id:String = ( object.id as String ) ;
		if ( components[ id ] is Slideshow ) {
			return components[ id ] ;
		}
						
		//	Create a bitmap reference to be returned synchrononously
		slideshow = new Slideshow(  );
		return null ;
	}
	override public function build( component:XML ):Object {
		// Return the Bitmap if we've already made it
		if ( components[ component.@id ] is Slideshow ) 
			return ( components[ component.@id.toString() ] as Slideshow ) ;
		//	Store a reference	
		components[ component.@id.toString() ] = slideshow ;
		//	Add the slideshow images 
		for each ( var image:XML in component.image ) {
			slideshow.add( ComponentFactory.create( image ) as Bitmap );
		}
			
		//	Return the slideshow
		return slideshow ;	
	}
}