const mongoose = require("mongoose");
const Schema = mongoose.Schema;

const ApplicationSchema = new Schema({
    name: {
        type: String,
        required: true
    },
    license: {
        type: String,
        required: true
    },
    displayName: {
        type: String
    },
    price: {
        type: String
    },
    currency: {
        type: String,
    },
    group: {
        type: String,
        required: true
    },
    processName: {
        type: String
    },
    imageAddress: {
        type: String
    },
    imageType: {
        type: String
    }
});

module.exports = mongoose.model("application", ApplicationSchema);
