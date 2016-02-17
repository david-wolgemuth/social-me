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
    return factory;
});