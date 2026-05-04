/**
 * One-time migration: create Firestore user profiles for all existing Firebase Auth users.
 * Run with: npx ts-node src/migrate_users.ts
 */

import * as admin from "firebase-admin";
import * as serviceAccount from "../service-account.json";

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount as admin.ServiceAccount),
});

const firestore = admin.firestore();
const auth = admin.auth();

async function migrateUsers() {
  console.log("Starting user migration...");

  let pageToken: string | undefined;
  let totalMigrated = 0;
  let totalSkipped = 0;

  do {
    const listResult = await auth.listUsers(1000, pageToken);

    for (const user of listResult.users) {
      const docRef = firestore.collection("users").doc(user.uid);
      const doc = await docRef.get();

      if (doc.exists) {
        console.log(`SKIP: ${user.email} (already exists)`);
        totalSkipped++;
        continue;
      }

      await docRef.set({
        uid: user.uid,
        email: user.email ?? "",
        displayName: user.displayName ?? "",
        createdAt: user.metadata.creationTime
          ? admin.firestore.Timestamp.fromDate(new Date(user.metadata.creationTime))
          : admin.firestore.FieldValue.serverTimestamp(),
        provider: user.providerData?.[0]?.providerId ?? "unknown",
      });

      console.log(`MIGRATED: ${user.email}`);
      totalMigrated++;
    }

    pageToken = listResult.pageToken;
  } while (pageToken);

  console.log(`\nDone. Migrated: ${totalMigrated}, Skipped: ${totalSkipped}`);
  process.exit(0);
}

migrateUsers().catch((err) => {
  console.error("Migration failed:", err);
  process.exit(1);
});
