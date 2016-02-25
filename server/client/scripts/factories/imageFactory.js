messengerModule.factory("imageFactory", function ($http) {
    var backgrounds = [];
    var factory = {};
    factory.backgrounds = backgrounds;
    factory.backgroundIndex = function (callback) {
        $http({
            url: "/backgrounds",
            method: "GET",
        }).then(function (res) {
            backgrounds = res.data;            
            if (callback) { callback(backgrounds); }
        });
    };
    factory.backgroundIndex();
    return factory;
});