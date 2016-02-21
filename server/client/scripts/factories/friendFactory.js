messengerModule.factory("friendFactory", function (userFactory, $http) {
    var factory = {};
    factory.search = function (name, callback) {
        $http({
            url: "/friends?user=" + name,
            method: "GET",
        }).then(function (res) {
            callback(res.data);
        });
    };
    factory.create = function (friendId, callback) {
        $http({
            url: "/friends",
            method: "POST",
            data: { id: friendId }
        }).then(function (res) {
            console.log(res.data);       
            if (callback) { callback(res.data); }
        });
    };
    factory.requests = function (callback) {
        $http({
            url: "/friends/requests",
            method: "GET",
        }).then(function (res) {
            callback(res.data);            
        });
    };
    return factory;
});