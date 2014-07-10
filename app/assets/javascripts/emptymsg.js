$(document).ready(function(){
  if (  $('.no-search-results').html() == "\n" ) {
    $('.no-search-results').remove();
  }
  if ( $('.no-favorites').html() == "\n" ) {
    $('.no-favorites').remove();
  }
  if ( $('.no-bookclub-quotes').html() == "\n" ) {
    $('.no-bookclub-quotes').remove();
  }
  if ( $('.no-user-quotes').html() ) {
    $('.no-user-quotes').remove();
  }
});