messengerModule.factory("friendFactory", function (userFactory, $http) {
    var factory = {};
    factory.index = function (callback) {
        $http({
            url: "/friends",
            method: "GET",
        }).then(function (res) {
            if (callback) { callback(res.data); }                   
        });
    };
    factory.show = function (id, callback) {
        $http({
            url: "/friends/" + id,
            method: "GET",
        }).then(function (res) {
            if (callback) { callback(res.data); }    
        });
    };
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
    factory.update = function (request, accepted, callback) {
        $http({
            url: "/friends/" + request._id,
            method: "PUT",
            data: {
                confirmed: accepted
            }
        }).then(function (res) {
            console.log("In Factory:", res); 
            if (callback) { callback(res.data); }
        });
    };
    return factory;
});