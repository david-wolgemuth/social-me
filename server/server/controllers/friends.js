var mongoose = require("mongoose");
var User = mongoose.model("User");

module.exports = function (io) {
    var fCtrl = {};
    fCtrl.index = function (req, res) {
        if (req.query.user) {
            fCtrl.search(req, res);
        } else {
            fCtrl.getFriends(req, res);
        }
    };
    fCtrl.search = function (req, res) {
        console.log(req.query);
        User.find({
            handle: new RegExp(req.query.user, "i")
        }).lean().exec(function(error, users) {
            if (error) { console.log(error); } 
            var arr = [];
            console.log(users);
            users.forEach(function (user) {
                console.log(user.handle);
                user.isFriend = false;
                for (var i = 0; i < user.friends.length; i++) {
                    if (user.friends[i].friendId == req.session.user._id) {
                        console.log("Is Confirmed?", user.friends[i].confirmed);
                        if (user.friends[i].confirmed) {
                            user.isFriend = true;
                        } else {
                            user.isFriend = false;
                            user.requestSent = true;
                        }
                    }
                }
                arr.push({ _id: user._id, isFriend: user.isFriend, requestSent: Boolean(user.requestSent), handle: user.handle });
            });
            res.json(arr);
        });
    };
    fCtrl.requests = function (req, res) {
        fCtrl.getFriends(req, res, true);
    };
    fCtrl.getFriends = function (req, res, friendRequests) {
        var user = req.session.user;
        User.findById(user._id, function (error, user) {
            if (error) { console.log(error); }
            var friends = [];
            if (user) {
                user.friends.forEach(function (friendship) {
                    if (friendRequests) {
                        if (!friendship.confirmed) {
                            friends.push(friendship.friendId);
                        }
                    } else {
                        if (friendship.confirmed) {
                            friends.push(friendship.friendId);
                        }
                    }
                });
            }
            User.find({
                "_id": { $in: friends }
            })
            .select("handle")
            .exec(function (error, users) {
                if (error) { console.log(error); }
                console.log("Users:", users);
                res.json(users);
            });
        });
    };
    fCtrl.create = function (req, res) {
        var userId = req.session.user._id;
        var friendId = req.body.id;
        User.findById(userId, function (error, user) {
            if (error) { console.log(error); }

            for (var i = 0; i < user.friends.length; i ++) {
                if (user.friends[i].friendId.equals(friendId)) {
                    if (!user.friends[i].confirmed) {
                        console.log("Check your Friend Request");
                        res.json({
                            success: false,
                            error: "Please Confirm your Friend Request"
                        })
                        return;
                    }
                }
            }

            User.findById(friendId, function (error, friend) {
                if (error) { console.log(error); }
                if (!friend || !user || userId == friendId) {
                    console.log("No User Found?"); 
                    res.json({
                        success: false,
                        error: "Friend Not Found? User Not Logged In? Trying to Add Yourself?"
                    });
                    return;
                }
                for (var i = 0; i < friend.friends.length; i++) {

                    if (friend.friends[i].friendId.equals(user._id)){
                        if (friend.friends[i].confirmed) {
                            console.log("Already Friends");
                            res.json({
                                success: false,
                                error: "Already Friends"
                            })
                        } else {
                            console.log("Request Already Sent");
                            res.json({
                                success: false,
                                error: "Request Already Sent"
                            })
                        }
                        return;
                    }
                }
                friend.friends.push({ friendId: user._id, confirmed: false });
                friend.save(function (error) {
                    if (error) { 
                        console.log(error); 
                        res.json({ success: false, error: error });
                    } else {
                        res.json({ success: true });
                        if (io.users[friend._id]) {
                            io.users[friend._id].emit("friendRequest", 
                                { user: { _id: user._id, handle: user.handle }}
                            );
                        }
                    }                    
                });
            });
        });
    };
    fCtrl.update = function (req, res) {
        var friendId = req.params.id;
        var confirmed = req.body.confirmed;
    
        User.findById(req.session.user._id, function (error, user) {
            if (error) { console.log(error); }
            if (!user) { 
                return res.json({ success: false, error: "Not Logged In"}); 
            }
            console.log(req.body);
            if (confirmed == 'false' || !confirmed) {  // Ignore Request
                console.log("ignore");
                for (var i = 0; i < user.friends.length; i++) {
                    if (String(user.friends[i].friendId) == friendId) {
                        user.friends.splice(i, 1);
                        console.log("Removed");
                        break;
                    }
                }
                user.save(function (error) {
                    if (error) { 
                        console.log(error); 
                        res.json({ success: false, error: error });
                    } else {
                        res.json({ success: true });
                    }
                });
            } else {  // Make Friends
                User.findById(friendId,function(error,friend) {
                    if (error) {console.log(error);}
                    var found = false;
                    for (var i = 0; i <user.friends.length; i++) {
                        if (user.friends[i].friendId.equals(friend._id)) {
                            user.friends[i].confirmed = true;
                            found = true;
                            break;
                        }
                    }
                    if (!found) {
                        console.log("Not Found??");
                        res.json({success: false, error: "Friend Request Not Found?"});
                        return;
                    }  else {
                        friend.friends.push({friendId: user._id, confirmed: true});
                        friend.save(function(errorA) {
                            user.save(function(errorB) {
                                if (errorA || errorB) {
                                    console.log(errorA,errorB);
                                    res.json({success:false,error: JSON.Stringify([errorA, errorB]) });
                                } else {
                                    res.json({success: true});
                                    if (io.users[friend._id]) {
                                        io.users[friend._id].emit("friendAccepted", {user:{_id:user._id,handle: user.handle}});
                                    }
                                }
                            })
                        })
                    }

                })
            }
        });
    };
    return fCtrl;
};