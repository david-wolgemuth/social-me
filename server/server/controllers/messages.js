var mongoose = require("mongoose");
var Message = mongoose.model("Message");
var Conversation = mongoose.model("Conversation");

module.exports = (function () {
    return {
        create: function (req, res) {
            var message = new Message({
                _user: req.body.userId,
                _conversation: req.body.conversationId,
                content: req.body.content
            });
            message.save(function (error, savedMessage) {
                if (error) { console.log(error); }
                Conversation.findById(savedMessage._conversation, function (error, conversation) {
                    if (error) { console.log(error); }
                    conversation.messages.push(savedMessage._id);
                    conversation.save(function (error, savedConversation) {
                        savedMessage.deepPopulate("_user", function () {
                            res.json(savedMessage);
                        });
                    });
                });
            });
        },
    };
})(); 