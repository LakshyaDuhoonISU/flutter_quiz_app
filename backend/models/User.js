// models/User.js
// This file defines the structure of a User in MongoDB
// Users can be either an "admin" or a "student"

const mongoose = require("mongoose");

const userSchema = new mongoose.Schema({
    // The username used to log in — must be unique (no two users can share it)
    username: {
        type: String,
        required: true,
        unique: true,
    },

    // The password — we will store it as a HASHED string (never plain text)
    password: {
        type: String,
        required: true,
    },

    // The role decides what the user can do in the app
    role: {
        type: String,
        enum: ["admin", "student"],
        default: "student", // If no role is given, they are a student by default
    },

    // Automatically saves when the user registered
    createdAt: {
        type: Date,
        default: Date.now,
    },
});

module.exports = mongoose.model("User", userSchema);
