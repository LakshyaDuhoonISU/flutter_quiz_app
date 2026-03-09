// routes/resultRoutes.js
// This file handles all API routes related to Quiz Results and Leaderboard

const express = require("express");
const router = express.Router();
const Result = require("../models/Result");
const { verifyToken, isStudent } = require("../middleware/auth");
const { create } = require("../models/Quiz");

// ─────────────────────────────────────────────
// POST /api/results
// Student submits their quiz result — STUDENT ONLY
// ─────────────────────────────────────────────
router.post("/", verifyToken, isStudent, async (req, res) => {
    try {
        // Get result data from the request body
        const { username, quizId, score, totalQuestions, timeTaken } = req.body;

        // Create a new Result document
        const result = new Result({ username, quizId, score, totalQuestions, timeTaken });

        // Save to MongoDB
        await result.save();

        res.status(201).json({ message: "Result saved successfully", result });
    } catch (error) {
        res.status(500).json({ message: "Error saving result", error: error.message });
    }
});

// ─────────────────────────────────────────────
// GET /api/results/user/:username
// Get all quiz results for a student — STUDENT ONLY
// Students use this to view their history
// ─────────────────────────────────────────────
router.get("/user/:username", verifyToken, isStudent, async (req, res) => {
    try {
        // Find all results for this username
        // .populate("quizId") fills in the quiz title/details instead of just the ID
        const results = await Result.find({ username: req.params.username }).populate("quizId");

        res.status(200).json(results);
    } catch (error) {
        res.status(500).json({ message: "Error fetching results", error: error.message });
    }
});

// ─────────────────────────────────────────────
// GET /api/results/leaderboard/:quizId
// Get the leaderboard for a quiz — any logged-in user (admin or student)
// ─────────────────────────────────────────────
router.get("/leaderboard/:quizId", verifyToken, async (req, res) => {
    try {
        // Find all results for this quizId
        // Sort by score in descending order (-1 = highest first)
        // Limit to top 20 results so it doesn't return too many
        const leaderboard = await Result.find({ quizId: req.params.quizId })
            // Primary sort: highest score first; tiebreaker: least time taken first
            .sort({ score: -1, timeTaken: 1 })
            .limit(20);

        res.status(200).json(leaderboard);
    } catch (error) {
        res.status(500).json({ message: "Error fetching leaderboard", error: error.message });
    }
});

module.exports = router;
