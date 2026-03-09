# Frontend — Quiz App (Flutter)

Cross-platform Flutter app (iOS, Android, Web, Desktop) for the Quiz competition platform.

## Architecture

```
lib/
├── main.dart                        # App entry — SplashScreen routes by role
├── models/
│   ├── user_model.dart              # UserModel { id, username, role }
│   ├── quiz_model.dart              # QuizModel { id, title, description, timeLimit }
│   ├── question_model.dart          # QuestionModel { id, quizId, questionText, options, correctAnswer }
│   └── result_model.dart            # ResultModel { username, quizId, score, totalQuestions, createdAt }
├── services/
│   ├── auth_service.dart            # SharedPreferences wrapper (token, username, role)
│   └── api_service.dart             # All HTTP calls to the backend (baseUrl, auth headers)
├── widgets/
│   ├── timer_widget.dart            # Countdown timer; turns red at ≤30 s, fires onTimeUp at 0
│   └── question_card.dart           # RadioListTile card for a single quiz question
└── screens/
    ├── login_screen.dart            # Login form → saves JWT → routes by role
    ├── register_screen.dart         # Register form (username, password, role dropdown)
    ├── home_screen.dart             # Student home — quiz list, start/leaderboard per quiz
    ├── quiz_screen.dart             # PageView quiz with timer, answer tracking, score submit
    ├── result_screen.dart           # Score summary with colour coding after quiz ends
    ├── leaderboard_screen.dart      # Top 20 scores, medal badges for top 3
    ├── history_screen.dart          # Student's past results with quiz titles
    ├── admin_dashboard.dart         # Admin quiz CRUD + navigate to question management
    └── manage_questions_screen.dart # List, add, edit, delete questions for a quiz
```

### State management

StatefulWidget only — no BLoC or Riverpod. Each screen manages its own state.

### Auth flow

1. JWT returned by backend login is stored in `SharedPreferences`
2. Every API call reads the token via `AuthService.getToken()` and sends it as `Authorization: Bearer <token>`
3. On app launch, `SplashScreen` reads the stored role and navigates to the correct home screen

### Key design decisions

- `baseUrl` is set in `lib/services/api_service.dart` — change this for different environments
- Quiz screen uses `PageView` with `NeverScrollableScrollPhysics` so users navigate with Next/Previous buttons, not swipes
- The timer is shown in the AppBar and displayed in red when ≤ 30 seconds remain; the quiz auto-submits when it hits zero
- Deleting a quiz (admin) is confirmed with a dialog before the API call is made

## Screens summary

| Screen           | Who sees it | What it does                                         |
| ---------------- | ----------- | ---------------------------------------------------- |
| Login            | All         | Authenticate, store token, route by role             |
| Register         | All         | Create account with role                             |
| Home             | Student     | Browse quizzes, start quiz, view history/leaderboard |
| Quiz             | Student     | Answer questions with countdown timer                |
| Result           | Student     | Score summary after quiz                             |
| Leaderboard      | All         | Top 20 scores for a quiz                             |
| History          | Student     | Personal past results                                |
| Admin Dashboard  | Admin       | Create, edit, delete quizzes                         |
| Manage Questions | Admin       | Add, edit, delete individual questions per quiz      |

## Dependencies

| Package              | Version | Purpose                                 |
| -------------------- | ------- | --------------------------------------- |
| `http`               | ^1.2.0  | HTTP requests to the backend            |
| `shared_preferences` | ^2.3.0  | Persist JWT token and user info locally |

## Running

```bash
flutter pub get
flutter run
```

To change the backend URL (e.g. for a physical Android device), update `baseUrl` in `lib/services/api_service.dart`:

```dart
// Android emulator
static const String baseUrl = 'http://10.0.2.2:3000/api';
// Physical device or web
static const String baseUrl = 'http://<your-machine-ip>:3000/api';
```
