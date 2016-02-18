
messengerModule.factory('socket', function ($http) {
    var socket = io.connect();
    socket.on("connect", function () {
        console.log("Socket Connected");
    });
    $http({
        url: "/users/current",
        method: "GET"
    }).then(function (res) {
        var user = res.data;
        socket.emit("loggedIn", user._id);
    });
    var factory = {};
    factory.on = function (eventName, callback) {
        socket.on(eventName, callback);
    };
    factory.emit = function (eventName, data) {
        console.log("Emitting: ", eventName);
        socket.emit(eventName, data);
    };
    return factory;
});
