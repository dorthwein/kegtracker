$(document).on('pageshow', '.popup', function() {
	var title = $('.popup_title').html()
	window.parent.$('.jqxWindowTitleText').html(title);
});

function openPopupWindow(url){
	$(".jqxWindowIFrame").attr('src',url);		   
	$('.jqxWindow').jqxWindow('open');
	$('#content').addClass('modal-blur'); 				
}

function jqxIntialize(){
	var theme = settings.theme	


	$('.jqxGrid').off('rowdoubleclick');
	$('.jqxGrid').on('rowdoubleclick', function (event){
/*		
	    var column = event.args.column;	   
	    var rowindex = event.args.rowindex;
		var rowdata = $(this).jqxGrid('getrowdata', rowindex);

	    var columnindex = event.args.columnindex;
		var url = $('.ui-page-active').attr('data-url') + "/" + rowdata['_id'] + "/edit"		
		alert(rowdata['cycle'])
		$('.jqxWindow').jqxWindow('open');
		$(".jqxWindowIFrame").attr('src',url);		
		$('#content').addClass('modal-blur'); 		
*/
//	    window.open(, "_blank", system.popup_settings);
	});

//	$('#jqxGrid').off('rowselect');
//	$('#jqxGrid').bind('rowselect', function (event){	    

//	});
	
	$('.jqxGrid').off('cellclick');
	$(".jqxGrid").on("cellclick", function (event) {
/*
	    var column = event.args.column;	   
	    var rowindex = event.args.rowindex;
		var rowdata = $('.jqxGrid').jqxGrid('getrowdata', rowindex);

	    var columnindex = event.args.columnindex;
	    $.each(event, function(key, value){
	    //	alert(key + '--' + value)
	    })	    
	    if(column.text == 'View'){	    	    
//		    window.open($('.ui-page-active').attr('data-url') + "/" + rowdata['_id'] + "/edit", "_blank", system.popup_settings);
		}	 
*/		   
	});       
	    
//
//	var listSource = [];
	// Grid Column show/hide
	if($('.jqxGrid').length && 	$(".jqxGridColumnListBox").length){
		var listSource = [];
		$.each( $('.jqxGrid').jqxGrid('columns'), function(key, item){
			listSource.push({ label: item.text, value: item.datafield, checked:true })
		})

	    $(".jqxGridColumnListBox").jqxListBox({ 
	    	rtl:false,
	    	source: listSource,     	
	    	height: system.full_window_table_height() - 100, 
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
		var url = $('.ui-page-active').attr('data-url')		
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
			url: system.server + $('.ui-page-active').attr('data-url') + '/' + rowdata['_id'],
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
		$(".jqxGrid").jqxGrid('exportdata', 'xls', 'jqxGrid');           
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

    $('.jqxValidator').jqxValidator({ rules: form_rules });
}



// not active but works if fired correctly
/*
$.each($('.jqxToolTip'), function(key, value){		
	var id = '#' + value.id		
	var tooltip = '#' + value.id		

	var id = id.substring(0, id.length - 8);
	var html = $(tooltip).html();

	$(id).jqxTooltip({ content: html, position: 'mouse', name:'test', theme: theme });
});
*/