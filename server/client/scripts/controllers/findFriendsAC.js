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
