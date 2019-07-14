const mongoose = require("mongoose");
const Schema = mongoose.Schema;

const customerLocationSchema = new Schema({
    caId: {
        type: Schema.ObjectId,
        ref: "userAuthCred"
    },
    name: {
        type: String,
        trim: true,
        required: true
    },
    address: {
        type: String
    },
    zipCode: {
        type: String
    },
    country: {
        type: String
    },
    city: {
        type: String
    }
});

module.exports = mongoose.model("customerLocation", customerLocationSchema);