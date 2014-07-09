$(document).ready(function(){
  // when there is a login button AKA user is not signed in
  if (document.getElementsByClassName('nav-signin').length == 1) {
    $('.page-info').remove();
    $('.quotes').addClass('home-quotes');

    var hero = "<div class='hero-image'></div>";

    $('.quotes').before(hero);
  }
});