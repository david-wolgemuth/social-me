messengerModule.controller("homeController", function (userFactory, conversationFactory, imageFactory, socket, friendFactory, $scope, $location, $uibModal) {
    var self = this;
    this.sessUser = null;
    this.friends = [];
    this.conversations = [];
    this.ccid = null;
    this.requests = [];
    this.slideDown = false;

    this.showFriendList = function () {
        console.log("SHOWING");
        this.slideDown = !this.slideDown;
    };
    socket.on("friendRequest", function (request) {  // { user: { _id: user._id, handle: user.handle }}
        $scope.$apply(function () {
            self.requests.push(request.user);
        });
    });
    socket.on("friendAccepted", function (friendship) {
        $scope.$apply(function () {
            self.friends.push(friendship.user);
        });
    });
    socket.on("newConversation", function (convo) {
        console.log("New Convo:", convo);
        $scope.$apply(function () {
            self.conversations.push(convo.conversation);
        });
    });
        
    userFactory.getSessionUser(function (user) {
        if (!user) {
            $location.path("/welcome");
        }
        self.sessUser = user;
    });
    this.resetFriendsAndRequests = function () {
        friendFactory.index(function (friends) {
            self.friends = friends;
        });
        friendFactory.requests(function (requests) {
            self.requests = requests;
        });
        conversationFactory.index(function (convos) {
            self.conversations = convos;
        });
    };
    this.resetFriendsAndRequests();
    
    this.logout = function () {
        userFactory.logout(function () {
            $location.path("/welcome");
        });
    };
    this.newConvo = function (user) {
        $scope.modalInstance = $uibModal.open({
            animation: true,
            templateUrl: "views/new-conversation-modal.html",
            scope: $scope
        });
        $scope.modalInstance.result.then(this.resetFriendsAndRequests, this.resetFriendsAndRequests);

    };
    this.showFriend = function (friendId) {
        friendFactory.show(friendId, function (friendship) {
            self.ccid = friendship.conversation._id;
            self.slideDown = false;
            $scope.$broadcast("ccid", { id: self.ccid });
        });
    };
    this.searchConvos = function (convoSearch) {
        return function (convo) {
            if (!convoSearch) {
                return true;
            }
            convoSearch = convoSearch.toLowerCase();
            if (convo.title && convo.title.toLowerCase().indexOf(convoSearch) >= 0) {
                return true;
            }
            for (var i = 0; i < convo.users.length; i++) {
                if (convo.users[i].handle.toLowerCase().indexOf(convoSearch) >= 0) {
                    return true;
                } 
            }
            return false;
        };
    };
    this.showConvo = function (convo) {
        this.ccid = convo._id;
        $scope.$broadcast("ccid", { id: this.ccid });
    };
    this.updateUser = function () {
        $scope.modalInstance = $uibModal.open({
            animation: true,
            templateUrl: "views/update-user-modal.html",
            scope: $scope
        });
    };
    this.findFriends = function () {
        $scope.modalInstance = $uibModal.open({
            animation: true,
            templateUrl: "views/find-friends-modal.html",
            scope: $scope
        });
        $scope.modalInstance.result.then(this.resetFriendsAndRequests, this.resetFriendsAndRequests);
    };
    this.showRequests = function () {
        $scope.modalInstance = $uibModal.open({
            animation: true,
            templateUrl: "views/friend-requests.html",
            scope: $scope
        });
        $scope.modalInstance.result.then(this.resetFriendsAndRequests, this.resetFriendsAndRequests);
    };
})
.directive("showConvo", function ($compile) {
    return {
        template: "<div conversation convo-id=homeCtrl.ccid class='height-100'></div>",
    };
});

