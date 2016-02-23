messengerModule.controller("homeController", function (userFactory, conversationFactory, socket, friendFactory, $scope, $location, $uibModal) {
    var self = this;
    this.sessUser = null;
    this.friends = [];
    this.conversations = [];
    this.ccid = null;
    this.requests = [];
    socket.on("friendRequest", function (request) {  // { user: { _id: user._id, handle: user.handle }}
        console.log("Request:", request);
        self.requests.push(request.user);
    });
    socket.on("friendAccepted", function (friendship) {
        console.log("BEFORE:", self.friends);
        console.log("Friend Accepted:", friendship);
        self.friends.push(friendship.user);
        console.log("AFTER:", self.friends);
    });
        
    userFactory.getSessionUser(function (user) {
        if (!user) {
            $location.path("/welcome");
        }
        self.sessUser = user;
    });
    friendFactory.index(function (friends) {
        self.friends = friends;
    });
    friendFactory.requests(function (requests) {
        console.log("Requests:", requests);
        self.requests = requests;
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
    this.showFriend = function (friendId) {
        friendFactory.show(friendId, function (friendship) {
            self.ccid = friendship.conversation._id;
            $scope.$broadcast("ccid", { id: self.ccid });
        });
    };
    this.showConvo = function (convo) {
        this.ccid = convo._id;
        $scope.$broadcast("ccid", { id: this.ccid });
    };
    this.findFriends = function () {
        $scope.modalInstance = $uibModal.open({
            animation: true,
            templateUrl: "views/find-friends-modal.html",
            scope: $scope
        });
    };
    this.showRequests = function () {
        console.log("Friend Requests Clicked");
        $scope.modalInstance = $uibModal.open({
            animation: true,
            templateUrl: "views/friend-requests.html",
            scope: $scope
        });
        $scope.modalInstance.result.then(function () {}, function () {
            friendFactory.requests(function (requests) {
                console.log("Requests:", requests);
                self.requests = requests;
            });        
        });
    };
})
.directive("showConvo", function ($compile) {
    return {
        template: "<div conversation convo-id=homeCtrl.ccid class='height-100'></div>",
    };
});

