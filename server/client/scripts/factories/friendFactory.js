messengerModule.factory("friendFactory", function (userFactory) {
    var factory = {};
    factory.search = function (name, callback) {
        $http({
            url: "/friends?name=" + name,
            method: "GET",
        }).then(function (res) {
            callback(res.data);
        });
    };
    return factory;
});