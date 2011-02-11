package com.madsystems.components.gallery
{
	import com.madsystems.components.Builder;
	import com.madsystems.components.ComponentFactory;
	
	import flash.display.Sprite;;

	internal class GalleryBuilder extends Builder
	{
		
		override public function build( component:XML ):Object {
			
			//	Return the Bitmap if we've already made it
			var id:String = component.@id.toString() as String ;
			var gallery:Gallery = ( components[ id ] as Gallery ) ;
			if ( gallery ) 
				return gallery ;
					
					
			//	Create the images array
			var images:Array = new Array( );
			var list:XMLList = component.images.children() ;
			for ( var i:int = 0; i < list.length(); i++ ) {
				var image:XML = ( list[ i ] as XML );
				images.push( ComponentFactory.create( image ));
			}
			
			//	Create the buttons array
			var button:Sprite = ComponentFactory.create(( component.button )[0] as XML ) as Sprite ;
			
//			var buttons:Array = new Array( );
//			list = component.buttons.children() ;
//			for ( i = 0; i < list.length(); i++ ) {
//				var button:Sprite = ComponentFactory.create( ( list[ i ] as XML ) ) as Sprite ;
//				buttons.push( button );
//			}
			
			//	Create the gallery and pass the images and buttons
			gallery = components[ id ] = new Gallery( images, button ) ;//buttons, component.buttons.@toggle.toString(), button.x );
			
			//	Return the gallery
			return gallery ;
			
		}
	}
}