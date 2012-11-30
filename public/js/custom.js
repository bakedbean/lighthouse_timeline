/*$(document).ready(function(){*/
  //$('#search_lnk').click(function(){
    //$('#search').toggle();
  //});
/*});*/

function tracker(number){
  $.ajax({
    url: '/tracker/'+number,
    timeout: 25000,
    error: function(jqXHR,textStatus,errorThrown){
      $('#responseModalContent').html("The following error occurred: "+errorThrown+", Message: "+textStatus);
      $('#responseModal').modal();
    },
    success: function(data){
      $('#responseModalContent').html(data);
      $('#responseModal').modal();
    }
  });
}
