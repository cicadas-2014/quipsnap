var Quote = {

	bind: function() {
		// $(window).on('scroll', this.getMoreQuotesAjax.bind(this));
	},

	init: function() {
		this.bind();
	},

	// getMoreQuotesAjax: function() {
	// 	var more_quotes_url;
	// 	more_quotes_url = $('.pagination .next_page').attr('href');
	// 	if (more_quotes_url && $(window).scrollTop() > $(document).height() - $(window).height() - 60) {
	// 		$('.pagination').html('<img src="/assets/ajax-loader.gif" alt="Loading..." title="Loading..." />');
	// 		$.getScript(more_quotes_url);
	// 	}
	// },

	// make quote draggable and droppable to add to bookclub
	addToBookclub: function(quoteId,bookclubId,bookclubDiv) {
		var ajaxRequest = $.ajax({
			url: '/bookclubs/' + bookclubId + '/quotes/' + quoteId,
			type: "post"
		});


		ajaxRequest.done(function(response){
			if (response.quote_added == false) {
				bookclubDiv.addClass("``mouse-drop-false");
				bookclubDiv.removeClass("mouse-drop-false",1000)
				$("div.failure").fadeIn(300);
				$("div.failure").fadeOut(1600);
			}
			else {
				bookclubDiv.addClass("mouse-drop-true");
				bookclubDiv.removeClass("mouse-drop-true",1000);
				$("div.success").fadeIn(300);
				$("div.success").fadeOut(1800);
			}
		});

		ajaxRequest.fail(function(response){
		})
	},


	offOfBookclub: function(event,ui) {
		ui.draggable.mouseup(function(){
			var top = ui.draggable.data('orgTop');
			var left = ui.draggable.data('orgLeft');
			ui.position = { top: top, left: left };
		});
	}

};

var makeDraggable = function() {
	$("div.quote").draggable({
		revert: function(dropped){
			var dropped = dropped && dropped[0].id == "droppable";
			return !dropped;
		},
		start: function(e, ui) { $(this).css('z-index', 1);},
		stop:  function(e) { $(this).css('z-index', 0); },					
		revertDuration: 150
	}).each(function() {
		var top = $(this).position().top;
		var left = $(this).position().left;
		var quoteId = $(this).attr("id")
		$(this).data('orgTop', top);
		$(this).data('orgLeft', left);

	});

	//quote can be dropped on bookclub li and will be added to bookclub quotes
	$("li").droppable({
		hoverClass: "mouse-hover",
		tolerance: 'pointer',
		drop:function(event,ui) {
			var quoteId = $(ui.draggable).attr("id");
			var bookclubId = $(this).attr("id");
			var bookclubDiv = $(this)
			Quote.addToBookclub(quoteId,bookclubId,bookclubDiv);
			
		},
		over:Quote.almostToBookclub,
		out:Quote.offOfBookclub

	});

};

$(document).ready(function(){
	//quote is a draggable object that reverts back to original position
	makeDraggable();
	// a quote on /quotes/:id should not be draggable 
	$(".show-quote").children(".quote").draggable("destroy");
	// Quote.init();
})

