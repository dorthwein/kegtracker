function openPopupWindow(url){
	$(".jqxWindowIFrame").attr('src',url);		   
	$(".jqxWindow").jqxWindow('open');
	$('#content').addClass('modal-blur');
}

function jqxIntialize(){
	var theme = settings.theme		
	// Grid Column show/hide
	if($('.jqxGrid').length && 	$(".jqxGridColumnListBox").length){		
		var listSource = [];
		$.each( $('.jqxGrid').jqxGrid('columns'), function(key, item){			
			listSource.push({ label: item.text, value: item.datafield, checked:true })
		})

	    $(".jqxGridColumnListBox").jqxListBox({ 	    	
	    	source: listSource,     	
	    	height: jqxGridColumnListBoxHeight(), 
	    	width:'85%',
	    	theme: theme, 
	    	checkboxes: true,
	    });
	   
	    $(".jqxGridColumnListBox").on('checkChange', function (event) {
	        if (event.args.checked) {
	            $(".jqxGrid").jqxGrid('showcolumn', event.args.value);
	        }
	        else {
	            $(".jqxGrid").jqxGrid('hidecolumn', event.args.value);
	        }
	    });	
	}

    $('.jqxWindow').jqxWindow({
        showCollapseButton: false, 
        resizable:false,
        height: 550, 
        width: '960px', 
        draggable: false,
        theme: theme,
        autoOpen:false,
    });

	$('.jqxWindow').on('close', function (event) {	
		$('.jqxWindowIFrame').attr('src', "");
		$('.jqxWindowTitleText').html('<br />');
		$('#content').removeClass('modal-blur'); 
	 }); 

	$('.jqxRecordLinkButton').on('click', function(){
		var base_url = $(this).attr('data-url')
		var id = $(this).data('data-id')
		var url = system.server + base_url + id
		window.location = url
	})
	$(".new").jqxButton({ theme: theme });            
	$(".new").click(function () {
		var url = location.href
		url = url.replace("/new","");
		url = url.replace("/edit","");
		if($(this).attr('data-resource') == undefined){
//			window.open(url + "/new", "_blank", system.popup_settings);	        	
			$(".jqxWindowIFrame").attr('src',url + '/new');
			$('.jqxWindow').jqxWindow('open');
		}else {
			// To be redone
			url = url + '/' + $(this).attr('data-resource')			
			window.open(url + "/new", "_blank", system.popup_settings)
		}
	});

	$(".delete").jqxButton({ theme: theme });            
	$(".delete").click(function () {	
		var rowindex = $('.jqxGrid').jqxGrid('getselectedrowindex');
		var rowdata = $('.jqxGrid').jqxGrid('getrowdata', rowindex);		
		$.ajax({
			type: "DELETE",
			dataType : "JSON",
			url: location.href + '/' + rowdata['_id'],
			data: { 
				_id: rowdata['_id'],
			},
		}).done(function( data ) {
			window.dataAdapter.dataBind();
		});		        	
	});

	// Button Processing/Action	
	// NEW BUTTON
	$(".excelExport").jqxButton({ theme: theme});
	$(".excelExport").click(function () {		
		$(".jqxGrid").jqxGrid('exportdata', 'xls', 'BreweryApps'); //, true, null, false, 'http://localhost:3000');           

// The first parameter of the export method determines the export’s type – ‘xls’, ‘xml’, ‘html’, ‘json’, ‘tsv’ or ‘csv’.
// The second parameter is the file’s name.
// The third parameter is optional and determines whether to export the column’s header or not. Acceptable values are – true and false. By default, the exporter exports the columns header.
// The fourth parameter is optional and determines the array of rows to be exported. By default all rows are exported. Set null, if you want all rows to be exported.
// The last parameter is optional and determines the url of the export server. By default, the exporter is hosted on the jQWidgets website.		
	});
	
	$(".jqxFilterToggle").jqxToggleButton({ theme: theme});
	$(".jqxFilterToggle").click(function () {
    	if ($(this).attr("disabled") != "disabled"){
    		
	        var toggled = $(this).jqxToggleButton('toggled');	        
	        if (toggled) {	            
	        	$(".jqxGrid").jqxGrid({filterable:true, showfilterrow:true})
				$(".jqxGrid").jqxGrid('render');	        	
	        	$(this).html('Filter On');	        		        	
	        } else {	        	
				$(".jqxGrid").jqxGrid({filterable:false, showfilterrow:false})
				$('.jqxGrid').jqxGrid('clearfilters');
				$(".jqxGrid").jqxGrid('render');
				$(this).html('Filter Off');	        	
	        }

	    }		           
	});


	$(".jqxInput").jqxInput({height: '20px', width: '200px', minLength: 1, theme: theme });	
	$(".jqxNumberInput").jqxNumberInput({height: '20px', digits: 4, width: '200px', minLength: 1, theme: theme});
	$(".jqxNumberInput.currency").jqxNumberInput({decimalDigits: 2, symbol: '$'})	
	$(".jqxButton").jqxButton({ theme: theme, width:75 });            

	$(".jqxDateTimeInput").jqxDateTimeInput({ width: '200px', height: '20px', theme: theme });
	$(".jqxDropDownList").jqxDropDownList({ source: {}, valueMember: 'value', displayMember: 'html', width: '200px',  height: '20px', theme: theme });	
	

	$(".jqxListBox").jqxListBox({ source: {}, valueMember: 'value', displayMember: 'html', width: '200px',  height: '200px', theme: theme });	

	$(".jqxToggle").jqxToggleButton({ theme: theme });
    $(".jqxToggle").bind('click', function () {    	    	    
    	if ($(this).attr("disabled") != "disabled"){
	        var toggled = $(this).jqxToggleButton('toggled');
	        if (toggled) {
	            $(this).val(1);
	            $(this).html('On');
	        }
	        else {
	        	$(this).val(0);
	        	$(this).html('Off');
	        }
	    }
    });

    var form_rules = []
    if($('#password').length > 0){
	    form_rules.push({input: '#password', message:'Required!', action: 'keyup, blur', rule: function (input, commit) {
	    	if($('#password_confirmation').val().length == 0 && input.val() != 0){
	    		return false;
	    	} else{
	    		return true;
	    	}
	    }});
	    form_rules.push({input: '#password_confirmation', message:'Required!', action: 'keyup, blur', rule: function (input, commit) {
	    	if($('#password').val().length == 0 && input.val() != 0){
	    		return false;
	    	}else
	    	return true;
	    }})
	    form_rules.push({ input: '#password_confirmation', message: 'Passwords doesn\'t match!', action: 'keyup, focus', rule: function (input, commit) {
	        // call commit with false, when you are doing server validation and you want to display a validation error on this field. 
	        if (input.val() === $('#password').val()) {
	            return true;
	        }
	        return false;
	    }});
	}

	$.each($('.jqxDropDownList.required'), function(key, value){
		var id = '#' + value.id		
		form_rules.push({input: id, message: 'Required!', action: 'keyup, blur', rule: function(input, commit){									
			var item = $(element).jqxDropDownList('getSelectedItem')			
			var id = '#' + value.id		
			var element = $(id)

			if( $(element).jqxDropDownList('getSelectedItem') == null){
				return false
			} else return true
		}})		
	})

	$.each($('.jqxInput.required'), function(key, value){
		id = '#' + value.id
		form_rules.push({input: id, message: 'Required!', action: 'keyup, blur', rule: 'required'})
	})

	$.each($('.jqxNumberInput.required'), function(key, value){
		id = '#' + value.id
		form_rules.push({input: id, message: 'Required!', action: 'keyup, blur', rule: 'required'})
	})

    $('.jqxValidator').jqxValidator({rtl:true, rules: form_rules });
}
