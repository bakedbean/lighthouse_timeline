$(document).ready(function(){
  
  $('.ticket').mouseover(function(){
    
    $.ajax({
      url: '/ticket/'+$(this).html(),
      success: function(data){
        $('#detail').html(data);
      }
    });

  });

});
