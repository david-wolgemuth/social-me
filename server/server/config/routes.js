// Messenger Server Routes

var fs = require("fs");

module.exports = function (app, io) {
    // Sockets
    io.users = {};
    io.on("connection", function (socket) {
        console.log("New Socket Connection:", socket.id);
        socket.on("loggedIn", function (userId) {
            console.log("Socket Login User:", userId);
            io.users[userId] = socket;
        });
    });

    // Controllers
    var users = require("./../controllers/users.js")(io);
    var friends = require("./../controllers/friends.js")(io);
    var messages = require("./../controllers/messages.js")(io);
    var conversations = require("./../controllers/conversations.js")(io);


    //------------ Users -------------//
    
    app.get("/users", users.index);
    //      -> [{ _id: "_", handle: "david" }]
    // "/users?user=jim_bob" searches for single user

    app.get("/users/current", users.current);
    app.get("/users/:id", users.show);
    //      -> { _id: "_", handle: "david" } / null (if not found)

    app.post("/users", users.create);
    //      -> { success: Boolean }


    //------------ Friends -------------//
    app.get("/friends", friends.index);
    //      -> [{ _id: "_", handle: "david" }]
    // 
    //      Can Search For Friends using "/friends?user=joe"
    //      -> [{ _id: " _ ", handle: "david", isFriend: false, requestSent: true }]
    
    app.get("/friends/requests", friends.requests);
    //      -> [{ _id: "_", handle: "david" }]

    app.get("/friends/:id", friends.show);
    //      -> { friend: { _id: friend._id, handle: friend.handle }, conversation: conversation }

    app.post("/friends", friends.create);  // New Friend Request
    //      <- { id: friendId } (must be logged in)
    //      -> { success: Boolean, error: "some error message" }
    //      friendSocket.emit("friendRequest", { user: { _id: user_id, handle: user_handle }} );

    app.put("/friends/:id", friends.update);  // Respond to Friend Request
    //      <- { confirmed: Boolean }  (true means "accepting", false means "ignoring")
    //      -> { success: Boolean, error: "some error message" }
    //     friendSocket.emit("friendAccepted", { user: { _id: user._id, handle: user.handle }} ); 

    //------------ Session -------------//
    app.post("/login", users.login);
    //      -> { user: { _id: "_", handle: "david" }} / null (if not found)
    app.get("/logout", users.logout);
    // res.json()  (If any response, successful logout)


    //------------ Messages -------------//
    app.post("/messages", messages.create);
    //      <- { conversationId: "asdf", content: "Hello!" } (must be logged in) (returns created message)
    app.get("/messages/:id", messages.show);
    //      -> { _user: { _id: "_" handle: "david" }, _conversation: "_", content: "Hello!" } (also includes createdAt/updatedAt)

    //------------ Conversations -------------//
    app.post("/conversations", conversations.create);
    app.get("/conversations", conversations.index);
    app.get("/conversations/:id", conversations.show);

    app.get("/backgrounds", function (req, res) {
        backgrounds = [];
        backgrounds_path = __dirname + "/../../client/styles/background-images";
        fs.readdirSync(backgrounds_path).forEach(function (file) {
            console.log(file);
            backgrounds.push(file);
        });
        console.log("Backgrounds:", backgrounds);
        res.json(backgrounds);
    });
};
