
var mongoose = require("mongoose");
var bcrypt = require("bcrypt");

//------------ Users -------------//
var UserSchema = new mongoose.Schema({
    email: { type: String, required: true, unique: true },
    handle: { type: String, required: true, unique: true , trim: true },
    password: { type: String, required: true },
    friends: [{ 
        friendId: {
            type: mongoose.Schema.Types.ObjectId, 
            ref: "User",
        },
        confirmed: { type: Boolean, default: false },
        conversation: { type: mongoose.Schema.Types.ObjectId, ref: "Conversation" }
    }],

    profileImage: { type: Boolean, default: false },  // if true, image path is "images/profiles/user._id"
    conversations: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: "Conversation"
    }]
}, {
    timestamps: true
});

UserSchema.pre('save', function(next) {
    // Salt Encrypt The User Password

    var user = this;

    // only hash the password if it has been modified (or is new)
    if (!user.isModified('password')) return next();

    // generate a salt
    var SALT_WORK_FACTOR = 10;
    bcrypt.genSalt(SALT_WORK_FACTOR, function(err, salt) {
       if (err) return next(err);

       // hash the password along with our new salt
       bcrypt.hash(user.password, salt, function(err, hash) {
           if (err) return next(err);

           // override the cleartext password with the hashed one
           user.password = hash;
           next();
       });
    });
});

UserSchema.methods.comparePassword = function(candidatePassword, cb) {
   bcrypt.compare(candidatePassword, this.password, function(err, isMatch) {
       if (err) return cb(err);
       cb(null, isMatch);
   });
};

//------------ Messages -------------//
var MessageSchema = new mongoose.Schema({
    content: String,
    image: { type: Boolean, default: false },  // if true, image path is "images/messages/message._id"
    _user: {  // .populate("_user", "handle", "image")
        type: mongoose.Schema.Types.ObjectId,
        ref: "User"
    },
    _conversation: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Conversation"
    }
}, {
    timestamps: true
});

//------------ Conversations -------------//
var ConversationSchema = new mongoose.Schema({
    title: String,
    private: { type: Boolean, default: false },  // Private Conversations Are Created When Friends Are Added
    users: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: "User"
    }],
    messages: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: "Message"
    }]
}, {
    timestamps: true
});

// Deep Populate Rules
var deepPopulate = require("mongoose-deep-populate");
UserSchema.plugin(deepPopulate, { 
    populate: {
        "conversations.users": {
            select: "handle profileImage"
        }
    }
});
ConversationSchema.plugin(deepPopulate, {
    populate: {
        "users": {
            select: "handle profileImage"
        },
        "messages._user": {
            select: "handle profileImage"
        }
    }
});
MessageSchema.plugin(deepPopulate, {
    populate: {
        "_user": {
            select: "handle profileImage"
        }
    }
});

mongoose.model("User", UserSchema);
mongoose.model("Message", MessageSchema);
// mongoose.model("Image", ImageSchema);
mongoose.model("Conversation", ConversationSchema);
