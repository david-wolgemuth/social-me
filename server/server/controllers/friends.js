var mongoose = require("mongoose");
var User = mongoose.model("User");

module.exports = function (io) {
    return {
        index: function (req, res) {
            var user = req.session.user;
            User.findById(user._id, function (error, user) {
                if (error) { console.log(error); }
                var friends = [];
                if (user) {
                    user.friends.forEach(function (friendship) {
                        if (friendship.confirmed) {
                            friends.push(friendship.friendId);
                        }
                    });
                }
                User.find({
                    "_id": { $in: friends }
                })
                .select("handle")
                .exec(function (error, users) {
                    if (error) { console.log(error); }
                    console.log(users);
                    res.json(users);
                });
            });
        },
        create: function (req, res) {
            // Not Logged In, Friend Not Found, Already Friends, Not Confirmed, Confirmed
            console.log("Yo?");
            var userId = req.session.user._id;
            var friendId = req.body.id;
            if (!userId || !friendId) {
                console.log("Missing Id?"); return;
            }
            User.findById(userId, function (error, user) {
                if (error) { console.log(error); }
                User.findById(friendId, function (error, friend) {
                    if (error) { console.log(error); }
                    if (!friend || !user) {
                        console.log("No User Found?"); 
                        res.json(null);
                        return; 
                    }
                    var confirmed = false;
                    var alreadyFriends = false;
                    friend.friends.forEach(function (friendship) {
                        console.log("IDS:", friendship.friendId, String(user._id), (String(friendship.friendId) == String(user._id)) );
                        if (String(friendship.friendId) == String(user._id)) {
                            console.log("Confirmed!!");
                            if (friendship.confirmed) {
                                console.log("Already Friends");
                                alreadyFriends = true;
                                return;
                            }
                            confirmed = true;
                            friendship.confirmed = true;
                        }
                    });
                    if (alreadyFriends) {
                        res.json({ confirmed: true });
                        return;
                    }
                    user.friends.push({ friendId: friend._id, confirmed: confirmed});
                    user.save(function (error) {
                        if (error) { console.log(error); }
                        friend.save(function (error) {
                            if (error) { console.log(error); }
                            console.log("User:", user);
                            console.log("Friend:", friend);
                            if (io.users[friend._id]) {
                                io.users[friend._id].emit("friendRequest", 
                                    { user_id: user._id, confirmed: confirmed }
                                );
                            }
                            res.json({ confirmed: confirmed });
                        });
                    });
                });
            });
        },
        requests: function (req, res) {
            var user = req.session.user;
            User.findById(user._id, function (error, user) {
                if (error) { console.log(error); }
                var requests = [];
                if (user) {
                    user.friends.forEach(function (friendship) {
                        console.log(friendship);
                        if (!friendship.confirmed) {
                            requests.push(friendship.friendId);
                        }
                    });
                }
                User.find({
                    "_id": { $in: requests }
                })
                .select("handle")
                .exec(function (error, users) {
                    if (error) { console.log(error); }
                    console.log(users);
                    res.json(users);
                });
            });
        },
    };
};