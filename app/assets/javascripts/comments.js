var Comment = {
	commentChain: [],

	formHTML: function(quoteId){
		return "<form class='comment-form' action='/quotes/" + quoteId + "/comments/create' method='post'> " +
		  "<textarea class='comment-box' name='comment' placeholder='Your comment here' /></textarea><br />" +
		  "<input name='commit' type='submit' value='Submit Comment' />" +
		"<input value='Cancel' type='button' class='cancel-comment'/></form>";
	},

	commentHTML: function(commentId, content, user, isLoggedIn) {
		var html = "<div data-comment-id='" + commentId + "' class='quote-comment'>" +
				"<div class='comment-content'>" + content + "</div>" +
				"<div>Posted by: " + user + "</div>";

		if (isLoggedIn) {
			html = html + "<button class='reply-comment'>Reply</button>";
		} 
		return html + "</div>";
	},

	hiddenCommentHTML: function(commentId, content, user, isLoggedIn) {
		var html = "<div style='display:none' data-comment-id='" + commentId + "' class='quote-comment'>" +
				"<div class='comment-content'>" + content + "</div>" +
				"<div>Posted by: " + user + "</div>";
		if (isLoggedIn) {
			html = html + "<button class='reply-comment'>Reply</button>";
		} 
		return html + "<button class='more-comments'></button></div>"
	},

	lastHiddenCommentHTML: function(commentId, content, user, isLoggedIn) {
		var html = "<div style='display:none' data-comment-id='" + commentId + "' class='quote-comment'>" +
				"<div class='comment-content'>" + content + "</div>" +
				"<div>Posted by: " + user + "</div>";
		if (isLoggedIn) {
			html = html + "<button class='reply-comment'>Reply</button>";
		} 
		return html + "</div>";
	},

	replyFormHTML: function(commentId){
		return "<form class='reply-comment-form' action='/quotes/comments/" + commentId + "/create' method='post'> " +
		  "<textarea class='reply-comment-box' name='reply' placeholder='Your reply here' /></textarea><br />" +
		  "<input name='commit' type='submit' value='Submit Reply' />" +
		"<input value='Cancel' type='button' class='cancel-reply'/></form>";
	},

	// display the add comment form to the user
	displayForm: function(selector, quoteId) {
		var html = this.formHTML(quoteId);
		$(selector).append(html);
	}, 

	// display the add reply form to the user
	displayReplyForm: function(selector, commentId) {
		var html = this.replyFormHTML(commentId);
		$(selector).children(".less-comments").after(html);
		$(selector).children(".more-comments").after(html);
		if ($(selector).children(".more-comments").length == 0 && $(selector).children(".less-comments").length == 0) {
			$(selector).children(".reply-comment").after(html);
		}
	},

	// let the user briefly know if comment was saved successfully
	// this needs to be changed later. right now, the success status is prepended to the top of the page
	displayMessage: function(message) {
		$("form.comment-form").remove();
		$("form.reply-comment-form").remove();
		
		// $("body").prepend("<div class='add-comment-response'>" + message + "</div>");

		// setTimeout(function() {
		//   $("div.add-comment-response").remove();
		// }, 1000);
	},

	appendResponse: function(response) {
		if (response.isSuccess) {
			// if direct comment to a quote..., else is a reply to a comment
			if (!(response.quote_id == null) && response.parent_id == null) {
				$("div.quote-comments").append(this.commentHTML(response.comment_id, response.comment_content, response.user));
			} else {
				// if the parent div does not have a hide/see replies button, add it
				var parentDiv = $("div[data-comment-id="+response.parent_id+"]") 
				if (parentDiv.children("button.less-comments").length == 0 && parentDiv.children("button.more-comments").length == 0) {
					parentDiv.append("<button class='less-comments'></button>");
				}
				parentDiv.append(this.commentHTML(response.comment_id, response.comment_content, response.user));
			}
			this.displayMessage("Comment/Reply Saved Successfully");
		} else {
			this.displayMessage("Unable to Save Comment/Reply");
		}

	},

	// send an ajax request to save the user's comment
	ajaxRequestToAdd: function(comment, action) {
		var ajaxRequest = $.ajax({
			url: action,
			type: "post",
			data: {comment: comment, authenticity_token: AUTH_TOKEN}
		});

		ajaxRequest.always(this.appendResponse.bind(this));

	},

	appendCommentChain: function(isLoggedIn){
		for (var i = 0; i < this.commentChain.length; i++) {
			for (var j = 0; j < this.commentChain[i].replies.length; j++) {
				this.recursiveCall(this.commentChain[i].replies[j], isLoggedIn);
			}
		}
	},

	recursiveCall: function(comment, isLoggedIn) {
		if (comment.replies.length == 0) {
			$("div[data-comment-id="+comment.parent_id+"]").append(this.lastHiddenCommentHTML(comment.comment_id, comment.comment_content, comment.user, isLoggedIn));
		} else {
			$("div[data-comment-id="+comment.parent_id+"]").append(this.hiddenCommentHTML(comment.comment_id, comment.comment_content, comment.user, isLoggedIn));
			for (var i = 0; i < comment.replies.length; i++) {
				this.recursiveCall(comment.replies[i], isLoggedIn);
			}	
		}
	},

	removeForm: function(e) {
		$(e.target).parent().remove();
	}

}

$(document).ready(function(){
	// when user adds a comment
	$("div.quotes, .show-quote").on("click", "button.add-comment", function(e){
		e.preventDefault();
		$("form.comment-form").remove();
		Comment.displayForm($(e.target).parent().parent(), $(e.target).attr("data-quote-id"));
	});

	// when user submits a comment
	$("div.quotes, .show-quote").on("submit", "form.comment-form", function(e){
		e.preventDefault();
		var comment = $(e.target).children("textarea.comment-box").val();
		var action = $(e.target).attr("action");
		Comment.ajaxRequestToAdd(comment, action);
	});	

	// from quote show page, user can reply to a comment
	$("div.quote-comments").on("click", "button.reply-comment", function(e){
		e.preventDefault();
		$("form.reply-comment-form").remove();
		var parentCommentId = $(e.target).parent().attr("data-comment-id");
		Comment.displayReplyForm($(e.target).parent(), parentCommentId)
	});

	// from quote show page, user submits a reply to a comment
	$("div.quote-comments").on("submit", "form.reply-comment-form", function(e){
		e.preventDefault();
		var reply = $(e.target).children("textarea.reply-comment-box").val();
		var action = $(e.target).attr("action");
		Comment.ajaxRequestToAdd(reply, action);
	});

	// user cancels adding a comment or a reply
	$("div.quotes, .show-quote").on("click", ".cancel-comment", Comment.removeForm.bind(this));
	$("div.quote-comments").on("click", ".cancel-reply", Comment.removeForm.bind(this));

	// from quote show page, user can expand replies for a comment
	$("div.quote-comments").on("click", "button.more-comments", function(e){
		e.preventDefault();
		$(e.target).parent().children('div.quote-comment').show();
		$(e.target).removeClass("more-comments");
		$(e.target).addClass("less-comments");
	});

	// from quote show page, user can collapse replies for a comment
	$("div.quote-comments").on("click", "button.less-comments", function(e){
		e.preventDefault();
		$(e.target).parent().children('div.quote-comment').hide();
		$(e.target).removeClass("less-comments");
		$(e.target).addClass("more-comments");
	});

	// if user is on the quote show page, send an ajax request to get all comment replies
	if ($("div.quote-comments").length > 0) {
		var commentIds = [];
		var comments = $("div.quote-comments").children(".quote-comment");

		for (var i = 0 ; i < comments.length; i++) {
			commentIds.push(comments[i].getAttribute("data-comment-id"))
		}

		var ajaxRequest =  $.ajax({
			url: "/comments/replies",
			type: "GET",
			data: { comment_ids: commentIds }
		});

		ajaxRequest.always(function(response){
			Comment.commentChain = response.comments;
			Comment.appendCommentChain(response.isLoggedIn);
		});
	}

})