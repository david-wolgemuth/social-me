
var mongoose = require("mongoose");
var User = mongoose.model("User");
var Image = require("./../controllers/images.js")();

module.exports = function (io) {

    return {
        index: function (req, res) {
            if (req.query.user) {
                var user = req.query.user;
                User.findOne({
                    $or: [
                       { handle: user }, { email: user }
                    ]}, function (error, foundUser) {
                            if (error) { console.log(error); }
                            if (foundUser) {
                                res.json({ _id: foundUser._id, handle: foundUser.handle, profileImage: foundUser.profileImage});
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
                                var sUser = { _id: user._id, handle: user.handle,profileImage:user.profileImage };
                                req.session.user = sUser;
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
            res.json();
        },
        current: function (req, res) {
            User.findById(req.session.user._id, function (error, user) {
                if (error) { console.log(error); }
                res.json(user);
            });
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
                    res.json({ success: false ,error: "email or handle has been used"});
                    return;
                }
                var user = new User({
                    email: info.email,
                    handle: info.handle,
                    password: info.password,
                    profileImage: Boolean(info.image)
                });
                user.save(function (error, user) {
                    if (error) {
                        console.log(error);
                    } else {
                        console.log(user);
                        if (user.profileImage) {
                            Image.writeProfileImage(req.body.image, user._id, function (obj) {
                                res.json(obj);
                            });
                        } else {
                            res.json({ success: true });
                        }
                    }
                });
            });
        },
        update: function (req, res) {
            if (!req.body.image) {
                console.log("Only Can Update Images Currently");
                return;
            }
            User.findById(req.params.id, function (error, user) {
                if (error) { console.log(error); }
                if (user) {

                    Image.writeProfileImage(req.body.image, user._id, function (obj) {
                        if (obj.success) {
                            user.profileImage = true;
                            user.save(function (error) {
                                if (error) { console.log(error); }
                                res.json(obj);
                            });
                        } else {
                            console.log("Could Not Update Image ...");
                            res.json(obj);
                        }
                    });
                }
            });
        }
    };
}; 