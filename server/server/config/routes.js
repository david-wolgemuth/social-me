// Messenger Server Routes

// Controllers
var users = require("./../controllers/users.js");
var messages = require("./../controllers/messages.js");
var conversations = require("./../controllers/conversations.js");

module.exports = function (app) {
    app.get("/users", users.index);
    app.get("/users/current", users.current);
    // app.get("/users/:id", users.show);
    app.post("/users", users.create);
    app.post("/login", users.login);
    app.get("/logout", users.logout);

    app.post("/conversations", conversations.create);
    app.get("/conversations", conversations.index);
    app.get("/conversations/:id", conversations.show);

    app.post("/messages", messages.create);
    // app.get("/users/edit/:id", users.edit);
    // app.put("/users/:id", users.update);
    // app.delete("/users/:id", users.delete);
};
