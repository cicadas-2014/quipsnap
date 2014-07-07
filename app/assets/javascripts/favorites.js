var quoteFavorites = {

	init: function() {
		// user favorites a quote
		$(".quotes").on("click", "button.unliked-quote", this.addToFavorites.bind(this));
		// user unfavorites a quote
		$(".quotes").on("click", "button.liked-quote", this.removeFromFavorites.bind(this));
	},

	displayLikeQuote: function (selector) {
		$(selector).removeClass("unliked-quote");
		$(selector).addClass("liked-quote");
	},

	displayUnlikeQuote: function(selector) {
		$(selector).removeClass("liked-quote");
		$(selector).addClass("unliked-quote");
	},

	addToFavorites: function(e) {
		e.preventDefault();
		this.displayLikeQuote(e.target);

		var quoteId = $(e.target).parent().parent().attr("id");
		var ajaxRequest = $.ajax({
			url: "/quotes/" + quoteId + "/favorite",
			type: "post"
		});
	},

	removeFromFavorites: function(e) {
		e.preventDefault();
		this.displayUnlikeQuote(e.target);

		var quoteId = $(e.target).parent().parent().attr("id");
		var ajaxRequest = $.ajax({
			url: "/quotes/" + quoteId + "/unfavorite",
			type: "delete"
		});
	}
};

$(document).ready(function(){
	quoteFavorites.init();
});