var mongoose = require('mongoose'),
Schema = mongoose.Schema;

var usageSchema = new Schema({
    caId: {
        type: Schema.Types.ObjectId,
        ref: 'userAuthCred'
    },
    appName: String,
    cuId: {
        type: Schema.Types.ObjectId,
        ref: 'customerUser'
    },
    date: Date,
    appId: {
        type: Schema.Types.ObjectId,
        ref: 'application'
    },
    usage: Number,
    year: Number,
    month: Number,
    day: Number

});

module.exports = mongoose.model('customerUsage', usageSchema);