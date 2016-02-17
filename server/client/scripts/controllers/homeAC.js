messengerModule.controller("homeController", function (userFactory, conversationFactory, $location) {
    var self = this;
    this.sessUser = null;
    this.users = [];
    this.conversations = [];

    userFactory.getSessionUser(function (user) {
        if (!user) {
            $location.path("/welcome");
        }
        self.sessUser = user;
    });
    userFactory.index(function (users) {
        self.users = users;
    });
    conversationFactory.index(function (convos) {
        self.conversations = convos;
    });
    this.logout = function () {
        userFactory.logout(function () {
            $location.path("/welcome");
        });
    };
    this.newConvo = function (user) {
        if (!this.sessUser) {
            return;
        }
        conversationFactory.create([user, this.sessUser], function (convo_id) {
            $location.path("/conversations/" + convo_id);
        });
    };
    this.goToConvo = function (convo) {
        $location.path("/conversations/" + convo._id);
    };
});