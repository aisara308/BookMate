const UserModel=require('../model/user_model')
const jwt = require('jsonwebtoken');
const generateUID = require('../utils/generateUID');

class UserService{

    static async registerUser(name,email,password){
        try{
            const uid = generateUID();
            const createUser=new UserModel({uid,name,email,password});
            return await createUser.save();
        }catch(error){
            throw error;
        }
    }

    static async findByUID(uid) {
        return UserModel.findOne({ uid }).select('-password');
    }

    static async getUserByEmail(email) {
        return await UserModel.findOne({ email }).select('-password');
    }

    static async updateProfile(userId, data) {
    // data теперь может содержать: birthDate, gender, name, email, avatar
    return UserModel.findByIdAndUpdate(
        userId,
        { $set: data },
        { new: true }
    );
}


    static async checkUser(email){
        try{
            return await UserModel.findOne({email});
        }catch(error){
            throw error;
        }
    }

    static async generateToken(tokenData, secretKey, jwt_expire){
        return jwt.sign(tokenData, secretKey, {expiresIn:jwt_expire});
    }
}

module.exports= UserService;