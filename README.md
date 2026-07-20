# Stint 

**Where ALU students meet ALU startups.** Stint connects students seeking
real internship experience with verified student-led ventures inside the ALU
ecosystem , startups post opportunities, students discover, apply and track
their applications in real time.

Built with **Flutter + Firebase (Auth + Cloud Firestore)** using **Provider**
for state management.

## Demo video

▶️ [Watch the demo on YouTube](https://youtu.be/WJG7AXSupt0)

## The problem

Many ALU students struggle to land internships at established companies, while
student founders on the same campus need help with development, design,
marketing, operations and more. Stint bridges that gap with a trust
layer: only startups **verified by an admin** can post, so students never
apply to ghost ventures.

## Features

| Area | What it does |
|---|---|
| Auth & onboarding | Email/password sign-up restricted to `@alustudent.com`, role selection (student / founder) |
| Startup verification | Founder-created startups start *pending*; an admin approves or rejects them; posting is gated on approval (enforced in security rules too) |
| Opportunity posting | Full CRUD for verified startups: create, edit, close/reopen, delete |
| Discovery & search | Live feed with text search, category chips and skill-match sorting |
| Skill matching | "Matches N of your skills" badges driven by the student's skill profile |
| Applications | Apply with a motivation note, duplicate-application guard, deadline enforcement |
| Application tracking | Status pipeline (Submitted → Reviewed → Accepted/Rejected) that updates on the student's screen in real time |
| Bookmarks | Save opportunities; syncs instantly across tabs |
| Admin console | Verification queue with live badge count + all-startups overview |

## Architecture

```
lib/
├── models/       # Plain Dart data classes + Firestore (de)serialization
├── services/     # The ONLY layer that talks to Firebase (auth + one service per collection)
├── providers/    # ChangeNotifiers: session, discovery filters, startup + application state
├── screens/      # Grouped by flow: auth/ student/ founder/ admin/ shared/
├── widgets/      # Reusable cards, badges, chips, empty states
└── theme/        # Single source of truth for colors & typography
```

**Data flow:** UI watches providers → providers call services → services
stream Firestore snapshots back → providers notify → UI rebuilds. Real-time
sync comes free from Firestore listeners; Provider decides who rebuilds.

**Session wiring:** `AuthProvider` merges the FirebaseAuth state with the
live `users/{uid}` document. `AuthGate` switches between login and the three
role shells purely off provider state — login/logout never needs manual
navigation. Session-scoped providers are re-bound via
`ChangeNotifierProxyProvider` whenever the user changes.

## Firestore schema

| Collection | Key fields |
|---|---|
| `users/{uid}` | name, email, role (`student`/`founder`/`admin`), skills[], bookmarkedOpportunityIds[] |
| `startups/{id}` | ownerUid, name, sector, stage, description, verificationStatus |
| `opportunities/{id}` | startupId, startupName*, title, category, requiredSkills[], paid, commitment, deadline, isOpen |
| `applications/{id}` | opportunityId, opportunityTitle*, startupId, startupName*, studentUid, studentName*, studentSkills[]*, note, status, timestamps |

\* denormalized so lists render from a single query — reads are the dominant
Firestore cost at scale.

Security rules live in [firestore.rules](firestore.rules) and enforce the
same invariants as the UI (verification gate, no self-promotion to admin,
students only write their own applications).

## Setup

### 1. Prerequisites

- Flutter 3.x (`flutter doctor` clean)
- A Google account for Firebase
- Node (for the Firebase CLI) or standalone `firebase-tools`

### 2. Create the Firebase project (one time, ~5 minutes)

1. Go to [console.firebase.google.com](https://console.firebase.google.com) → **Add project** → name it `stint` (Analytics optional → disable is fine).
2. **Build → Authentication → Get started → Sign-in method → Email/Password → Enable**.
3. **Build → Firestore Database → Create database** → production mode → pick a region (e.g. `europe-west1`).
4. In Firestore → **Rules**, paste the contents of [firestore.rules](firestore.rules) and **Publish**.

### 3. Connect this app to your project

```bash
# one-time tool installs
npm install -g firebase-tools
dart pub global activate flutterfire_cli

firebase login
flutterfire configure   # select your stint project + android/ios
```

`flutterfire configure` overwrites the placeholder
[lib/firebase_options.dart](lib/firebase_options.dart) with your real keys.

### 4. Run

```bash
flutter pub get
flutter run          # on an emulator or physical device
```

### 5. Seed the admin account

1. In the app, sign up normally (e.g. `admin.stint@alustudent.com`) as a **Student**.
2. In Firebase Console → Firestore → `users` → that uid → edit `role` → `admin`.
3. Hot-restart the app and log in, you land in the admin console. (There is deliberately no in-app path to becoming admin.)

## Testing

```bash
flutter test      # unit tests: skill matching, email validation, model invariants
flutter analyze   # static analysis (clean)
```

## Demo walkthrough (suggested)

1. Sign up as a **founder** → create a startup → show the *pending* state and the disabled posting UI, and show the `startups` doc in Firebase Console.
2. Log in as **admin** → approve the startup → switch back to founder and show posting unlock **without reloading** (real-time stream).
3. Post an opportunity → show it appear in Firestore Console and instantly in a student's Discover feed.
4. As a **student**: search, filter, bookmark, apply → show the application doc created in the console.
5. As the founder: accept the application → show the student's tracking screen update in real time.
