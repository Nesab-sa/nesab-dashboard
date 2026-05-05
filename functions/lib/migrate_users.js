"use strict";
/**
 * One-time migration: create Firestore user profiles for all existing Firebase Auth users.
 * Run with: npx ts-node src/migrate_users.ts
 */
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
const admin = __importStar(require("firebase-admin"));
const serviceAccount = __importStar(require("../service-account.json"));
admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
});
const firestore = admin.firestore();
const auth = admin.auth();
async function migrateUsers() {
    console.log("Starting user migration...");
    let pageToken;
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
//# sourceMappingURL=migrate_users.js.map