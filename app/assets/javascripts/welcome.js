function slideRight(e) {
  e.preventDefault();

 $("#carousel ul").animate({marginLeft:-1200},1500,function(){
    $(this).find("li:last").after($(this).find("li:first"));
    $(this).css({marginLeft:0});
  });
}

function goHome() {

    var hostName = 'http://' + window.location.hostname;
    var localhost = '';

    // so the URL succeeds for testing and development
    if ( hostName.match(/localhost/) ) {
      localhost = ':3000';
    }
    
    window.location.replace(hostName + localhost);
}

$(document).ready(function(){

  // pull user quotes asynchronously while user is on the welcome page
  if ( window.location.pathname.match(/\/welcome/) ) {
    $.ajax({
      url: '/retrieve_quotes',
      type: 'GET'
    });
  }

  $('.slide-next').on('click', slideRight);
  $('.slide-done').on('click', goHome);

});