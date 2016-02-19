var mongoose = require("mongoose");
var User = mongoose.model("User");

module.exports = function (io) {
    return {
        index: function (req, res) {
            console.log("Search Query:", req.query);
            if (req.query.user) {
                var user = req.query.user;
                User.findOne({
                    $or: [
                       { handle: user }, { email: user }
                    ]}, function (error, foundUser) {
                            if (error) { console.log(error); }
                            if (foundUser) {
                                console.log(foundUser);
                                res.json({ _id: foundUser._id, handle: foundUser.handle });
                            } else {
                                res.json(null);
                            }
                    }
                );
            } else {
                User.find({}).select("handle").exec(function (error, users) {
                    if (error) { console.log(error); }
                    res.json(users);
                });
            }
        },
        login: function (req, res) {
            var info = req.body;
            console.log("Login Attempt:", info);
            // info = { user: "david@wolgemuth.com", password: "abc123" };
            User.findOne({
                $or: [
                   { handle: info.user }, { email: info.user }
                ]}, function (error, user) {
                        if (error) { console.log(error); }

                        if (!user) {
                            res.json({ user: null });
                            return;
                        }
                        user.comparePassword(info.password, function (error, success) {
                            if (error) {
                                console.log(error);
                            } else if (success) {
                                var sUser = { _id: user._id, handle: user.handle };
                                req.session.user = sUser;
                                console.log("Logged In!");
                                res.json({ user: sUser });
                            } else {
                                res.json({ user: null });
                            }
                        });
                    }
                );
        },
        logout: function (req, res) {
            req.session.destroy();
            console.log("Logged Out");
            console.log(req.session);
            res.json();
        },
        current: function (req, res) {
            console.log("Sess User:", req.session);
            res.json(req.session.user);
        },
        show: function (req, res) {
            User.findById(req.params.id, function (error, user) {
                if (error) { console.log(error); }
                res.json(user);
            });
        },
        create: function (req, res) {
            var info = req.body;
            User.find({ $or: [
                    { "handle": info.handle }, { "email": info.email}
                ]}, function (error, users) {
                    if (error) { console.log(error); }
                    if (users.length) {
                        res.json({ success: false });
                        return;
                    }
                    var user = new User({
                        email: info.email,
                        handle: info.handle,
                        password: info.password
                    });
                    user.save(function (error, user) {
                        if (error) {
                            console.log(error);
                        } else {
                            console.log(user);
                            res.json({ success: true });
                        }
                    });
            });
        }
    };
}; 