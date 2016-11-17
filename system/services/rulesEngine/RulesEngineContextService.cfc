/**
 * Provides logic for dealing with rules engine contexts.
 *
 * See [[rules-engine]] for more details.
 *
 * @singleton
 * @presideservice
 * @autodoc
 *
 */
component displayName="RulesEngine Context Service" {

// CONSTRUCTOR
	/**
	 * @configuredContexts.inject coldbox:setting:rulesEngine.contexts
	 *
	 */
	public any function init( required struct configuredContexts ) {
		_setConfiguredContexts( arguments.configuredContexts );

		return this;
	}


// PUBLIC API
	/**
	 * Returns an array with details of all configured rules engine expression contexts
	 *
	 * @autodoc
	 * @filterObject.hint optionally use this argument to provide an object with which to filter the contexts. Only contexts that can be used as a filter for this object will be returned
	 */
	public array function listContexts( string filterObject = "" ) {
		var contexts = _getConfiguredContexts();
		var list     = [];

		for( var contextId in contexts ) {
			if ( !arguments.filterObject.len() || ( contexts[ contextId ].filterObject ?: "" ) == arguments.filterObject ) {
				list.append({
					  id           = contextId
					, title        = $translateResource( "rules.contexts:#contextId#.title"       )
					, description  = $translateResource( "rules.contexts:#contextId#.description" )
					, iconClass    = $translateResource( "rules.contexts:#contextId#.iconClass"   )
					, filterObject = contexts[ contextId ].filterObject ?: ""
				});
			}
		}

		list.sort( function( a, b ){
			return a.title > b.title ? 1 : -1;
		} );

		return list;
	}

	/**
	 * Returns an array of context IDs that are valid for the given parent contexts
	 * @autodoc
	 * @parentContext.hint IDs of the parent contexts
	 */
	public array function listValidExpressionContextsForParentContexts( required array parentContexts ) {
		var contexts      = _getConfiguredContexts();
		var validContexts = Duplicate( arguments.parentContexts );

		for( var parentContext in arguments.parentContexts ) {
			var subContexts   = contexts[ parentContext ].subcontexts ?: [];
			for( var subContext in subContexts ) {
				validContexts.append( listValidExpressionContextsForParentContexts( [ subContext ] ), true );
			}
		}

		return validContexts;
	}

	/**
	 * Returns an array of context IDs expanded from a source array of contexts to include
	 * any parent contexts
	 *
	 * @autodoc
	 * @contexts.hint IDs of the contexts to expand
	 */
	public array function expandContexts( required array contexts ) {
		var configuredContexts = _getConfiguredContexts();
		var expanded = Duplicate( arguments.contexts );

		for( var sourceContext in arguments.contexts ) {
			for ( var contextName in configuredContexts ) {
				var subContexts = configuredContexts[ contextName ].subcontexts ?: [];

				if ( subContexts.findNoCase( sourceContext ) && !expanded.findNoCase( contextName ) ) {
					expanded.append(  expandContexts( [ contextName ] ), true );
				}
			}
		}

		return expanded;
	}

	/**
	 * Returns the configured object (ID) that filters for the given context will filter against
	 *
	 * @autodoc
	 * @context.hint The context who's filter object you wish to get
	 */
	public string function getFilterObjectForContext( required string context ) {
		var contexts = _getConfiguredContexts();

		return contexts[ arguments.context ].filterObject ?: "";
	}

// GETTERS AND SETTERS
	private struct function _getConfiguredContexts() {
		return _configuredContexts;
	}
	private void function _setConfiguredContexts( required struct configuredContexts ) {
		_configuredContexts = arguments.configuredContexts;
	}

}