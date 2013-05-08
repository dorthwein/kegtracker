
    
var g_chart_api = {
	CategoryFilter: function(id, label){	
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
	},
	PieChart: function(source, group_by_index, value_column_indexes, target, options ){
		var aggregate_columns = []
		$.each(value_column_indexes, function(key, value){
			aggregate_columns.push({
	            column: value.column,
	            type: 'number',
	            label: value.label,
	            aggregation: function(values){
	                values = values.filter(Number)
	                var sum = 0;
	                for (var i = 0; i < values.length; i++) {
	                    sum += values[i];
	                }                    
	                return sum
	            }
	        })
		})

		var pieChartOptions = options

		var pieChartDateView = new google.visualization.DataView(source);
		var pieChartDateView = google.visualization.data.group(pieChartDateView, [group_by_index], aggregate_columns)    
	    var pieChart = new google.visualization.PieChart(document.getElementById(target));  
		pieChart.draw(pieChartDateView, pieChartOptions);

	},
	GeoChart: function(source, group_by_index, value_column_indexes, target, options ){	
		var aggregate_columns = []
		$.each(value_column_indexes, function(key, value){		
			aggregate_columns.push({
	            column: value.column,
	            type: 'number',
	            label: value.label,
	            aggregation: function(values){
	                values = values.filter(Number)
	                var sum = 0;
	                for (var i = 0; i < values.length; i++) {
	                    sum += values[i];
	                }                    
	                return sum
	            }
	        })		
		})
		var geoChartDateView = new google.visualization.DataView(source);
		var geoChartDateView = google.visualization.data.group(geoChartDateView, [group_by_index], aggregate_columns)    
	    var geoChart = new google.visualization.GeoChart(document.getElementById(target));  
		geoChart.draw(geoChartDateView, options);
	}
}