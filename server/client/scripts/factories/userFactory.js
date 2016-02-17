messengerModule.factory("userFactory", function ($http) {
    var users = [];
    var factory = {};
    factory.create = function (user, callback) {
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
            var success = res.data.success;
            console.log("Logged In:", success);
            if (callback) { callback(success); }
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
            var user = res.data;
            if (callback) { callback(user); }
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