/*$(document).ready(function(){*/
  //$('#search_lnk').click(function(){
    //$('#search').toggle();
  //});
/*});*/

function tracker(number){
  $.ajax({
    url: '/tracker/'+number,
    timeout: 10000,
    error: function(jqXHR,textStatus,errorThrown){
      alert("The following error occurred: "+errorThrown+", Message: "+textStatus);
    },
    success: function(data){
      console.log(data);
    }
  });
}
