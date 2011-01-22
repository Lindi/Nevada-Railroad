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
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	public class Caption extends Component
	{
		private var textField:TextField ;
		public var text:String ;
		private var caption:String ;
		private var sprite:Sprite ;
		private var timer:Timer ;
		private var blend:Number
		
		public function Caption( color:int, blend:Number = .2 ) 
		{  
			super();
			var format:TextFormat = new TextFormat( );
			var myFont:Font = new Satero( );
			format.font = myFont.fontName ; //"Satero Serif LT Pro" ; 
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
			timer = new Timer( 20 );
			timer.addEventListener( TimerEvent.TIMER, frame );
		}
		override public function run( event:Event ):void {
			caption = text.concat();			
			addChild( sprite ) ;
			addChild( textField );
			//addEventListener( Event.ENTER_FRAME, frame );
			timer.reset();
			timer.start();
		}
		override public function next( event:Event ):void {
			removeChild( sprite );
			removeChild( textField );
			timer.stop();
//			if ( hasEventListener( Event.ENTER_FRAME ))
//				removeEventListener( Event.EXIT_FRAME, frame );
		}
		private function frame( event:TimerEvent ):void {
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
				timer.stop();
				//	removeEventListener( Event.ENTER_FRAME, frame );
				
				//	Dispatch the complete event a second
				//	after the caption has completed
				var t:Timer = new Timer( 1000, 1 );
				t.addEventListener( TimerEvent.TIMER_COMPLETE,
					function ( event:TimerEvent ):void {
						( event.target as Timer ).removeEventListener
							( TimerEvent.TIMER_COMPLETE, arguments.callee );
						dispatchEvent( new Event( Event.COMPLETE ));
						t = null ;		
					});
				t.start();
				
			}
		}
	}
}