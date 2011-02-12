package com.madsystems.components.button
{
	import com.madsystems.components.Builder;
	import com.madsystems.components.ComponentFactory;
	
	import flash.display.Bitmap;
	
	internal class ButtonBuilder extends Builder 
	{

		
		override public function build( component:XML ):Object {
			
			//	Return the Bitmap if we've already made it
			var id:String = component.@id.toString() as String ;
			var button:Button = ( components[ id ] as Button ) ;
			if ( button ) 
				return button ;
		
					
			//	Create an array of bitmaps that represent the buttons states
			var states:Array = new Array( ) ;
			for each ( var image:XML in component.image )
				states.push( ComponentFactory.create( image ));
			//	Create a sprite reference to be returned synchrononously
			button = components[ id ] = new Button( states );
			
			//	Position the bitmap if we've included positioning data
			if ( component.@x )
				button.x = Number( component.@x.toString());
			if ( component.@y )
				button.y = Number( component.@y.toString());
				
			//	Name the button
			button.name = id ;
				
			
			//	Create the button xml node
			return button ;
		}
	}
}