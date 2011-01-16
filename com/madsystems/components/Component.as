package com.madsystems.components
{
	import com.madsystems.state.event.StateEvent;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	
	import mx.core.UIComponent;

	public class Component extends UIComponent
	{
		protected var main:DisplayObjectContainer ;
		
		public function Component( main:DisplayObjectContainer = null )
		{
			super();
			this.main = main ;
		}
		
		/**
		 * run
		 * 
		 * Default abstract method.  The run method is invoked
		 * by the controlling state in order to activate the component
		 **/ 
		protected function run( event:StateEvent ):void {}
		
		/**
		 * next
		 * 
		 * Default abstract method.  The next method is invoked
		 * by the controlling state in order to de-activate the component
		 **/ 
		protected function next( event:StateEvent ):void {}
		
		/**
		 * show
		 * 
		 * Adds a display object to the main display object container
		 * If the display object has a parent, it re-parents the
		 * display object in the main display object container
		 **/ 
		protected function show( displayObject:DisplayObject ):void {
			if ( !main )
				return ;
			if ( !displayObject )
				return ;
			if ( !main.contains( displayObject )) {
				if ( displayObject.parent is DisplayObjectContainer ) 
					main.addChild( ( displayObject.parent as DisplayObjectContainer ).removeChild( displayObject ))
				else main.addChild( displayObject );
			}
		}
		/**
		 * hide
		 * 
		 * Removes a display object from the main display object container
		 **/ 
		protected function hide( displayObject:DisplayObject ):void {
			if ( !main )
				return ;
			if ( !displayObject )
				return ;
			if ( main.contains( displayObject )) {
				main.removeChild( displayObject ) ;
			}			
		}		
	}
}