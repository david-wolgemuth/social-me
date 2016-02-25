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
            console.log("Hit Create Method");
            var sUser = req.session.user;
            if (!sUser) { res.json({ conversation: null, error: "Not Logged In." }); }
            var usersInConvo = req.body.users;
            usersInConvo.push(sUser);
            title = req.body.title;
            var conversation = new Conversation({
                users: usersInConvo,
                title: title
            });
            conversation.save(function (error, conversation) {
                if (error) { console.log(error); }
                res.json({ conversation: conversation });
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
        update: function (req, res) {  // Add to Conversation
            var sUser = req.session.user;
            var nUserId = req.body.userId;
            if (!sUser || !nUserId) {
                console.log("Not Logged In, Or Missing Arguments In Body");
                return res.json({ success: false, error: "Not Logged In, Or Missing Arguments In Body" });
            }
            Conversation.findById(req.params.id, function(error, conversation) {
                if (error) { console.log(error); }
                if (conversation.users.indexOf(sUser.id) <= 0) {
                    console.log("User Not In Conversation (Doesn't Have Authority To Add Users)");
                    return res.json({ success: false, error: "User Not In Conversation (Doesn't Have Authority To Add Users)"});
                }
                conversation.users.push(nUserId);
                conversation.save(function (error) {
                    console.log("User Added:", conversation);
                    res.json({ success: true, conversation: conversation });
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