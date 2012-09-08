function tracker(number){
  $.ajax({
    url: '/tracker/'+number,
  }).done(function(data){
    alert(data);
  });
}
