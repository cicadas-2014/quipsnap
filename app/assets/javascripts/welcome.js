var Welcome = {

  init: function() {
    $('.slide-next').on('click', this.slideRight);
    $('.slide-done').on('click', this.goHome);
  },

  slideRight: function(e) {
    e.preventDefault();

   $("#carousel ul").animate({marginLeft:-1200},1500,function(){
      $(this).find("li:last").after($(this).find("li:first"));
      $(this).css({marginLeft:0});
    });
  },

  goHome: function(e) {
    var hostName = 'http://' + window.location.hostname;
    var localhost = '';

    // generate URL for testing and development
    if ( hostName.match(/localhost/) ) {
      localhost = ':3000';
    }
    
    window.location.replace(hostName + localhost);
  }

};



$(document).ready(function(){

  Welcome.init();

  // pull user quotes asynchronously while user is on the welcome page
  if ( window.location.pathname.match(/\/welcome/) ) {
    $.ajax({
      url: '/retrieve_quotes',
      type: 'GET'
    });
  }

});