# Quiz App

A full-stack online quiz competition app with a Node.js/Express backend and a Flutter frontend. Admins create and manage quizzes; students take timed quizzes and compete on leaderboards.

## Features

- **Role-based access** — separate Admin and Student flows
- **Admin** — create, edit, delete quizzes; manage individual questions (add, edit, delete) per quiz
- **Student** — take timed quizzes, see score breakdown, view quiz history, check leaderboards
- **JWT authentication** — all routes protected; token stored locally on device
- **Cascade delete** — deleting a quiz automatically removes all its questions
- **Leaderboard** — top 20 scores per quiz, with medal badges for top 3

## Project Structure

```
quiz_app/
├── backend/    # Node.js + Express + MongoDB REST API
└── frontend/   # Flutter app (iOS, Android, Web, Desktop)
```

## Running the App

### Prerequisites

- Node.js ≥ 18, MongoDB running locally
- Flutter SDK ≥ 3.10

### 1 — Start MongoDB

```bash
mongod
```

### 2 — Start the backend

```bash
cd backend
npm install
npm start        # or: npm run dev  (uses nodemon)
```

Server runs on `http://localhost:3000`.

### 3 — Run the Flutter app

```bash
cd frontend
flutter pub get
flutter run
```

## Troubleshooting

| Problem                                  | Fix                                                                                                            |
| ---------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| `MongoServerError: connect ECONNREFUSED` | MongoDB is not running — run `mongod`                                                                          |
| `401 Unauthorized` on API calls          | Token expired or missing — log out and log in again                                                            |
| Flutter can't reach the server           | Check `baseUrl` in `lib/services/api_service.dart`; use `10.0.2.2` for Android emulator instead of `localhost` |
| `flutter pub get` fails                  | Run `flutter doctor` and ensure SDK and dependencies are installed                                             |
| Username already taken on register       | Choose a different username; usernames are unique in the database                                              |
