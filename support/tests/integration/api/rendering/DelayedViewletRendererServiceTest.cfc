component extends="tests.resources.HelperObjects.PresideBddTestCase"{

	function run(){
		describe( "renderDelayedViewlets()", function(){
			it( "should recursively replace delayed viewlet markup with dynamically rendered versions of the viewlet until there are no more viewlet markup tags left in the given content", function(){
				var service    = _getService();
				var complexArg = { test="this" };
				var dvs        = [
					  "<!--dv:test.viewlet( arg1=#ToBase64( 'true' )#, arg2=#ToBase64( 'test' )#, arg3=#ToBase64( SerializeJson( complexArg ) )# )-->"
					, "<!--dv:another.test.viewlet(arg3=#ToBase64( 'false' )#)-->"
					, "<!--dv:nested.viewlet()-->"
				];
				var replacements = {
					  "#dvs[1]#" = CreateUUId()
					, "#dvs[2]#" = "Test #dvs[3]#"
					, "#dvs[3]#" = CreateUUId()
				};
				var content = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,
#dvs[1]# exercitation ullamco laboris nisi ut aliquip ex ea commodo
consequat. Duis aute irure dolor in reprehenderit in #dvs[1]# voluptate velit esse
cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non
proident, sunt in #dvs[2]# culpa qui officia deserunt mollit anim id est laborum.";
				var expected = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,
#replacements[ dvs[1] ]# exercitation ullamco laboris nisi ut aliquip ex ea commodo
consequat. Duis aute irure dolor in reprehenderit in #replacements[ dvs[1] ]# voluptate velit esse
cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non
proident, sunt in Test #replacements[ dvs[3] ]# culpa qui officia deserunt mollit anim id est laborum.";

				mockColdbox.$( "renderViewlet" ).$args(
					  event   = "test.viewlet"
					, args    = { arg1=true, arg2='test', arg3=complexArg }
					, delayed = false
				).$results( replacements[ dvs[1] ] );
				mockColdbox.$( "renderViewlet" ).$args(
					  event   = "another.test.viewlet"
					, args    = { arg3=false }
					, delayed = false
				).$results( replacements[ dvs[2] ] );
				mockColdbox.$( "renderViewlet" ).$args(
					  event   = "nested.viewlet"
					, args    = {}
					, delayed = false
				).$results( replacements[ dvs[3] ] );


				expect( service.renderDelayedViewlets( content ) ).toBe( expected );
			} );
		} );

		describe( "renderDelayedViewletTag()", function(){
			it( "should return an html comment string with urlencoded and json serialized args", function(){
				var service  = _getService();
				var event    = "test.event.viewlet";
				var args     = StructNew( 'linked' );
				var expected = "";

				args.aBool       = true
				args.aString     = "test"
				args.aNumber     = 345
				args.aComplexOne = { fubar=true, test={ stuff=CreateUUId() } }

				expected = "<!--dv:#event#(aBool=#ToBase64( 'true' )#,aString=#ToBase64( 'test' )#,aNumber=#ToBase64( '345' )#,aComplexOne=#ToBase64( SerializeJson( args.aComplexOne ) )#)-->";

				expect( service.renderDelayedViewletTag(
					  event = event
					, args  = args
				) ).toBe( expected );
			} );
		} );
	}

	private function _getService(){
		variables.mockColdbox = CreateStub();

		var service = CreateMock( object=new preside.system.services.rendering.DelayedViewletRendererService() );

		service.$( "$getColdbox", mockColdbox );

		return service;
	}


}