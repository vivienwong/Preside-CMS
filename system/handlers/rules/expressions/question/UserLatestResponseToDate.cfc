/**
 *
 * @expressionCategory formbuilder
 * @expressionContexts user
 * @feature            websiteusers
 */
component {

	property name="rulesEngineOperatorService" inject="rulesEngineOperatorService";
	property name="formBuilderService"         inject="formBuilderService";
	property name="formBuilderFilterService"   inject="formBuilderFilterService";

	/**
	 * @question.fieldtype  formbuilderQuestion
	 * @question.item_type  date
	 * @_time.isDate
	 *
	 */
	private boolean function evaluateExpression(
		  required string question
		,          struct _time = {}
	) {
		var userId = payload.user.id ?: "";

		if ( !userId.len() ) {
			return false;
		}

		var filter = prepareFilters( argumentCollection = arguments	) ;

		return formBuilderFilterService.evaluateQuestionUserLatestResponseMatch(
			  argumentCollection = arguments
			, userId             = userId
			, formId             = payload.formId ?: ""
			, submissionId       = payload.submissionId ?: ""
			, extraFilters       = filter
		);
		return true;
	}

	/**
	 * @objects website_user
	 */
	private array function prepareFilters(
		  required string question
		,          struct _time               = {}
		,          string parentPropertyName  = ""
		,          string filterPrefix        = ""
	){
		return formBuilderFilterService.prepareFilterForUserLatestResponseToDateField( argumentCollection=arguments );
	}

}