// Server File For Messenger

// Express
var express = require("express");
var app = express();
var server = app.listen(5000, function () {
    console.log("Running");
});

// Body Parser
var bodyParser = require("body-parser");
// app.use(bodyParser.urlencoded({ extended: true }));

app.use(bodyParser.json({limit: '50mb'}));
app.use(bodyParser.urlencoded({limit: '50mb', extended: true}));

// app.use(bodyParser.json());

// Static Files
var path = require("path");
app.use(express.static(path.join(__dirname, "client")));

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
var io = require("socket.io")(server);
require("./server/config/routes.js")(app, io);
