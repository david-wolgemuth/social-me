// Messenger Server Routes

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
    var messages = require("./../controllers/messages.js")(io);
    var conversations = require("./../controllers/conversations.js")(io);

    // Users
    app.get("/users", users.index);
    app.get("/users/current", users.current);
    app.get("/users/:id", users.show);
    app.post("/users", users.create);
    app.post("/login", users.login);
    app.get("/logout", users.logout);

    // Conversations
    app.post("/conversations", conversations.create);
    app.get("/conversations", conversations.index);
    app.get("/conversations/:id", conversations.show);

    // Messages
    app.post("/messages", messages.create);
    app.get("/messages/:id", messages.show);
};
