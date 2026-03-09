// models/Result.js
// This file defines the structure of a quiz Result in MongoDB

const mongoose = require("mongoose");

const resultSchema = new mongoose.Schema({
    // The student's username
    username: {
        type: String,
        required: true,
    },

    // Which quiz this result belongs to
    quizId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Quiz",
        required: true,
    },

    // How many questions the student answered correctly
    score: {
        type: Number,
        required: true,
    },

    // Total number of questions in the quiz
    totalQuestions: {
        type: Number,
        required: true,
    },

    // How many seconds the student took to complete the quiz
    timeTaken: {
        type: Number,
        required: true,
        default: 0,
    },

    // When the student submitted their answers
    createdAt: {
        type: Date,
        default: Date.now,
    },
});

module.exports = mongoose.model("Result", resultSchema);
