# Backend — Quiz App API

REST API built with **Node.js**, **ExpressJS**, and **MongoDB** (via Mongoose).

## Architecture

```
backend/
├── server.js              # Entry point — Express app, middleware, route mounting
├── config/
│   └── db.js              # MongoDB connection (mongoose.connect)
├── models/
│   ├── User.js            # username, password (bcrypt hash), role
│   ├── Quiz.js            # title, description, timeLimit
│   ├── Question.js        # quizId (ref), questionText, options[], correctAnswer
│   └── Result.js          # username, quizId (ref), score, totalQuestions
├── middleware/
│   └── auth.js            # verifyToken, isAdmin, isStudent (JWT middleware)
└── routes/
    ├── authRoutes.js      # /api/auth
    ├── quizRoutes.js      # /api/quizzes
    ├── questionRoutes.js  # /api/questions
    └── resultRoutes.js    # /api/results
```

**Port:** `3000`  
**Database:** `mongodb://localhost:27017/quizapp`  
**Auth:** JWT (7-day expiry), sent as `Authorization: Bearer <token>`

### Middleware flow

Every protected route goes through `verifyToken` (decodes JWT and sets `req.user`). Admin-only routes additionally check `isAdmin`; student-only routes check `isStudent`.

---

## API Reference

### Auth — `/api/auth`

| Method | Endpoint    | Auth | Description         |
| ------ | ----------- | ---- | ------------------- |
| POST   | `/register` | None | Register a new user |
| POST   | `/login`    | None | Log in, receive JWT |

**POST `/register`** — body: `{ username, password, role }` (`role`: `"admin"` or `"student"`)

```json
{ "message": "User registered successfully!" }
```

**POST `/login`** — body: `{ username, password }`

```json
{
  "message": "Login successful!",
  "token": "<jwt>",
  "user": { "id": "...", "username": "...", "role": "student" }
}
```

---

### Quizzes — `/api/quizzes`

| Method | Endpoint   | Auth  | Description                     |
| ------ | ---------- | ----- | ------------------------------- |
| POST   | `/`        | Admin | Create a quiz                   |
| GET    | `/`        | Any   | List all quizzes                |
| GET    | `/:quizId` | Any   | Get a single quiz               |
| PUT    | `/:quizId` | Admin | Update a quiz                   |
| DELETE | `/:quizId` | Admin | Delete quiz + all its questions |

**Quiz object:**

```json
{
  "_id": "...",
  "title": "...",
  "description": "...",
  "timeLimit": 60,
  "createdAt": "..."
}
```

> Deleting a quiz cascades — all `Question` documents with the same `quizId` are removed automatically.

---

### Questions — `/api/questions`

| Method | Endpoint       | Auth  | Description                  |
| ------ | -------------- | ----- | ---------------------------- |
| POST   | `/`            | Admin | Add a question to a quiz     |
| GET    | `/:quizId`     | Any   | Get all questions for a quiz |
| PUT    | `/:questionId` | Admin | Edit a question              |
| DELETE | `/:questionId` | Admin | Delete a single question     |

**POST `/`** — body: `{ quizId, questionText, options: ["A","B","C","D"], correctAnswer: 0 }`  
(`correctAnswer` is the 0-based index of the correct option)

**Question object:**

```json
{
  "_id": "...",
  "quizId": "...",
  "questionText": "What is 2+2?",
  "options": ["3", "4", "5", "6"],
  "correctAnswer": 1
}
```

GET `/:quizId` returns `[]` (empty array) when the quiz has no questions.

---

### Results — `/api/results`

| Method | Endpoint               | Auth    | Description                    |
| ------ | ---------------------- | ------- | ------------------------------ |
| POST   | `/`                    | Student | Submit quiz result             |
| GET    | `/user/:username`      | Student | Get a student's result history |
| GET    | `/leaderboard/:quizId` | Any     | Top 20 scores for a quiz       |

**POST `/`** — body: `{ username, quizId, score, totalQuestions }`

**Result object (history):**

```json
{
  "username": "alice",
  "quizId": { "_id": "...", "title": "General Knowledge" },
  "score": 8,
  "totalQuestions": 10,
  "createdAt": "..."
}
```

(`quizId` is populated with quiz details in history; plain ID in leaderboard.)

**Leaderboard entry:**

```json
{ "username": "alice", "quizId": "...", "score": 8, "totalQuestions": 10 }
```

Sorted by `score` descending, limited to 20 entries.

---

## Running

```bash
npm install
npm start        # node server.js
npm run dev      # nodemon server.js (auto-restart on changes)
```
