const mongoose = require("mongoose");
const Schema = mongoose.Schema;

const customerUserSchema = new Schema({
    roleId: {
        type: Schema.ObjectId,
        ref: "customerRole",
        required: true
    },
    locId: {
        type: Schema.ObjectId,
        ref: "customerLocation",
        required: true
    },
    caId: {
        type: Schema.ObjectId,
        ref: "userAuthCred",
        required: true
    },
    name: {
        type: String,
        required: true
    },
    email: {
        type: String,
        required: true
    },
    username: {
        type: String,
        required: true
    }
});

module.exports = mongoose.model("customerUser", customerUserSchema);