
messengerModule.factory("conversationFactory", function ($http) {
    var factory = {};
    factory.create = function (users, callback) {
        $http({
            url: "/conversations",
            method: "POST",
            data: users
        }).then(function (res) {
            var convo = res.data.conversation;
            var error = res.data.error;
            console.log("RES:", convo);
            console.log("ERROR?", error);
            if (callback) { callback(convo, error); } 
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
