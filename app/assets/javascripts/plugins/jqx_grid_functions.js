function jqxIntialize(){
	var theme = settings.theme		
	// Grid Column show/hide
// ***********************
// jqxGrid Functions
// ***********************	

//	$(".jqxFilterToggle").jqxToggleButton({ theme: theme});

// ******************************
// jqxInput Formatting Functions
// ******************************
	$(".jqxInput").jqxInput({height: '20px', width: '200px', theme: theme });	
	$(".jqxNumberInput").jqxNumberInput({height: '20px', digits: 4, width: '200px', theme: theme});
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

// ******************************
// jqxValidator
// ******************************

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
	    form_rules.push({input: '#password', message:'Must be at least 6 letters!', action: 'keyup, blur', rule: function (input, commit) {
	    	if($('#password').val().length < 6){
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
