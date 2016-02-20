messengerModule.controller("homeController", function (userFactory, conversationFactory, $scope, $location, $uibModal) {
    var self = this;
    this.sessUser = null;
    this.users = [];
    this.conversations = [];
    this.ccid = null;

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
        this.ccid = convo._id;
        $scope.$broadcast("ccid", { id: this.ccid });
        // $location.path("/conversations/" + convo._id);
    };
    this.findFriends = function () {
        console.log("Trying");
        $scope.modalInstance = $uibModal.open({
            animation: true,
            templateUrl: "views/find-friends-modal.html",
            scope: $scope
        });

    };
})
.directive("showConvo", function ($compile) {
    return {
        template: "<div conversation convo-id=homeCtrl.ccid></div>",
    };
});

