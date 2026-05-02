# Nesab Dashboard – Cloud Functions

## Setup

1. Install dependencies:
   ```bash
   cd functions && npm install
   ```

2. Ensure the Flutter project is linked to a Firebase project (`firebase use` or `firebase init`).

## createAdmin (callable)

- **Name:** `createAdmin`
- **Region:** `us-central1` (change in `src/index.ts` if needed).

**Behavior:**

- Caller must be signed in and exist in the `managers` collection with role `admin`.
- Request body: `{ email: string, password: string, displayName?: string, role?: "admin" | "user" }`.
- Creates a Firebase Auth user (email/password) and writes a document to the `managers` collection with the given role.

**Setting the first manager (admin):**

The first admin cannot be created by this function. Create it manually:

1. In Firebase Console → Authentication, create a user (email/password).
2. In Firestore, add a document at `managers/{uid}` with:
   ```json
   {
     "email": "admin@example.com",
     "name": "Admin Name",
     "displayName": "Admin Name",
     "role": "admin",
     "createdAt": <server timestamp>
   }
   ```
3. Log in to the dashboard with that account and create additional managers via the UI.

## Deploy

```bash
firebase deploy --only functions
```

## Build (TypeScript)

```bash
cd functions && npm run build
```
