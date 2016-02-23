var mongoose = require("mongoose");
var Conversation = mongoose.model("Conversation");
var User = mongoose.model("User");

module.exports = function (io) {
    return {
        index: function (req, res) {
            if (!req.session.user) {
                res.json(null);
                return;
            }
            User.findById(req.session.user._id)
            // .select("conversations")
            .populate("conversations")
            .exec(function (error, user) {
                if (error) { console.log(error); }
                user.deepPopulate(["conversations.users"], function (error, userB) {
                    if (error) { console.log(error); }
                    res.json(userB.conversations);
                });
            });
        },
        create: function (req, res) {
            var sUser = req.session.user;
            if (!sUser) { res.json({ conversation: null, error: "Not Logged In." })}
            var conversation = new Conversation({
                users: req.body
            });
            conversation.save(function (error, conversation) {
                if (error) { console.log(error); }
                res.json(conversation._id);
                conversation.users.forEach(function (cUser) {
                    User.findById(cUser, function (error, user) {
                        if (error) { console.log(error); }
                        user.conversations.push(conversation._id);
                        user.save(function (error) {
                            if (error) { console.log(error); } else { console.log("Successfully Saved Convo:", user);}
                        });
                    });
                });
            });
        },
        show: function (req, res) {
            Conversation.findById(req.params.id)
            .deepPopulate("users messages._user")
            .exec(function (error, conversation) {
                if (error) { console.log(error); }
                // console.log(conversation);
                res.json(conversation);
            });
        }
    };
}; 