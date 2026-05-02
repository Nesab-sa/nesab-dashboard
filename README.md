# Nesab Dashboard

A Flutter dashboard for financial services management with Firebase.

## Prerequisites

- Flutter 3.11.0+ (uses .fvmrc for version management)
- Node.js 18+ (for Firebase Functions)
- Firebase project

## Environment Variables

Firebase is configured via google-services.json (Android/iOS) or GoogleService-Info.plist (iOS).

## Setup

### 1. Firebase Setup

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Create Firebase project at https://console.firebase.google.com
```

### 2. Firestore & Storage Rules

Deploy rules:
```bash
firebase deploy --only firestore:rules,storage
```

### 3. Firestore Collections

Create manually in Firebase Console:

| Collection | Purpose |
|------------|---------|
| `managers` | Dashboard users (admins) |
| `users` | End users data |
| `categories` | Service categories |

### 4. First Admin

1. Enable **Email/Password** in Firebase Console → Authentication
2. Sign up with email/password in the app
3. Go to Firestore → `managers` collection
4. Create document with your UID:
```json
{
  "email": "admin@example.com",
  "name": "Admin",
  "displayName": "Admin",
  "role": "admin",
  "createdAt": server timestamp
}
```

### 5. Firebase Functions

```bash
cd functions
npm install
firebase deploy --only functions
```

### 6. Install & Run

```bash
# Using FVM (recommended)
fvm install
fvm use

# Or system Flutter
flutter pub get

# Run
flutter run
```

## Deployment

### Deploy All

```bash
# Firestore rules
firebase deploy --only firestore:rules

# Storage rules
firebase deploy --only storage

# Firebase Functions
cd functions
npm install
firebase deploy --only functions

# Flutter Web
flutter build web --release
firebase deploy --only hosting
```

### Deploy Individual Parts

```bash
# Functions only
cd functions && npm install && firebase deploy --only functions

# Hosting only
firebase deploy --only hosting

# All rules
firebase deploy --only firestore:rules,storage
```

## Project Structure

```
lib/
├── core/           # Shared utilities, routing, theme, localization
├── features/       # Feature modules
│   ├── auth/      # Authentication
│   ├── dashboard/  # Dashboard features
│   └── calculators/ # Calculator tools
firebase.json      # Firebase config
firestore.rules    # Firestore security rules
storage.rules     # Storage security rules
functions/       # Firebase Cloud Functions
```

## Cloud Functions

Two functions are deployed:

1. `createAdmin` - Create new managers (admin only)
2. `deleteManager` - Delete managers (admin only)

To delete old functions that are no longer needed:
```bash
firebase functions:delete aiChatProxy --region us-central1
firebase functions:delete aiChatWeb --region us-central1
firebase functions:delete deleteAiApiKey --region us-central1
firebase functions:delete getAiApiKeyStatus --region us-central1
firebase functions:delete setAiApiKey --region us-central1
```

## Security Rules Summary

| Resource | Read | Write |
|----------|------|-------|
| categories | Authenticated | Authenticated |
| managers | Authenticated | Admin only (functions) |
| users | Authenticated | None |
| settings/* | None | Admin only |
