messengerModule.factory("userFactory", function ($http, socket) {
    var factory = {};
    factory.create = function (user, callback) {
        console.log(user);
        $http({
            url: "/users",
            method: "POST",
            data: user
        }).then(function (res) {
            var success = res.data.success;
            console.log("Registered:", success);
            if (callback) { callback (success); }       
        });
    };
    factory.login = function (user, callback) {
        $http({
            url: "/login",
            method: "POST",
            data: user
        }).then(function (res) {
            var sUser = res.data.user;
            console.log("Logged In:", sUser);
            if (sUser) {
                socket.emit("loggedIn", sUser._id);
            }
            if (callback) { callback(sUser); }
        });
    };
    factory.logout = function (callback) {
        $http({
            url: "/logout",
            method: "GET",
        }).then(function (res) {
            if (callback) { callback(); }            
        });
    };
    factory.getSessionUser = function (callback) {
        $http({
            url: "/users/current",
            method: "GET"
        }).then(function (res) {
            console.log(res);
            var user = res.data;
            if (callback) { callback(user); }
        });
    };
    factory.updateProfileImage = function (info, callback) {
        $http({
            url: "/users/" + info.userId,
            method: "PUT",
            data: info
        }).then(function (res) {
            console.log(res.data);
            if (res.data.success) {
                if (callback) { callback(); }
            }
        });
    };
    factory.index = function (callback) {
        $http({
            url: "/users",
            method: "GET",
        }).then(function (res) {
            var users = res.data;
            if (callback) { callback(users); }            
        });
    };
    return factory;
});