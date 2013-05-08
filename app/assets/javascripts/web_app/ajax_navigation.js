//On load page, init the timer which check if the there are anchor changes each 300 ms   

$(document).ready(function(){   
    setInterval("checkAnchor()", 300);   
});   
function parseUrl(url){    
    if(url.hash){
        url = url.protocol+'//'+url.host + '' + currentAnchor.substring(1)   
    }
    return url   
}

var currentAnchor = null;   
//Function which chek if there are anchor changes, if there are, sends the ajax petition   
function checkAnchor(){   
    //Check if it has changes   
    if(currentAnchor != document.location.hash && document.location.hash != ''){   
        currentAnchor = document.location.hash;   

        //if there is not anchor, the loads the default section   
        if(!currentAnchor)   {

        } else {   
            //Creates the  string callback. This converts the url URL/#main&id=2 in URL/?section=main&id=2   
//            var splits = currentAnchor.substring(1).split('&');               
            //Get the section   
//            var section = splits[0];   
  //          delete splits[0];   
            //Create the params string   
    
//            var params = splits.join('&');   
  //          var query = "section=" + section + params;   
        }   
        
        var ajax_url = location.protocol+'//'+location.host + '/' + currentAnchor.substring(1)           
        $('#page_view').html(' Loading...')
        $.ajax({
            url: ajax_url,
            type: 'GET',
            data: {ajax_load:1}            
        }).done(function(data) {
            $('#page_view').html(data)            
            setViews();
        })

        //Send the petition   
//        $.get("callbacks.php",query, function(data){   
  //          $("#content").html(data);   
    //    });   
    }   
}  
$('a').on('tap',function(event){
    alert('t')
})
// Link Highjack
$(document).ready(function(){
    $('a').on('click tap',function(event){
        event.preventDefault();
        document.location.hash = $(this).attr('href')
    })    
});

