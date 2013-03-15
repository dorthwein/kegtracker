$(document).on('pageshow', '.popup', function() {
	var title = $('.popup_title').html()
	window.parent.$('.jqxWindowTitleText').html(title);
});

function jqxIntialize(){
	var theme = settings.theme	
	$('.jqxGrid').off('rowdoubleclick');
	$('.jqxGrid').on('rowdoubleclick', function (event){
	    var column = event.args.column;	   
	    var rowindex = event.args.rowindex;
		var rowdata = $(this).jqxGrid('getrowdata', rowindex);

	    var columnindex = event.args.columnindex;

		var url = $('.ui-page-active').attr('data-url') + "/" + rowdata['_id'] + "/edit"

		$('.jqxWindow').jqxWindow('open');
		$(".jqxWindowIFrame").attr('src',url);		

//	    window.open(, "_blank", system.popup_settings);
	});

//	$('#jqxGrid').off('rowselect');
//	$('#jqxGrid').bind('rowselect', function (event){	    

//	});
	
	$('.jqxGrid').off('cellclick');
	$(".jqxGrid").on("cellclick", function (event) {
	    var column = event.args.column;	   
	    var rowindex = event.args.rowindex;
		var rowdata = $('.jqxGrid').jqxGrid('getrowdata', rowindex);

	    var columnindex = event.args.columnindex;
	    if(column.text == 'View'){	    	
			var url = $('.ui-page-active').attr('data-url') + "/" + rowdata['_id'] + "/edit"

			$('.jqxWindow').jqxWindow('open');
			$(".jqxWindowIFrame").attr('src',url);		    
//		    window.open($('.ui-page-active').attr('data-url') + "/" + rowdata['_id'] + "/edit", "_blank", system.popup_settings);
		}	    
	});       
    $('.jqxWindow').jqxWindow({
        showCollapseButton: false, 
        resizable:false,
        height: 550, 
        width: '960px', 
        draggable: false,
        theme: theme,
    });

	$('.jqxWindow').on('close', function (event) {
		$('.jqxWindowIFrame').attr('src', "");
		$('.jqxWindowTitleText').html('<br />');
	 }); 


	$(".new").jqxButton({ theme: theme, width:100 });            
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

	$(".delete").jqxButton({ theme: theme, width:100 });            
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
	$(".excelExport").jqxButton({ theme: theme,});                        
	$(".excelExport").click(function () {
		$(".jqxGrid").jqxGrid('exportdata', 'xls', 'jqxGrid');           
	});

	$(".jqxInput").jqxInput({height: '20px', width: '200ps', minLength: 1, theme: theme });	
	$(".jqxNumberInput").jqxNumberInput({height: '20px', digits: 4, width: '200px', minLength: 1, theme: theme});
	$(".jqxNumberInput.currency").jqxNumberInput({decimalDigits: 2, symbol: '$'})	
	$(".jqxButton").jqxButton({ theme: theme, width:75 });            

	$(".jqxDateTimeInput").jqxDateTimeInput({ width: '200px', height: '20px', theme: theme });
	$(".jqxDropDownList").jqxDropDownList({ source: {}, valueMember: 'value', displayMember: 'html', width: '200px',  height: '20px', theme: theme });	
	

	$(".jqxListBox").jqxListBox({ source: {}, valueMember: 'value', displayMember: 'html', width: '100%',  height: '200px', theme: theme });	

	$(".jqxToggle").jqxToggleButton({ theme: theme, width:'75px' });
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
	    form_rules.push({input: '#password', message:'Required!', action: 'keyup, blur', rule: 'required'});
	    form_rules.push({input: '#password_confirmation', message:'Required!', action: 'keyup, blur', rule: 'required'});
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