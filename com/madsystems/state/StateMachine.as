﻿package com.madsystems.state
{
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	

	public class StateMachine 
	{
		public var state:State ;
		public var states:Object = {};
		private var main:DisplayObjectContainer ;
		
		public function StateMachine( main:DisplayObjectContainer )
		{
			this.main = main ;
			main.addEventListener( Event.COMPLETE,
				function ( event:Event ):void {
					main.removeEventListener( Event.COMPLETE, arguments.callee );
					addEventListeners( state );
					state.run();
				});
		}
		
		public function add( id:String, state:IState ):void {
			if ( !states[ id ] )
				states[ id ] = state ;
		}
		
		private function addEventListeners( state:State ):void {
			for ( var type:String in state.inputs ) {
				var inputs:Array = state.inputs[ type ] as Array ;
				for each ( var target:Object in inputs ) {
					var component:IEventDispatcher = ( state.components[ target.component ] as IEventDispatcher ); 
					if ( component )
						component.addEventListener( type, next );					
				} 
			}
		}		
		private function removeEventListeners( state:State ):void {
			for ( var type:String in state.inputs ) {
				var inputs:Array = state.inputs[ type ] as Array ;
				for each ( var target:Object in inputs ) {
					var component:IEventDispatcher = ( state.components[ target.component ] as IEventDispatcher ); 
					if ( component )
						component.removeEventListener( type, next );					
				} 
			}
		}

		public function next( input:Event ):void {
	
			var next:String = state.next( input ) ;
			trace( "next("+next+")");
			if ( next ) {
				//	Remove event listeners from the state
				//	This should be refactored to allow many components
				//	for one input type
				
				//	And then we should probably add a condition that tests
				//	of the type of component, or we should store the component
				//	id and test for the id of the component that dispatched
				//	the event
				removeEventListeners( state );

				//	Store a reference to the new state
				state = states[ next ] ;

				//	Now listen to the events in this state
				addEventListeners( state ) ;
				
				//	Rune the state
				state.run( ) ;
			}
		}
	}
}
	
