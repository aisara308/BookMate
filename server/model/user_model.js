const mongoose = require('mongoose');
const db = require('../config/db');
const bcrypt = require('bcrypt');

const { Schema } = mongoose;

const userSchema = new Schema({
  uid: {
    type: String,
    unique: true,
    required: true
  },

  name: {
    type: String,
    required: true
  },

  email: {
    type: String,
    required: true,
    lowercase: true,
    unique: true
  },

  password: {
    type: String,
    required: true
  },

  birthDate: {
    type: Date
  },

  gender: {
    type: String,
    enum: ['male', 'female', 'other']
  },

  avatar: {
    type: String,
    default: null
  },

books: {
    type: [String],
    default: [
        "/assets/books/117640.epub",
        "/assets/books/secretgarden.epub",
        "/assets/books/1984.epub",
        "/assets/books/doriangray.epub",
        "/assets/books/jail.epub",
        "/assets/books/boy.epub"
    ]
}

}, { timestamps: true });


userSchema.pre('save', async function () {
  if (!this.isModified('password')) return;

  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
});

userSchema.methods.comparePasswords= async function(userPassword){
    try{
        const isMatch = await bcrypt.compare(userPassword,this.password);
        return isMatch;
    }
    catch(error){
        throw(error)
    }
}

const UserModel = db.model('user', userSchema);

module.exports = UserModel;