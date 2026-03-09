// config/db.js
// This file connects our app to the MongoDB database using Mongoose

const mongoose = require("mongoose");

const connectDB = async () => {
    try {
        const conn = await mongoose.connect("mongodb://localhost:27017/quizapp");
        console.log(`MongoDB connected: ${conn.connection.host}`);
    } catch (error) {
        console.error(`MongoDB connection error: ${error.message}`);
        process.exit(1); // Exit the app with a failure code
    }
};

module.exports = connectDB;
