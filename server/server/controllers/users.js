var mongoose = require("mongoose");
var User = mongoose.model("User");

module.exports = (function () {
    return {
        index: function (req, res) {
            User.find({}).select("handle").exec(function (error, users) {
                if (error) { console.log(error); }
                res.json(users);
            });
        },
        login: function (req, res) {
            var info = req.body;
            User.findOne({
                $or: [
                   { handle: info.user }, { email: info.user }
                ]}, function (error, user) {
                    if (error) { console.log(error); }
                    if (user && user.password == info.password) {
                        res.json({ success: true });
                        req.session.user = { _id: user._id, handle: user.handle };
                        req.session.save();
                        return;
                    }
                    res.json({ success: false });
                });
        },
        logout: function (req, res) {
            req.session.destroy();
            console.log("Logged Out");
            console.log(req.session);
            res.json();
        },
        current: function (req, res) {
            res.json(req.session.user);
        },
        create: function (req, res) {
            var info = req.body;
            User.find({ $or: [{ 
                "handle": info.handle }, { "email": info.email}
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
        },
    };
})(); 