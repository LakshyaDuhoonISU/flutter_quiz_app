// routes/questionRoutes.js
// This file handles all API routes related to Questions

const express = require("express");
const router = express.Router();
const Question = require("../models/Question");
const { verifyToken, isAdmin } = require("../middleware/auth");

// ─────────────────────────────────────────────
// POST /api/questions
// Admin adds a new question — ADMIN ONLY
// ─────────────────────────────────────────────
router.post("/", verifyToken, isAdmin, async (req, res) => {
    try {
        // Get question data from the request body
        const { quizId, questionText, options, correctAnswer } = req.body;

        // Create a new Question document
        const question = new Question({ quizId, questionText, options, correctAnswer });

        // Save to MongoDB
        await question.save();

        res.status(201).json({ message: "Question added successfully", question });
    } catch (error) {
        res.status(500).json({ message: "Error adding question", error: error.message });
    }
});

// ─────────────────────────────────────────────
// GET /api/questions/:quizId
// Get all questions for a quiz — any logged-in user
// Students use this when they start a quiz
// ─────────────────────────────────────────────
router.get("/:quizId", verifyToken, async (req, res) => {
    try {
        // Find all questions where quizId matches the given ID
        const questions = await Question.find({ quizId: req.params.quizId });

        // Return an empty array instead of 404 — this is not an error,
        // the quiz simply has no questions yet (e.g. after all were deleted)
        res.status(200).json(questions);
    } catch (error) {
        res.status(500).json({ message: "Error fetching questions", error: error.message });
    }
});

// ─────────────────────────────────────────────
// PUT /api/questions/:questionId
// Admin edits an existing question — ADMIN ONLY
// ─────────────────────────────────────────────
router.put("/:questionId", verifyToken, isAdmin, async (req, res) => {
    try {
        const { questionText, options, correctAnswer } = req.body;

        // findByIdAndUpdate with { new: true } returns the updated document
        const question = await Question.findByIdAndUpdate(
            req.params.questionId,
            { questionText, options, correctAnswer },
            { new: true }
        );

        if (!question) {
            return res.status(404).json({ message: "Question not found" });
        }

        res.status(200).json({ message: "Question updated successfully", question });
    } catch (error) {
        res.status(500).json({ message: "Error updating question", error: error.message });
    }
});

// ─────────────────────────────────────────────
// DELETE /api/questions/:questionId
// Admin deletes a single question — ADMIN ONLY
// ─────────────────────────────────────────────
router.delete("/:questionId", verifyToken, isAdmin, async (req, res) => {
    try {
        const question = await Question.findByIdAndDelete(req.params.questionId);

        if (!question) {
            return res.status(404).json({ message: "Question not found" });
        }

        res.status(200).json({ message: "Question deleted successfully" });
    } catch (error) {
        res.status(500).json({ message: "Error deleting question", error: error.message });
    }
});

module.exports = router;
