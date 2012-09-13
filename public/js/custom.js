function tracker(number){
  $.ajax({
    url: '/tracker/'+number,
    success: function(data){
      console.log(data);
    }
  });
}
