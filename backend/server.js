// server.js
// This is the main entry point of our backend app

const express = require("express");
const cors = require("cors");
const connectDB = require("./config/db");

// Import all route files
const authRoutes = require("./routes/authRoutes");
const quizRoutes = require("./routes/quizRoutes");
const questionRoutes = require("./routes/questionRoutes");
const resultRoutes = require("./routes/resultRoutes");

// Create an Express app
const app = express();

// Connect to MongoDB
connectDB();

// Middleware
app.use(cors());
app.use(express.json());

// Routes
// Auth routes — register and login (no token needed for these)
app.use("/api/auth", authRoutes);

// All quiz-related routes (create, read, update, delete quiz)
app.use("/api/quizzes", quizRoutes);

// All question-related routes (add question, get questions)
app.use("/api/questions", questionRoutes);

// All result and leaderboard routes
app.use("/api/results", resultRoutes);

// Home route — just to test if the server is running
app.get("/", (req, res) => {
    res.send("Quiz App Backend is running!");
});

// Start the server
const PORT = 3000;

app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});
