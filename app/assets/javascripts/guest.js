$(document).ready(function(){
  // when there is a login button AKA user is not signed in
  if (document.getElementsByClassName('nav-signin').length == 1) {

    $('.page-info').html('Check out some recently shared quotes');

    $('.quotes').addClass('home-quotes');

    var hero = "<div class='guest-image'><h1>Stay on the same page.</h1>" +
                "<h2>Share and discuss quotes from any Kindle app or device.</h2></div>";

    $('.page-info').before(hero);
  }
});