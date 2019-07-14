const mongoose = require("mongoose");
const Schema = mongoose.Schema;

const customerRoleSchema = new Schema({
    name: {
        type: String,
        trim: true,
        required: true
    },
    applications: [{
      type: Schema.ObjectId,
      ref: "application"
    }],
    caId: {
        type: Schema.ObjectId,
        ref: "userAuthCred"
    }
});

module.exports = mongoose.model("customerRole", customerRoleSchema);
