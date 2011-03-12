package com.madsystems.components.caption
{
	import com.madsystems.components.Component;
	import com.madsystems.state.event.StateEvent;
	
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import fl.transitions.easing.None;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.text.AntiAliasType;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	public class Caption extends Component
	{
		private var textField:TextField ;
		public var text:String ;
		private var caption:String ;
		private var sprite:Sprite ;
//		private var timer:Timer ;
		private var tween:Tween ;
		private var blend:Number ;
		private var html:String = "" ;
		public function Caption( color:int, blend:Number = .5 ) 
		{  
			super();

			var style:StyleSheet = new StyleSheet( );		
			var highlight:Object = new Object();
            highlight.fontWeight = "bold";
            highlight.color = "#FEE480";


            style.setStyle(".highlight", highlight);


			var format:TextFormat = new TextFormat( );
			format.font = "Bookman Old Style" ;//Satero Serif LT Pro" ; //myFont.fontName ; //"Satero Serif LT Pro" ; 
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
			textField.styleSheet = style ;
			textField.selectable = false ;
			sprite = new Sprite( );
			addEventListener( StateEvent.RUN, run );
			addEventListener( StateEvent.NEXT, next );
//			timer = new Timer( 125 );
//			timer.addEventListener( TimerEvent.TIMER, frame );
			this.blend = .8;//blend ;
			
			tween = new Tween( {}, "", None.easeIn, 0, 1, 1, true ) ;
			tween.addEventListener( TweenEvent.MOTION_CHANGE, frame ) ;
			tween.addEventListener( TweenEvent.MOTION_FINISH, frame ) ;
						

		}
		override public function run( event:Event ):void {
			caption = text.concat();		
//			trace( caption );	
			addChild( sprite ) ;
			addChild( textField );
//			timer.reset();
//			timer.start();
			textField.text = html = textField.htmlText = caption ;
			tween.start();
		}
		override public function next( event:Event ):void {
			removeChild( sprite );
			removeChild( textField );
			tween.stop();
			//timer.stop();
//			if ( hasEventListener( Event.ENTER_FRAME ))
//				removeEventListener( Event.EXIT_FRAME, frame );
		}
		private function frame( event:TweenEvent ):void {
			if ( !stage )
				return ;
				
			textField.alpha = tween.position ;
//			trace( textField.alpha );
//			var index:int = caption.indexOf(" ");
//			if ( index != -1 ) {
//				html += caption.substr(0,index) + " " ;
////				textField.appendText(caption.substr(0,index) + " ");
//				caption = caption.substring(index+1);
//			} else if ( caption.length ) {
//				html += caption ;
////				textField.appendText(caption);
//				caption = "";
//								
//			}
//			textField.htmlText = html ;
			var x:int = textField.x/2 ;
			var w:int = ( textField.x - textField.x/2 );
			sprite.graphics.clear();
			sprite.graphics.beginFill( 0x000000, blend );
			sprite.graphics.drawRect( x, 0, 2 * w + textField.textHeight, stage.stageHeight );
			sprite.graphics.endFill();
			
			if ( event.type == TweenEvent.MOTION_FINISH ) {
				( event.target as Tween ).removeEventListener
					( TweenEvent.MOTION_CHANGE, arguments.callee );
				( event.target as Tween ).removeEventListener
					( TweenEvent.MOTION_FINISH, arguments.callee );
				tween.stop( );
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