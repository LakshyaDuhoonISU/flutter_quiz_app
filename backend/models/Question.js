// models/Question.js
// This file defines the structure of a Question in MongoDB

const mongoose = require("mongoose");

const questionSchema = new mongoose.Schema({
    // Which quiz this question belongs to
    quizId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Quiz",
        required: true,
    },

    // The actual question text, e.g. "What is the capital of France?"
    questionText: {
        type: String,
        required: true,
    },

    // Array of answer choices, e.g. ["Paris", "London", "Berlin", "Rome"]
    options: {
        type: [String], // Array of strings
        required: true,
    },

    // Index of the correct answer in the options array (0-based)
    // e.g. if "Paris" is at index 0, correctAnswer = 0
    correctAnswer: {
        type: Number,
        required: true,
    },
});

module.exports = mongoose.model("Question", questionSchema);
