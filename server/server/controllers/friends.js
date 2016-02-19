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
            console.log("Friend Request");
            var userId = req.session.user._id;
            var friendId = req.body.id;
            if (!userId || !friendId || friendId == userId) {
                console.log("Missing Id?"); res.json(null); return;
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
                    var respondingToRequest = false;
                    user.friends.forEach(function (friendship) {
                        if (String(friendship.friendId) == String(friend._id)) {
                            respondingToRequest = true;
                            friendship.confirmed = true;
                            confirmed = true;
                        }
                    });

                    var alreadyFriends = false;
                    var requestExists = false;
                    friend.friends.forEach(function (friendship) {
                        if (String(friendship.friendId) == String(user._id)) {
                            requestExists = true;
                            // Regardless Of If Res/Req, Will Confirm Friend On Other Side
                            if (friendship.confirmed) {
                                console.log("Already Friends");
                                alreadyFriends = true;
                                confirmed = true;
                            }
                            // friendship.confirmed = true;
                        }
                    });

                    // If Responding, Then Add Confirmed Friend to User
                    if (respondingToRequest) {
                        friend.friends.push({ friendId: user._id, confirmed: true });
                    } else if (alreadyFriends) {
                        console.log("Already Friends");
                    } else if (requestExists) {
                        console.log("Request Already Sent");
                    } else {  // New Request
                        friend.friends.push({ friendId: user._id, confirmed: false });
                    }

                    user.save(function (error) {
                        if (error) { console.log(error); }
                        friend.save(function (error) {
                            if (error) { console.log(error); }
                            console.log("User:", user._id, user.friends);
                            console.log("Friend:", friend._id, friend.friends);
                            if (io.users[friend._id]) {
                                io.users[friend._id].emit("friendRequest", 
                                    { user_id: user._id, confirmed: confirmed }  // true: accepted, false: requesting
                                );
                            }
                            console.log("Confirmed: ", confirmed);
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