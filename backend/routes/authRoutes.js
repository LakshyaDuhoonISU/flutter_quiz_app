// routes/authRoutes.js
// This file handles user registration and login

const express = require("express");
const router = express.Router();
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const User = require("../models/User");
const { JWT_SECRET } = require("../middleware/auth");

// ─────────────────────────────────────────────
// POST /api/auth/register
// Create a new user account (admin or student)
// ─────────────────────────────────────────────
router.post("/register", async (req, res) => {
    try {
        // Get the data sent from the app
        const { username, password, role } = req.body;

        // Check if a user with this username already exists
        const existingUser = await User.findOne({ username });
        if (existingUser) {
            return res.status(400).json({ message: "Username already taken. Please choose another." });
        }

        // Hash the password before saving it
        const hashedPassword = await bcrypt.hash(password, 10);

        // Create a new user with the hashed password
        const user = new User({ username, password: hashedPassword, role });

        // Save to MongoDB
        await user.save();

        res.status(201).json({ message: "User registered successfully!" });
    } catch (error) {
        res.status(500).json({ message: "Error registering user", error: error.message });
    }
});

// ─────────────────────────────────────────────
// POST /api/auth/login
// Log in with username and password, receive a JWT token
// ─────────────────────────────────────────────
router.post("/login", async (req, res) => {
    try {
        const { username, password } = req.body;

        // Check if the user exists in the database
        const user = await User.findOne({ username });
        if (!user) {
            return res.status(400).json({ message: "Invalid username or password." });
        }

        // Compare the plain-text password entered by the user
        // with the hashed password stored in the database
        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            return res.status(400).json({ message: "Invalid username or password." });
        }

        // Create a JWT token that contains the user's id, username, and role
        // The token will expire after 7 days
        const token = jwt.sign(
            { id: user._id, username: user.username, role: user.role },
            JWT_SECRET,
            { expiresIn: "7d" }
        );

        // Send the token and basic user info back to the Flutter app
        res.status(200).json({
            message: "Login successful!",
            token,
            user: {
                id: user._id,
                username: user.username,
                role: user.role,
            },
        });
    } catch (error) {
        res.status(500).json({ message: "Error logging in", error: error.message });
    }
});

module.exports = router;
