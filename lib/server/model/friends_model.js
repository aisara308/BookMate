const mongoose = require('mongoose');
const db = require('../config/db');

const { Schema } = mongoose;

const friendsSchema = new Schema({
  userUid: {
    type: String,
    required: true,
    unique: true
  },
  friends: [
    {
      friendUid: {
        type: String,
        required: true
      },
      status: {
        type: String,
        enum: ['pending', 'accepted'],
        default: 'pending'
      },
      isSender: {
        type: Boolean
      }
    }
  ]
}, { timestamps: true });

const FriendsModel = db.model('friends', friendsSchema);
module.exports = FriendsModel;
