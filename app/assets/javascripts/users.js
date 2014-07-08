var Users = {

  // Bind events to Bookclubs
  bind: function() {
    $('li').on('click', this.showQuotesForThisBookclub.bind(this));
    $('div.quotes').on('dblclick', 'div.quote', this.goToShowQuotePage.bind(this));
  },

  init: function(model) {
    this.bind();
    // this.renderList();
  },

  instructionsHover: function() {
    $('input.nav-signout').qtip({
        content: 'Signout',
        style: {
                 classes: 'qtip-green qtip-rounded'
              },
        position: {
                    my: 'top center',  // Position my top left...
                    at: 'bottom center', // at the bottom right of...
                    target: $('input.nav-signout') // my target
              }
        });
    $('input.nav-bookclubs').qtip({
        content: 'Bookclubs',
        style: {
                classes: 'qtip-green qtip-rounded'
              },
              position: {
                    my: 'top center',  // Position my top left...
                    at: 'bottom center', // at the bottom right of...
                    target: this // my target
              }
        }).bind(this);
    $('input.nav-favorites').qtip({
        content: 'Favorites',
        style: {
                classes: 'qtip-green qtip-rounded'
              },
              position: {
                    my: 'top center',  // Position my top left...
                    at: 'bottom center', // at the bottom right of...
                    target: this // my target
              }
        }).bind(this);
    $('input.nav-notebook').qtip({
        content: 'My Notebook',
        style: {
                classes: 'qtip-green qtip-rounded'
              },
              position: {
                    my: 'top center',  // Position my top left...
                    at: 'bottom center', // at the bottom right of...
                    target: this // my target
              }
        }).bind(this);
    $('input.nav-public').qtip({
        content: 'All Quotes',
        style: {
                classes: 'qtip-green qtip-rounded'
              },
              position: {
                    my: 'top center',  // Position my top left...
                    at: 'bottom center', // at the bottom right of...
                    target: this // my target
              }
        }).bind(this);
    $('button.liked-quote').qtip({
        content: 'Unfave',
        style: {
                classes: 'qtip-green qtip-rounded'
              },
              position: {
                    my: 'top center',  // Position my top left...
                    at: 'bottom center', // at the bottom right of...
                    target: this // my target
              }
        }).bind(this);
    $('button.unliked-quote').qtip({
        content: 'Fave this!',
        style: {
                classes: 'qtip-green qtip-rounded'
              },
              position: {
                    my: 'top center',  // Position my top left...
                    at: 'bottom center', // at the bottom right of...
                    target: this // my target
              }
        }).bind(this);
    $('button.share-quote').qtip({
        content: 'Share',
        style: {
                classes: 'qtip-green qtip-rounded'
              },
              position: {
                    my: 'top center',  // Position my top left...
                    at: 'bottom center', // at the bottom right of...
                    target: this // my target
              }
        }).bind(this);
    $('button.add-comment').qtip({
        content: 'Add Comment',
        style: {
                classes: 'qtip-green qtip-rounded'
              },
              position: {
                    my: 'top center',  // Position my top left...
                    at: 'bottom center', // at the bottom right of...
                    target: this // my target
              }
        }).bind(this);
    $('input.search').qtip({
        content: 'Search',
        style: {
                classes: 'qtip-green qtip-shadow qtip-rounded'
              },
              position: {
                    my: 'top center',  // Position my top left...
                    at: 'bottom center', // at the bottom right of...
                    target: this // my target
              }
        }).bind(this);
    $('select').qtip({
        content: 'Category',
        style: {
                classes: 'qtip-green qtip-shadow qtip-rounded'
              },
              position: {
                    my: 'top center',  // Position my top left...
                    at: 'bottom center', // at the bottom right of...
                    target: this // my target
              }
        }).bind(this);
    
        
      },
  

  showQuotesForThisBookclub: function(e) {
    e.preventDefault();
    var bookclubId = e.target.id;

    $(".quotes").children().remove;


    var ajaxRequest = $.ajax({
      url: '/bookclubs/' + bookclubId,
      type: 'GET'
    });
    // when new bookclub is valid, show it on the page
    ajaxRequest.done(this.showBookclubQuotes.bind(this));
    // when new bookclub is invalid, show error message in console log for now
    ajaxRequest.fail(function(data){
      console.log(data.responseJSON.message);
    });

  },

  getQuoteHtml: function(quote, isFavorite) {
      var html = "<div class='quote' id='" + quote.id + "'>" +
        "<div class='content'><img src='/icons/openingquote.png'><p>" + quote.content + "</p><img src='/icons/closingquote.png'></div>" +
          "<div class='quote-info'><a class='search-author' data-method='post'" +
          "href='/?q%5Bauthor_name_cont%5D=" + encodeURI(quote.author_name) + "' rel='nofollow'>" + quote.author_name + "</a>"
      if (quote.book_title != "") {
        html = html + "<br/>" +
          "<a class='search-title' data-method='post'" +
          "href='/?q%5Bbook_title_cont%5D=" + encodeURI(quote.book_title) + 
          "' rel='nofollow'>" + quote.book_title + "</a>";
      }     

      html = html + "</div><a class='search-user' data-method='post'" + 
        "href='/?q%5Buser_goodreads_name_cont%5D="+ encodeURI(quote.user_name) + 
        "' rel='nofollow'>Created by: " + quote.user_name + "</a>" + 
        "<div class='quote-options'>" + 
        "<button class='share-quote'>Share Quote</button>";

      if (isFavorite) {
        html = html + "<button class='liked-quote'></button>";
      } else {
        html = html + "<button class='unliked-quote'></button>";
      }

      html = html + "<button data-quote-id='" + quote.id + "' class='add-comment'>Add Comment</button></div></div>";

      return html;
  },

  showBookclubQuotes: function(response) {

    var quoteHTML = "";

    var quotes = response.quotes;
    var favs = response.is_favorites;

    for (var i=0; i<quotes.length; i++) {
      quoteHTML += this.getQuoteHtml(quotes[i], favs[i]);
    }
    
    $('.quotes').html(quoteHTML);
    makeDraggable();
  },

  // redirect the user to the quote show page upon double click
  goToShowQuotePage: function(e) {
    var quoteId = $(e.target).closest('div.quote').attr('id');
    window.location = "/quotes/" + quoteId;
  }
};

  

//On document load
$(document).ready(function(){
  Users.init();
  Users.instructionsHover();
});