messengerModule.controller("conversationsController", function ($scope, $routeParams, $location, socket, conversationFactory, messageFactory, userFactory) {
    this.users = [];
    this.messages = [];
    this.sessUser = null;
    var self = this;

    console.log("Setting Listener");
    socket.on("newMessage", function (data) {
        var convoId = data.conversation;
        if (convoId == $routeParams.id) {
            messageFactory.show(data.message, function (message) {
                self.messages.push(message);
            });
        } else {
            console.log("Received Message, but Wrong Convo");
        }
    });

    conversationFactory.show($routeParams.id, function (conversation) {
        userFactory.getSessionUser(function (user) {
            if (!user) {
                $location.path("/welcome"); 
                return;
            }
            self.sessUser = user;
            var inConvo = false;
            self.users = conversation.users;
            self.users.forEach(function (cUser) {
                if (cUser._id == user._id) {
                    inConvo = true;
                }
            });
            if (!inConvo) {
                $location.path("/home");
                return;
            }
            self.messages = conversation.messages;
        });
    });
    this.createMessage = function (message) {
        message.conversationId = $routeParams.id;
        message.userId = this.sessUser._id;
        messageFactory.create(message, function (createdMessage) {
            self.messages.push(createdMessage);
            message.content = "";
        });
    };
    this.logout = function () {
        console.log("hit func");
        userFactory.logout(function () {
            $location.path("/welcome");
        });
    };
}); 