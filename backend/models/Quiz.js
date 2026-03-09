// models/Quiz.js
// This file defines the structure (schema) of a Quiz in MongoDB

const mongoose = require("mongoose");

const quizSchema = new mongoose.Schema({
    // Title of the quiz, e.g. "General Knowledge Round 1"
    title: {
        type: String,
        required: true,
    },

    // A short description about the quiz
    description: {
        type: String,
        required: true,
    },

    // How many minutes the student has to finish the quiz
    timeLimit: {
        type: Number,
        required: true, // e.g. 10 means 10 minutes
    },

    // Automatically saves the date and time when the quiz was created
    createdAt: {
        type: Date,
        default: Date.now,
    },
});

module.exports = mongoose.model("Quiz", quizSchema);
