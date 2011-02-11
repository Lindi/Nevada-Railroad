package com.madsystems.components.background
{
	import com.madsystems.components.Component;
	import com.madsystems.state.event.StateEvent;
	
	import flash.display.Bitmap;
	import flash.events.Event;

	internal class Background extends Component
	{
		private var background:Bitmap ;
		private var speed:int ;
		private var direction:int = 1 ;
		private var positioned:Boolean = false ;
		
		public function Background( background:Bitmap, speed:int )
		{
			super();
			this.background = background ;
			this.speed = speed ;
			addEventListener( StateEvent.RUN, run );
			addEventListener( StateEvent.NEXT, next );
		}
		
		
		override public function run( event:Event ):void {
			
			//	Listen to the enter frame event
			addEventListener( Event.ENTER_FRAME, frame );
			
			//	Position the background image
			if ( !positioned ) {
				background.y = stage.stageHeight - background.height ;
				positioned = true ;
			}
		}
		
		override public function next( next:Event ):void {
			
			//	Stop listening to the enter frame event
			removeEventListener( Event.ENTER_FRAME, frame ) ;
		}
		
		private function frame( event:Event ):void {
			if ( background.y + speed > 0 && direction == 1 )
				direction = -1 ;
			else if ( background.y - speed + background.height < stage.stageHeight && direction == -1 ) 
				direction = 1 ;
				
			//	Animate the background image
			background.y += ( speed * direction ) ;
			
		}
	}
}