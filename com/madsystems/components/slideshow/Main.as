package com.madsystems.components.slideshow
{
	import com.madsystems.components.ComponentFactory;
	
	import flash.display.MovieClip;
	import flash.filesystem.File;;

	public class Main extends MovieClip
	{
		private var slideshow:Slideshow ;
		
		public function Main()
		{
			super();
			//	Get the application directory
			var dir:File = File.applicationDirectory ;
			
			//	Get the directory for the routes
			var file:File = dir.resolvePath("images") ;
			
			//	If we have a valid directory
			if ( file.isDirectory ) {
				
				//	Create the factory 
				//	Should probably refactor?  Can specific component
				//	factories extend a singleton?
				var factory:ComponentFactory = new ComponentFactory( );
				
				
				
			}
		}
	}
}