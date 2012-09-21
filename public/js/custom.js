/*$(document).ready(function(){*/
  //$('#search_lnk').click(function(){
    //$('#search').toggle();
  //});
/*});*/

function tracker(number){
  $.ajax({
    url: '/tracker/'+number,
    success: function(data){
      console.log(data);
    }
  });
}
