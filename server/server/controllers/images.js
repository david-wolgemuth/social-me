var mongoose = require("mongoose");
var fs = require("fs");

var User = mongoose.model("User");
// var Image = mongoose.model("Image");
var Message = mongoose.model("Message");

var images_path = __dirname + "/../../client/images";

module.exports = function (app, io) {
    var Ctrl = {};
    Ctrl.backgroundIndex = function (req, res) {
        backgrounds = [];
        backgrounds_path = images_path + "/backgrounds";
        fs.readdirSync(backgrounds_path).forEach(function (file) {
            backgrounds.push(file);
        });
        res.json(backgrounds);
    };
    Ctrl.writeProfileImage = function (image, userId, callback) {

        Ctrl.writeImage("/profiles/", image, userId, callback);
    };
    Ctrl.writeMessageImage = function (image, messageId, callback) {
        Ctrl.writeImage("/messages/", image, messageId, callback);


    };
    Ctrl.writeImage = function (directory, image, id, callback) {
    
        if (!callback) { callback = function () {}; }
        if (!image) {
            return callback({ success: false, error: "No Image Uploaded" });
        }
        if (!id) {
            return callback({ success: false, error: "Must Contain User Id."});
        }
        var image_path = images_path + directory + id + ".jpeg";
        fs.writeFile(image_path, image, "base64", function (error) {
            if (error) { 
                console.log(error);
                callback({ success: false, error: error });
            } else {
                console.log("uploadedImage");
                callback({ success: true });
            }
        });
    };
    Ctrl.edit = function (req, res) {

    };
    Ctrl.update = function (req, res) {

    };
    Ctrl.delete = function (req, res) {

    };
    return Ctrl;
}; 

