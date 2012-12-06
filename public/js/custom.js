/*$(document).ready(function(){*/
  //$('#search_lnk').click(function(){
    //$('#search').toggle();
  //});
/*});*/

function tracker(number){
  $.ajax({
    url: '/tracker/'+number,
    timeout: 25000,
    beforeSend: function(jqXHR, setting){
      $('#responseModalContent').html("<div style='text-align: center; padding: 20px 0 20px 0;'><p>Connecting to Google Docs API...</p><img src='img/ajax-loader.gif' /></div>");
      $('#responseModal').modal();
    },
    error: function(jqXHR,textStatus,errorThrown){
      $('#responseModalContent').html("The following error occurred: "+errorThrown+", Message: "+textStatus);
    },
    success: function(data){
      $('#responseModalContent').html(data);
    }
  });
}
