// routes/quizRoutes.js
// This file handles all API routes related to Quizzes

const express = require("express");
const router = express.Router();
const Quiz = require("../models/Quiz");
const Question = require("../models/Question");
const { verifyToken, isAdmin } = require("../middleware/auth");

// ─────────────────────────────────────────────
// POST /api/quizzes
// Admin creates a new quiz — ADMIN ONLY
// ─────────────────────────────────────────────
router.post("/", verifyToken, isAdmin, async (req, res) => {
    try {
        // Get quiz data sent from the app (in the request body)
        const { title, description, timeLimit } = req.body;

        // Create a new Quiz document using the Quiz model
        const quiz = new Quiz({ title, description, timeLimit });

        // Save it to MongoDB
        await quiz.save();

        // Send back the saved quiz as a response
        res.status(201).json({ message: "Quiz created successfully", quiz });
    } catch (error) {
        res.status(500).json({ message: "Error creating quiz", error: error.message });
    }
});

// ─────────────────────────────────────────────
// GET /api/quizzes
// Get all quizzes — any logged-in user (admin or student)
// ─────────────────────────────────────────────
router.get("/", verifyToken, async (req, res) => {
    try {
        // Find all quizzes in the database
        const quizzes = await Quiz.find();

        // Return them as JSON
        res.status(200).json(quizzes);
    } catch (error) {
        res.status(500).json({ message: "Error fetching quizzes", error: error.message });
    }
});

// ─────────────────────────────────────────────
// GET /api/quizzes/:quizId
// Get a single quiz — any logged-in user (admin or student)
// ─────────────────────────────────────────────
router.get("/:quizId", verifyToken, async (req, res) => {
    try {
        // req.params.quizId is the ID from the URL
        const quiz = await Quiz.findById(req.params.quizId);

        // If no quiz found, return a 404 error
        if (!quiz) {
            return res.status(404).json({ message: "Quiz not found" });
        }

        res.status(200).json(quiz);
    } catch (error) {
        res.status(500).json({ message: "Error fetching quiz", error: error.message });
    }
});

// ─────────────────────────────────────────────
// PUT /api/quizzes/:quizId
// Admin updates an existing quiz — ADMIN ONLY
// ─────────────────────────────────────────────
router.put("/:quizId", verifyToken, isAdmin, async (req, res) => {
    try {
        // Find the quiz by ID and update it with new data from req.body
        // { new: true } means return the updated document, not the old one
        const quiz = await Quiz.findByIdAndUpdate(req.params.quizId, req.body, { new: true });

        if (!quiz) {
            return res.status(404).json({ message: "Quiz not found" });
        }

        res.status(200).json({ message: "Quiz updated successfully", quiz });
    } catch (error) {
        res.status(500).json({ message: "Error updating quiz", error: error.message });
    }
});

// ─────────────────────────────────────────────
// DELETE /api/quizzes/:quizId
// Admin deletes a quiz — ADMIN ONLY
// ─────────────────────────────────────────────
router.delete("/:quizId", verifyToken, isAdmin, async (req, res) => {
    try {
        const quiz = await Quiz.findByIdAndDelete(req.params.quizId);

        if (!quiz) {
            return res.status(404).json({ message: "Quiz not found" });
        }

        // Cascade-delete all questions that belong to this quiz
        await Question.deleteMany({ quizId: req.params.quizId });

        res.status(200).json({ message: "Quiz and all its questions deleted successfully" });
    } catch (error) {
        res.status(500).json({ message: "Error deleting quiz", error: error.message });
    }
});

module.exports = router;
