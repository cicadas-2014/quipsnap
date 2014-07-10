var ShareQuotes = {

  init: function() {
    $('.quotes').on('click', '.share-quote', this.showUrl);
    $('.container').on('click', this.removeShare);
    $('.show-quote').on('click', '.share-quote', this.showUrlSinglePage);
  },

  showUrl: function(e) {
    e.preventDefault();

    var index = $(e.target).closest('.quote').index();
    var quoteId = $(e.target).closest('.quote').attr('id');
    var hostName = 'http://' + window.location.hostname;
    var localhost = '';
    // so the URL succeeds for testing and development 
    if ( hostName.match(/localhost/) ) {
      localhost = ':3000';
    }

    var url = hostName + localhost + '/quotes/' + quoteId;
    var html = "<div class='share-link'><input type='text' value='" + url + "'/></div>";

    $('.quotes').children(':eq(' + index + ')').after(html);

  },

  showUrlSinglePage: function(e) {
    e.preventDefault();

    var index = $(e.target).closest('.quote').index();
    var quoteId = $(e.target).closest('.quote').attr('id');
    var hostName = 'http://' + window.location.hostname;
    var localhost = '';
    if ( hostName.match(/localhost/) ) {
      localhost = ':3000';
    }
    var url = hostName + localhost + '/quotes/' + quoteId;
    var html = "<div class='share-link'><input type='text' value='" + url + "'/></div>";
    
    $('.show-quote').children(':eq(' + index + ')').after(html);
  },

  removeShare: function(e) {

    if ($(e.target).attr('class') != 'share-quote' &&
        !($(e.target).is('input'))) {
      $('.share-link').remove();
    }
  }

};

$(document).ready(function() {
  ShareQuotes.init();
});