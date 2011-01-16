package com.madsystems.components.caption
{
	import com.madsystems.state.event.StateEvent;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.AntiAliasType;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class Caption extends Sprite
	{
		private var main:DisplayObjectContainer ;
		private var textField:TextField ;
		public var text:String ;
		private var caption:String ;
		private var sprite:Sprite ;
		
		public function Caption( main:DisplayObjectContainer, color:int ) 
		{  
			super();
			this.main = main ;
			
			//	var myFont:Satero = new Satero(); 
			var myFont:Font = new Font();
			
			var format:TextFormat = new TextFormat( );
			format.font = myFont.fontName ;
			format.bold = true ;
			format.size = 32 ;
			format.color = color ;
					
			textField = new TextField( );
			textField.autoSize = TextFieldAutoSize.LEFT ;
			textField.defaultTextFormat = format ;
			textField.antiAliasType = AntiAliasType.ADVANCED; 
			textField.multiline = true ;
			textField.wordWrap = true ;
			textField.embedFonts = true ;
			textField.width = 920 ;
			textField.x = textField.y  = 80 ;
			
			sprite = new Sprite( );
			

			addEventListener( StateEvent.RUN, run );
			addEventListener( StateEvent.NEXT, next );
		}
		private function run( event:Event ):void {
			show( this );
			caption = text.concat();
			
			addChild( sprite ) ;
			addChild( textField );
			addEventListener( Event.ENTER_FRAME, frame );
		}
		private function next( event:Event ):void {
			hide( this );
			removeChild( sprite );
			removeChild( textField );
			if ( hasEventListener( Event.ENTER_FRAME ))
				removeEventListener( Event.EXIT_FRAME, frame );
		}
		private function frame( event:Event ):void {
			if ( !stage )
				return ;
			textField.appendText(caption.substr(0,1));
			caption = caption.substring(1);
			
			var y:int = textField.y/2 ;
			var h:int = ( textField.y - textField.y/2 );
			sprite.graphics.clear();
			sprite.graphics.beginFill( 0xffffff, .2);
			sprite.graphics.drawRect( 0, y, stage.stageWidth, 2 * h + textField.textHeight );
			sprite.graphics.endFill();
			if ( !caption.length ) {
				removeEventListener( Event.ENTER_FRAME, frame );
				dispatchEvent( new Event( Event.COMPLETE ));
			}
		}
		private function hide( displayObject:DisplayObject ):void {
			if ( !displayObject )
				return ;
			if ( main.contains( displayObject )) {
				main.removeChild( displayObject ) ;
			}			
		}
		private function show( displayObject:DisplayObject ):void {
			if ( !displayObject )
				return ;
			if ( !main.contains( displayObject )) {
				if ( displayObject.parent is DisplayObjectContainer ) 
					main.addChildAt( ( displayObject.parent as DisplayObjectContainer ).removeChild( displayObject ), main.numChildren);
				else {
					main.addChildAt( displayObject, main.numChildren);
				} 
			} else {
				main.addChildAt( ( displayObject.parent as DisplayObjectContainer ).removeChild( displayObject ), main.numChildren);
			}
		}
	}
}