var g_chart_api = {}
g_chart_api.CategoryFilter = function(id, label){	
	var settings = {
		'controlType': 'CategoryFilter',
		'containerId': id,
		'options': {
//		  'filterColumnIndex': 0,
		  'filterColumnLabel': label,
		  'ui': {		 
		  	'label': false,
		  	'caption': label,
		  	'allowTyping': false,
		  	'selectedValuesLayout' : 'below',
		    'allowMultiple': true,
			'cssClass': 'categoryControlFilter',
		  }
		}
	}
	return settings
}
