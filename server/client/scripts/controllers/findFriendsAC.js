messengerModule.controller("findFriendsController", function ($scope, userFactory, friendFactory) {
    this.users = [];
    var self = this;
    this.search = function (name) {
        friendFactory.search(name, function (users) {
            console.log(users);
            self.users = users;
        });
    };
    this.addFriend = function (friend) {
        console.log(friend);
        friendFactory.create(friend._id, function (data) {
            if (data.success) {
                friend.requestSent = true;
                console.log("Friend Request Sent");
            }
        });
    };
    this.close = function () {
        $scope.modalInstance.close();
    };
});

messengerModule.controller("friendRequestsController", function ($scope, friendFactory) {
    console.log("Opening");
    var self = this;
    this.requests = [];
    this.addedFriend = null;
    friendFactory.requests(function (requests) {
        requests.forEach(function (request) {
            request.isFriend = false;
            self.requests.push(request);
        });
    });
    this.accept = function (request, accepted) {
        console.log(request, accepted);
        friendFactory.update(request, accepted, function (result) {
            if (result.success) {
                if (accepted) {
                    request.isFriend = true;
                    this.addedFriend = request;
                } else {
                    // Blah
                }
                for (var i = 0; i < self.requests.length; i++) {
                    if (self.requests[i]._id == request._id) {
                        self.requests.splice(i, 1); break;
                    }
                }
            } else {
                console.log(result.error);
            }
        });
    };
    this.close = function () {
        $scope.modalInstance.close();
    };
});

messengerModule.controller("newConversationController", function ($scope, friendFactory, conversationFactory) {
    this.allFriends = [];
    this.friendsInConversation = [];
    var self = this;
    friendFactory.index(function (friends) {
        self.allFriends = friends;
        for (var i = 0; i < self.allFriends.length; i++) {
            self.allFriends[i].inConvo = false;
        }
    });
    this.createConversation = function () {
        var conversation = {};
        conversation.title = this.conversationTitle;
        conversation.users = [];
        for (var i = 0; i < this.friendsInConversation.length; i++) {
            conversation.users.push(this.friendsInConversation[i]._id);
        }
        conversationFactory.create(conversation, function (created, error) {
            if (error) { console.log(error); }
        });
    };
    this.addFriendToConvo = function (friend) {
        friend.inConvo = true;
        this.friendsInConversation.push(friend);
    };
    this.removeFromConvo = function (friend) {
        this.friendsInConversation.splice(this.friendsInConversation.indexOf(friend), 1);
        friend.inConvo = false;
    };
    this.close = function () {
        $scope.modalInstance.close();
    };
});
