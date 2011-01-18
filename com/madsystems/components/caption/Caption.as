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
	import com.madsystems.components.Component;
	
	public class Caption extends Component
	{
		private var textField:TextField ;
		public var text:String ;
		private var caption:String ;
		private var sprite:Sprite ;
		
		public function Caption( color:int ) 
		{  
			super();
			var format:TextFormat = new TextFormat( );
			format.font = "Satero Serif LT Pro" ; 
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
			textField.rotation = -90 ;
			textField.x = 80 ;
			textField.y = 1000 ;
			sprite = new Sprite( );
			addEventListener( StateEvent.RUN, run );
			addEventListener( StateEvent.NEXT, next );
		}
		override public function run( event:Event ):void {
			caption = text.concat();			
			addChild( sprite ) ;
			addChild( textField );
			addEventListener( Event.ENTER_FRAME, frame );
		}
		override public function next( event:Event ):void {
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
			
			var x:int = textField.x/2 ;
			var w:int = ( textField.x - textField.x/2 );
			sprite.graphics.clear();
			sprite.graphics.beginFill( 0xffffff, .2);
			sprite.graphics.drawRect( x, 0, 2 * w + textField.textHeight, stage.stageHeight );
			sprite.graphics.endFill();
			if ( !caption.length ) {
				removeEventListener( Event.ENTER_FRAME, frame );
				dispatchEvent( new Event( Event.COMPLETE ));
			}
		}
	}
}