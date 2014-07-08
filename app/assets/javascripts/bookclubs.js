// Main script for /bookclubs
var Bookclubs = {

  // Finds the current user's id
  currentUserId: function() { return parseInt($('div.bookclubs-all').attr('data-current-user')); },

  // Bind events to Bookclubs
  bind: function() {
    $('.new_bookclub').on('submit', this.sendNewBookclubRequest.bind(this));
    $('.bookclubs-all').on('click', 'button.bookclub-join', this.sendJoinRequest.bind(this));
    $('#btn1').on('click', this.displayNewBookclubForm.bind(this));
    $('input#cancel').on('click', this.hideNewBookclubForm.bind(this));
  },

  init: function() {
    this.bind();
    this.renderList();
  },

  // Render list of bookclubs
  renderList: function() {
    // Fetch bookclubs on load
    var ajaxRequest = $.ajax({
      url: '/bookclubs/all',
      type: 'GET'
    });
    ajaxRequest.done(this.showBookclubListHtml.bind(this));
  },


  displayNewBookclubForm: function(e) {
    $("form#new_bookclub").show(500);
  },

  hideNewBookclubForm: function(e) {
    e.preventDefault();
    $("form#new_bookclub").hide(500);
  },

  // Prepare bookclubs list HTML
  bookclubsHtml: "<div class='bookclubs'>",

  // Return html for all bookclubs
  showBookclubListHtml: function(data) {
    var bookclubs = data.bookclubs;
    for(var i = 0; i < bookclubs.length; i++) {
      var bookclub = bookclubs[i];
      this.bookclubsHtml += this.getBookclubHtml(bookclub, this.currentUserId());
    }

    this.bookclubsHtml += "</div>";

    $('.bookclubs-all').prepend(this.bookclubsHtml);

  },

  // Return html for one bookclub
  getBookclubHtml: function(bookclub, currentUserId) {
    // If current user is not in the bookclub,
    // add a + so that the user can join the bookclub
    var joinBookclub = "";
    var belongTo = "";

    if ($.inArray(currentUserId, bookclub.user_ids) == -1) {
      joinBookclub = "<button class='bookclub-join'>Join</button>";
      belongTo = "class='bookclub-non'"
    } else {
      belongTo = "class='bookclub-belong'";
    }

    // If current user is the admin of the bookclub,
    // add a bookclub-admin class to the li
    if (currentUserId == bookclub.admin_id) {
      belongTo = belongTo.replace(/'$/, " bookclub-admin'");
    }

    var html =  "<a id='" +
                bookclub.id.toString() +
                "' href='/bookclubs/" +
                bookclub.id.toString() +
                "' " + 
                belongTo + 
                "><div class='bookclub-cover-top'></div><div class='bookclub-pages'><p>" +
                bookclub.name +
                ": " +
                bookclub.description +
                joinBookclub +
                "</p></div><div class='bookclub-cover-bottom'></div></a>";  

    return html;
  },

  // Request new bookclub creation
  sendNewBookclubRequest: function(e) {
    e.preventDefault();

    var newBook = $(e.target).serialize();

    var ajaxRequest = $.ajax({
      url: '/bookclubs',
      type: 'POST',
      data: newBook
    });
    // when new bookclub is valid, show it on the page
    ajaxRequest.done(this.showNewBookclub.bind(this));
    // when new bookclub is invalid, show error message in console log for now
    ajaxRequest.fail(function(data){
      console.log(data.responseJSON.message);
    });
  },

  showNewBookclub: function(data) {
    $("form#new_bookclub").hide();
    $('.bookclubs').append(this.getBookclubHtml(data.bookclub, this.currentUserId()));
    this.formFields().reset();
  },

  // Retrieve formFields for reset after submitting
  formFields: function() {
    return $('form.new_bookclub')[0];
  },

  // Request user to join bookclub
  sendJoinRequest: function(e) {
    e.preventDefault();

    // set id of bookclub to join
    var bookclubId = $(e.target).closest('.bookclub-non').attr('id');

    // remove + button after clicking join
    $(e.target).remove();

    var ajaxRequest = $.ajax({
      url: '/bookclubs/join',
      type: 'PUT',
      data: { bookclub_id: bookclubId }
    });
    ajaxRequest.done(this.showJoinBookclub.bind(this));
  },

  // data.bookclub_id can be used to access the li of the bookclub by id.
  showJoinBookclub: function(data) {
    $('li#' + data.bookclub_id.toString()).addClass('bookclub-belong');
  }

};

//On document load
$(document).ready(function(){
  Bookclubs.init();
});