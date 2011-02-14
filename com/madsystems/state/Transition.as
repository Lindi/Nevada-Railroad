package com.madsystems.state
{
	public class Transition implements ITransition
	{
		public var target:Object ;
		public var name:String ;
		public var args:Array ;
		
		public function Transition( target:Object, name:String, args:Array )
		{
			this.target = target ;
			this.name = name ;
			this.args = args ;
		}
		
		public function execute( ):void
		{
			if ( target[ name ] as Function )
				( target[ name ] as Function ).apply( target, args );	
			else if ( target.hasOwnProperty( name ))
				( target[ name ] = args[0] ) ;
		}
	}
}