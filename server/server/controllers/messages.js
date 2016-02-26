var mongoose = require("mongoose");
var Message = mongoose.model("Message");
var Conversation = mongoose.model("Conversation");
var Image = require("./../controllers/images.js")();

module.exports = function (io) {
    return {
        create: function (req, res) {
            var user = req.session.user;
            if (!user) {
                console.log("Not Logged In?");
                return;
            }
            var message = new Message({
                _user: user._id,
                _conversation: req.body.conversationId,
                image: Boolean(req.body.image),
                content: req.body.content
            });
            console.log(req.body.image);
            message.save(function (error, savedMessage) {
                if (error) { console.log(error); }

                Conversation.findById(savedMessage._conversation, function (error, conversation) {
                    if (error) { console.log(error); }

                    if (savedMessage.image) {
                        Image.writeMessageImage(req.body.image, savedMessage._id);
                    }

                    conversation.messages.push(savedMessage._id);
                    conversation.save(function (error, savedConversation) {
                        savedMessage.deepPopulate("_user", function () {
                            conversation.users.forEach(function (user_id) {
                                console.log("Should I emit to", user_id);
                                if (io.users[user_id]) {
                                    io.users[user_id].emit("newMessage", { 
                                        message: savedMessage._id, 
                                        conversation: conversation._id 
                                    });
                                    console.log("Emitting to:", user_id);
                                }
                            });
                            res.json(savedMessage);
                        });
                    });
                });
            });
        },
        show: function (req, res) {
            console.log(req.params.id);
            Message.findById(req.params.id)
            .deepPopulate("_user")
            .exec(function (error, message) {
                res.json(message);
            });
        }
    };
}; 