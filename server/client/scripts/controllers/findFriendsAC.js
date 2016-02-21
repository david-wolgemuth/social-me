console.log("Found File");
messengerModule.controller("findFriendsController", function ($scope, userFactory, friendFactory) {
    console.log("Opening");
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
                console.log("Friend Request Sent");
                $scope.modalInstance.close();
            }
        });
    };
});