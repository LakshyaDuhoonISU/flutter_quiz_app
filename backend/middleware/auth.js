// middleware/auth.js
const jwt = require("jsonwebtoken");
const JWT_SECRET = "itm";

// Checks if the request has a valid JWT token in the Authorization header
const verifyToken = (req, res, next) => {
    const authHeader = req.headers["authorization"];

    // If there is no Authorization header at all, reject the request
    if (!authHeader) {
        return res.status(401).json({ message: "Access denied. No token provided. Please log in." });
    }

    // Split "Bearer <token>" into ["Bearer", "<token>"] and take the second part
    const token = authHeader.split(" ")[1];

    if (!token) {
        return res.status(401).json({ message: "Access denied. Token is missing." });
    }

    try {
        // jwt.verify() checks if the token is valid and not expired
        // If valid, it returns the decoded payload (id, username, role)
        const decoded = jwt.verify(token, JWT_SECRET);

        // Attach the decoded user info to req.user so route handlers can use it
        req.user = decoded;

        // Token is valid — continue to the next middleware or route handler
        next();
    } catch (error) {
        // Token is invalid or expired
        return res.status(401).json({ message: "Invalid or expired token. Please log in again." });
    }
};

// isAdmin
// Checks if the logged-in user has the "admin" role
const isAdmin = (req, res, next) => {
    if (req.user.role !== "admin") {
        return res.status(403).json({ message: "Access denied. Admins only." });
    }
    next(); // User is an admin — continue
};

// Checks if the logged-in user has the "student" role
const isStudent = (req, res, next) => {
    if (req.user.role !== "student") {
        return res.status(403).json({ message: "Access denied. Students only." });
    }
    next(); // User is a student — continue
};

module.exports = { verifyToken, isAdmin, isStudent, JWT_SECRET };
