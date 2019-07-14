const mongoose = require("mongoose")
const Schema = mongoose.Schema

const userAuthCred = new Schema({
    username: {
        type: String,
        unique: true,
        required: true
    },
    password: {
        type: String,
        required: true
    },
    phoneNumber: {
        type: String,
        required: true
    },
    authRole: {
        type: String,
        required: true
    }
});

module.exports = mongoose.model("userAuthCred", userAuthCred)