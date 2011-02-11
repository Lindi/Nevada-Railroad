package com.madsystems.components.button
{
	import com.madsystems.components.Builder;
	import com.madsystems.components.ComponentFactory;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Bitmap ;
	
	internal class ButtonBuilder extends Builder 
	{

		
		override public function build( button:XML ):Object {
			
			//	Return the Bitmap if we've already made it
			var id:String = button.@id.toString() as String ;
			var sprite:Sprite = ( components[ id ] as Sprite ) ;
			if ( sprite ) 
				return sprite ;
		
					
			//	Create a sprite reference to be returned synchrononously
			sprite = components[ id ] = new Sprite( );
			
			//	Position the bitmap if we've included positioning data
			if ( button.@x )
				sprite.x = Number( button.@x.toString());
			if ( button.@y )
				sprite.y = Number( button.@y.toString());
				
			//	Name the button
			sprite.name = id ;
				
			
			//	Create the button xml node
			var list:XMLList = button.image ;
			sprite.addChild( ComponentFactory.create(list[0]) as Bitmap );
			return sprite ;
		}
	}
}