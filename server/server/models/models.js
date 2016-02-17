
var mongoose = require("mongoose");

//------------ Users -------------//
var UserSchema = new mongoose.Schema({
    email: { type: String, required: true, unique: true },
    handle: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    image: { data: Buffer, contentType: String },  // If time
    conversations: [{ 
        type: mongoose.Schema.Types.ObjectId, 
        ref: "Conversation" 
    }]
}, {
    timestamps: true
});

//------------ Messages -------------//
var MessageSchema = new mongoose.Schema({
    content: String,
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

var deepPopulate = require("mongoose-deep-populate");
UserSchema.plugin(deepPopulate, { 
    populate: {
        "conversations.users": {
            select: "handle"
        }
    }
});
ConversationSchema.plugin(deepPopulate, {
    populate: {
        "users": {
            select: "handle"
        },
        "messages._user": {
            select: "handle"
        }
    }
});
MessageSchema.plugin(deepPopulate, {
    populate: {
        "_user": {
            select: "handle"
        }
    }
});
mongoose.model("User", UserSchema);
mongoose.model("Message", MessageSchema);
mongoose.model("Conversation", ConversationSchema);

