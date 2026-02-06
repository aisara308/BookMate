// model/book_model.js
const db = require('../config/db'); // твой createConnection
const mongoose = require('mongoose');

const BookSchema = new mongoose.Schema({
  userUid: {
    type: String,
    required: true,
    index: true
  },

  filePath: {
    type: String,
    required: true
  },

  title: { type: String, required: true },
  author: { type: String, default: 'Unknown' },
  description: { type: String, default: '' },

  progress: {
  type: Number,
  default: 0,
},
lastCfi: {
  type: String,
},
  isFavorite: { type: Boolean, default: false },
  isFinished: { type: Boolean, default: false }
}, { timestamps: true });

BookSchema.index({ userUid: 1, filePath: 1 }, { unique: true });

module.exports = db.model('Book', BookSchema);
