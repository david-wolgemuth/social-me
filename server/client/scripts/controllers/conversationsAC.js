messengerModule.controller("conversationsController", function ($scope, $routeParams, $location, 
                                                                socket, conversationFactory, messageFactory, userFactory) {
    this.convoId = $scope.convoId;
    this.users = [];
    this.conversation = null;
    this.sessUser = null;
    var self = this;

    socket.on("newMessage", function (data) {
        var convoId = data.conversation;
        if (convoId == self.convoId) {
            messageFactory.show(data.message, function (message) {
                if (self.messages[self.messages.length - 1]._user._id == message._user._id) {
                    message.hideHandle = true;
                } else {
                    message.hideHandle = false;
                }
                self.messages.push(message);
            });
        } else {
            console.log(self.convoId, convoId);
            console.log("Received Message, but Wrong Convo");
        }
    });
    $scope.$on("ccid", function (event, value) {
        self.convoId = value.id;
        conversationFactory.show(self.convoId, function (conversation) {
            userFactory.getSessionUser(function (user) {
                if (!user || ! conversation) {
                    $location.path("/welcome"); 
                    return;
                }
                self.sessUser = user;
                var inConvo = false;
                self.users = conversation.users;
                self.users.forEach(function (cUser) {
                    if (cUser._id == user._id) {
                        inConvo = true;
                        cUser.sessUser = true;
                    } else {
                        cUser.sessUser = false;
                    }
                });
                if (!inConvo) {
                    $location.path("/home");
                    return;
                }
                self.messages = conversation.messages;
                filterUserNames(self.messages);
            });
        });
    });
    function filterUserNames (messages) {
        var lastUserId = null;
        if (!messages) { return; }
        messages.forEach(function (message) {
            if (message._user._id == lastUserId) {
                message.hideHandle = true;
            } else {
                message.hideHandle = false;
                lastUserId = message._user._id;
            }
        });
    }

    this.createMessage = function (message) {
        message.conversationId = this.convoId;
        message.userId = this.sessUser._id;
        messageFactory.create(message, function (createdMessage) {
            message.content = "";
        });
    };
    this.logout = function () {
        console.log("hit func");
        userFactory.logout(function () {
            $location.path("/welcome");
        });
    };
})
.directive("conversation", function () {
    return {
        scope: { convoId: "=convoId" },
        templateUrl: "views/conversation-view.html",
    };
});






