console.log("Found File");
messengerModule.controller("findFriendsController", function ($scope, userFactory) {
    console.log("Opening");
    this.users = [];
    var self = this;
    this.search = function () {
        friendFactory.search(name, function (users) {
            self.users = users;
        });
    };
    this.addFriend = function () {
        $scope.modalInstance.close();   
    };
});