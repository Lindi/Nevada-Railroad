package com.madsystems.state
{
	import com.madsystems.state.event.StateEvent;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.display.Sprite ;
	
	import mx.core.UIComponent;;
	
	public class State extends EventDispatcher implements IState
	{
		
		//	In Java, these should be final
		public var components:Array ;
		public var inputs:Object ;
		public var id:String ;
		public var uicomponent:UIComponent ;
		public var nevada:DisplayObjectContainer ;
		internal var timer:Timer ;
		
		public function State( nevada:DisplayObjectContainer, timeout:Number = 0 )
		{
			super( );
			this.nevada = nevada ;
			uicomponent = new UIComponent( );
			components = new Array( );
			inputs = new Object( );
			if ( timeout ) {
				timer = new Timer( timeout, 1 );
				timer.addEventListener( TimerEvent.TIMER_COMPLETE, this.timeout );
			}
		}

		public function run( ):void {
			trace("run("+id+")");
			
			//	N.B.:	We're doing this before so that
			//	child components don't flame out if they
			//	reference the stage during the run event
			nevada.addChild( uicomponent );

			//	N.B.:  You must iterate over the array to ensure that
			//	components are added to the uicomponent in the correct order
			for ( var i:int = 0; i < components.length; i++ ) {
				var component:Object = components[ i ] ;
				if ( component is DisplayObject )
					show(( component as DisplayObject ), uicomponent, i );
				if ( component is IEventDispatcher )
					( component as IEventDispatcher ).dispatchEvent( new StateEvent( StateEvent.RUN ));
			}
			
			//	Create the timeout timer
			if ( timer )
				timer.start();
			
		}
		
		public function next( event:Event ):String {
			trace( "next("+event+")");
			//	Find the right row of the input table
			var input:Array ;
			for ( var type:String in inputs ) {
				if ( type == event.type ) {
					input = inputs[ type ] ;
					break ;
				}
			}
					
			if ( input ) {
				
				//	Get the next state
				var next:String ;
				if ( event.type == StateEvent.TIMEOUT ) {
					//	Go through each transition and execute it
					if ( input[ 0].transitions ) {
						for each ( var transition:Transition in input[ 0 ].transitions )
							transition.execute();
					}
					next = input[ 0].next ;
				} else {
					//	First find the row
					for ( var i:int = 0; i < input.length; i++ ) {
						var component:Object = components[ input[ i ].component ] ;
						if ( event.target === component )
							break ;
					}
					
					//	Go through each transition and execute it
					if ( input[ i].transitions ) {
						for each ( transition in input[ i ].transitions )
							transition.execute();
					}
					
					//	Go to the next state
					next = input[i].next ;
				} 
				if ( next ) {
					nevada.removeChild( uicomponent );
					
					//	Take the kids out
					for each ( var child:DisplayObject in uicomponent )
						hide( child, uicomponent );
					
					//	Kill the timeout timer if there is one
					if ( timer )
						timer.stop();
						
					//	Return the new state
					return next ;
				}
			}
			return null ;
		}
		private function dispatch ( event:Event ):void {
			trace( "dispatch("+event+")");
			//	This is fine for now, but it might be a problem
			//	if we want to test the event target in the state machine
			dispatchEvent( event.clone());
		}
		
		private function timeout( event:TimerEvent):void {
			dispatchEvent( new Event( StateEvent.TIMEOUT ));
		}
		/**
		 * show
		 * 
		 * Adds a display object to the main display object container
		 * If the display object has a parent, it re-parents the
		 * display object in the main display object container
		 **/ 
		private function show( displayObject:DisplayObject, container:DisplayObjectContainer, index:int ):void {
			trace("show("+displayObject+","+index+")");
			//displayObject.visible = !( displayObject is Bitmap );
			if ( displayObject is DisplayObjectContainer )
				trace( ( displayObject as DisplayObjectContainer ).numChildren );
			//if ( !container.contains( displayObject )) {
				if ( displayObject.parent is DisplayObjectContainer ) 
					container.addChildAt( ( displayObject.parent as DisplayObjectContainer ).removeChild( displayObject ), index )
				else container.addChildAt( displayObject, index );
			//}
			trace("show("+container.getChildIndex( displayObject )+")");
		}
		/**
		 * hide
		 * 
		 * Removes a display object from the main display object container
		 **/ 
		private function hide( displayObject:DisplayObject, container:DisplayObjectContainer ):void {
//			if ( !container )
//				return ;
//			if ( !displayObject )
//				return ;
			if ( container.contains( displayObject )) {
				container.removeChild( displayObject ) ;
			}			
		}		
	}
}