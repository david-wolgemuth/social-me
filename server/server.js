// Server File For Messenger

// Express
var express = require("express");
var app = express();
app.listen(5000, function () {
    console.log("Running");
});

// Body Parser
var bodyParser = require("body-parser");
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

// Static Files
var path = require("path");
app.use(express.static(path.join(__dirname, "client")));
app.use(express.static(path.join(__dirname, "bower_components")));

// Database
var connection = require("./server/config/database.js");

// Session
var cookieParser = require("cookie-parser");
app.use(cookieParser("SecretKey"));
var session = require("express-session");
var MongoStore = require("connect-mongo")(session);
app.use(session({
    secret: "SecretKey",
    resave: true,  // These might default to true ...
    saveUninitialized: true,
    store: new MongoStore({
        mongooseConnection: connection  // reuse mongo connection for session
    })
}));

// Routes
require("./server/config/routes.js")(app);
