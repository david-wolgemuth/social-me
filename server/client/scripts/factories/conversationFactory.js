
messengerModule.factory("conversationFactory", function ($http) {
    var factory = {};
    factory.create = function (users, callback) {
        $http({
            url: "/conversations",
            method: "POST",
            data: users
        }).then(function (res) {
            var convo_id = res.data;
            console.log("RES:", convo_id);
            if (callback) { callback(convo_id); } 
        });
    };
    factory.index = function (callback) {
        $http({
            url: "/conversations",
            method: "GET",
        }).then(function (res) {
            var convos = res.data;
            if (callback) { callback(convos); }
        });
    };
    factory.show = function (conversation_id, callback) {
        $http({
            url: "/conversations/" + conversation_id,
            method: "GET",
        }).then(function (res) {
            var conversation = res.data;
            if (callback) { callback(conversation); }       
        });
    };
    return factory;
});
