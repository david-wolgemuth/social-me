messengerModule.factory("messageFactory", function ($http) {
    var messages = [];
    var factory = {};
    factory.create = function (message, callback) {
        $http({
            url: "/messages",
            method: "POST",
            data: message
        }).then(function (res) {
            var message = res.data;
            console.log(message);
            if (callback) { callback(message); } 
        });
    };
    factory.show = function (id, callback) {
        $http({
            url: "/messages/" + id,
            method: "GET",
        }).then(function (res) {
            var message = res.data;            
            console.log("Show Message in Factory:", message);
            if (callback) { callback(message); }
        });
    };
    return factory;
});