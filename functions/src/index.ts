import * as functions from "firebase-functions/v1";
import { defineSecret } from "firebase-functions/params";
import * as admin from "firebase-admin";
import { SecretManagerServiceClient } from "@google-cloud/secret-manager";
import * as https from "https";

admin.initializeApp();

const auth = admin.auth();
const firestore = admin.firestore();

const MANAGERS_COLLECTION = "managers";

type ManagerRole = "admin";

interface CreateAdminData {
  email?: string;
  password?: string;
  displayName?: string;
  role?: string;
}

const secretClient = new SecretManagerServiceClient();

const grokApiKey = defineSecret("GROK_API_KEY");

async function getSecret(secretName: string): Promise<string> {
  const projectId = process.env.GCLOUD_PROJECT || process.env.GOOGLE_CLOUD_PROJECT || "";
  const name = `projects/${projectId}/secrets/${secretName}/versions/latest`;
  const [version] = await secretClient.accessSecretVersion({ name });
  const payload = version.payload?.data;
  if (!payload) throw new Error(`Secret ${secretName} is empty`);
  return typeof payload === "string" ? payload : Buffer.from(payload).toString("utf8");
}

function httpsPost(options: https.RequestOptions, body: string): Promise<string> {
  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      let data = "";
      res.on("data", (chunk) => (data += chunk));
      res.on("end", () => {
        if (res.statusCode && res.statusCode >= 400) {
          reject(new Error(`HTTP ${res.statusCode}: ${data}`));
        } else {
          resolve(data);
        }
      });
    });
    req.on("error", reject);
    req.write(body);
    req.end();
  });
}

interface ChatMessage {
  role: "user" | "assistant" | "system";
  content: string;
}

interface AiChatData {
  message?: string;
  pageContext?: string;
  conversationHistory?: ChatMessage[];
}

interface AiConfig {
  provider: "grok" | "openai";
  model: string;
  systemPrompt: string;
  enabled: boolean;
}

/** Verifies the caller is authenticated and has admin role. */
async function verifyAdmin(context: functions.https.CallableContext): Promise<string> {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "You must be signed in.");
  }
  const uid = context.auth.uid;
  const doc = await firestore.collection(MANAGERS_COLLECTION).doc(uid).get();
  const role = doc.data()?.role as string | undefined;
  if (!doc.exists || role?.toLowerCase() !== "admin") {
    throw new functions.https.HttpsError("permission-denied", "Only admins can create new managers.");
  }
  return uid;
}

/** Create a new manager (admin only) */
export const createAdmin = functions.region("us-central1").https.onCall(
  async (data: CreateAdminData, context: functions.https.CallableContext) => {
    const callerUid = await verifyAdmin(context);

    const callerDoc = await firestore.collection(MANAGERS_COLLECTION).doc(callerUid).get();
    const callerRole = callerDoc.data()?.role as string | undefined;
    const isCallerAdmin = callerRole?.toLowerCase() === "admin";

    if (!callerDoc.exists || !isCallerAdmin) {
      throw new functions.https.HttpsError("permission-denied", "Only admins can create new managers.");
    }

    const email = typeof data?.email === "string" ? data.email.trim() : "";
    const password = typeof data?.password === "string" ? data.password : "";
    const displayName = typeof data?.displayName === "string" ? data.displayName.trim() : "";
    const role: ManagerRole = "admin";

    if (!email || !password) {
      throw new functions.https.HttpsError("invalid-argument", "email and password are required.");
    }

    if (password.length < 6) {
      throw new functions.https.HttpsError("invalid-argument", "Password must be at least 6 characters.");
    }

    try {
      const userRecord = await auth.createUser({
        email,
        password,
        displayName: displayName || undefined,
        emailVerified: false,
      });

      await firestore.collection(MANAGERS_COLLECTION).doc(userRecord.uid).set({
        email: userRecord.email,
        name: displayName || userRecord.displayName || "",
        displayName: displayName || userRecord.displayName || "",
        role,
        createdBy: callerUid,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });

      return { uid: userRecord.uid };
    } catch (err: unknown) {
      const message = err instanceof Error ? err.message : String(err);
      if (message.includes("email address is already in use") || message.includes("already exists")) {
        throw new functions.https.HttpsError("already-exists", "An account with this email already exists.");
      }
      throw new functions.https.HttpsError("internal", message);
    }
  }
);

/** AI Chat Proxy - supports Grok (xAI) and OpenAI */
export const aiChatProxy = functions.region("us-central1").https.onCall(
  async (data: AiChatData, context: functions.https.CallableContext) => {
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "يجب تسجيل الدخول.");
    }

    const message = typeof data?.message === "string" ? data.message.trim() : "";
    if (!message) {
      throw new functions.https.HttpsError("invalid-argument", "الرسالة مطلوبة.");
    }

    const pageContext = typeof data?.pageContext === "string" ? data.pageContext : "";
    const history: ChatMessage[] = Array.isArray(data?.conversationHistory)
      ? data.conversationHistory.slice(-10)
      : [];

    // Load AI config from Firestore
    let aiConfig: AiConfig = {
      provider: "grok",
      model: "grok-3-mini",
      systemPrompt: "Your default system prompt here.",
      enabled: true,
    };

    try {
      const configDoc = await firestore.collection("ai_config").doc("settings").get();
      if (configDoc.exists) {
        const d = configDoc.data()!;
        aiConfig = {
          provider: d.provider ?? aiConfig.provider,
          model: d.model ?? aiConfig.model,
          systemPrompt: d.systemPrompt ?? aiConfig.systemPrompt,
          enabled: d.enabled ?? true,
        };
      }
    } catch (e) {
      functions.logger.warn("Could not load ai_config, using defaults", e);
    }

    if (!aiConfig.enabled) {
      throw new functions.https.HttpsError("failed-precondition", "خدمة الذكاء الاصطناعي غير مفعلة حالياً.");
    }

    // Build messages array
    const systemContent = pageContext
      ? `${aiConfig.systemPrompt}\n\nالصفحة الحالية: ${pageContext}`
      : aiConfig.systemPrompt;

    const messages: ChatMessage[] = [
      { role: "system", content: systemContent },
      ...history,
      { role: "user", content: message },
    ];

    const requestBody = JSON.stringify({
      model: aiConfig.model,
      messages,
      max_tokens: 1024,
      temperature: 0.7,
    });

    try {
      let apiKey: string;
      let hostname: string;
      let path: string;

      if (aiConfig.provider === "grok") {
        apiKey = await getSecret("GROK_API_KEY");
        hostname = "api.x.ai";
        path = "/v1/chat/completions";
      } else {
        apiKey = await getSecret("OPENAI_API_KEY");
        hostname = "api.openai.com";
        path = "/v1/chat/completions";
      }

      const options: https.RequestOptions = {
        hostname,
        path,
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${apiKey}`,
          "Content-Length": Buffer.byteLength(requestBody),
        },
      };

      const responseText = await httpsPost(options, requestBody);

      // تنظيف الرد: إزالة Markdown، كلمة "json"، والمسافات الزائدة
      let cleaned = responseText
        .replace(/^\s*```(?:json)?/i, "") // إزالة ``` أو ```json في البداية
        .replace(/```$/g, "")            // إزالة ``` في النهاية
        .replace(/^\s*json\s*:/i, "")    // إزالة "json:" في البداية
        .trim();

      // محاولة التحويل إلى JSON مع معالجة الأخطاء
      let parsed;
      try {
        parsed = JSON.parse(cleaned);
      } catch (e) {
        functions.logger.error("Grok returned invalid JSON", { responseText, cleaned });
        throw new functions.https.HttpsError(
          "internal",
          "خطأ من Grok: لم يُرجع Grok بيانات JSON صالحة"
        );
      }

      if (parsed.error) {
        functions.logger.error("AI provider error", parsed.error);
        throw new functions.https.HttpsError("internal", parsed.error.message ?? "خطأ من مزود الذكاء الاصطناعي.");
      }

      const reply = parsed.choices?.[0]?.message?.content ?? "";
      return { reply, provider: aiConfig.provider, model: aiConfig.model };
    } catch (err: unknown) {
      if (err instanceof functions.https.HttpsError) throw err;
      const msg = err instanceof Error ? err.message : String(err);
      functions.logger.error("aiChatProxy error", msg);
      throw new functions.https.HttpsError("internal", "فشل الاتصال بخدمة الذكاء الاصطناعي.");
    }
  }
);

/** Delete a manager (admin only) */
export const deleteManager = functions.region("us-central1").https.onCall(
  async (data: { uid?: string }, context: functions.https.CallableContext) => {
    const callerUid = await verifyAdmin(context);

    const callerDoc = await firestore.collection(MANAGERS_COLLECTION).doc(callerUid).get();
    const callerRole = callerDoc.data()?.role as string | undefined;
    const isCallerAdmin = callerRole?.toLowerCase() === "admin";

    if (!callerDoc.exists || !isCallerAdmin) {
      throw new functions.https.HttpsError("permission-denied", "Only admins can delete managers.");
    }

    const targetUid = typeof data?.uid === "string" ? data.uid.trim() : "";

    if (!targetUid) {
      throw new functions.https.HttpsError("invalid-argument", "uid is required.");
    }

    if (targetUid === callerUid) {
      throw new functions.https.HttpsError("invalid-argument", "You cannot delete yourself.");
    }

    try {
      await firestore.collection(MANAGERS_COLLECTION).doc(targetUid).delete();
    } catch (firestoreErr: unknown) {
      const msg = firestoreErr instanceof Error ? firestoreErr.message : String(firestoreErr);
      throw new functions.https.HttpsError("failed-precondition", `Delete failed: ${msg}`);
    }

    try {
      await auth.deleteUser(targetUid);
    } catch (authErr: unknown) {
      functions.logger.warn("Could not delete auth user", authErr);
    }

    return { success: true };
  }
);

// ─── Profit Margins Scheduled Update (daily 10:00 AM KSA = 07:00 UTC) ────────

const SAUDI_BANKS = [
  "بنك الراجحي", "البنك الأهلي السعودي", "مصرف الإنماء", "بنك الرياض",
  "بنك الجزيرة", "بنك ساب", "البنك السعودي الفرنسي", "البنك العربي الوطني",
  "بنك البلاد", "بنك الاستثمار السعودي", "البنك الخليجي الدولي",
];

// ─── المنتجات الثمانية مع المعرّفات والأسماء ────────────────────────────────

const PRODUCT_KEYS = [
  { key: "personalBasic",               label: "تمويل شخصي عادي" },
  { key: "personalSpecial",             label: "تمويل شخصي مخصص" },
  { key: "realEstateSupportedProgram",  label: "تمويل عقاري مدعوم – برنامج سكني" },
  { key: "realEstateSupportedMinistry", label: "تمويل عقاري مدعوم – وزارة الإسكان" },
  { key: "realEstateCommercial",        label: "تمويل عقاري اعتيادي – تجاري" },
  { key: "realEstateResident",          label: "تمويل عقاري اعتيادي – مقيم" },
  { key: "leasingVehicles",             label: "تمويل تأجيري – سيارات" },
  { key: "leasingEquipment",            label: "تمويل تأجيري – معدات" },
];

// ─── Prompt لجلب هوامش الربح عبر الذكاء الاصطناعي ────────────────────────────

const PROFIT_MARGIN_PROMPT = `أنت محلل مالي متخصص في السوق السعودي.
ابحث عن هوامش الربح الحالية للبنوك السعودية التالية لثمانية منتجات تمويلية.
البنوك: ${SAUDI_BANKS.join("، ")}.

المنتجات المطلوبة (8 منتجات):
${PRODUCT_KEYS.map((p, i) => (i + 1) + ". " + p.key + " (" + p.label + ")").join("\n")}

أرجع الإجابة بتنسيق JSON فقط بهذا الشكل بالضبط (بدون أي نص خارج JSON):
{
  "banks": [
    {
      "bankId": "rajhi",
      "bankName": "بنك الراجحي",
      "products": {
        "personalBasic":               { "min": 3.99, "max": 5.50, "available": true },
        "personalSpecial":             { "min": 3.75, "max": 5.00, "available": true },
        "realEstateSupportedProgram":  { "min": 3.50, "max": 4.75, "available": true },
        "realEstateSupportedMinistry": { "min": 2.50, "max": 3.50, "available": true },
        "realEstateCommercial":        { "min": 4.00, "max": 5.50, "available": true },
        "realEstateResident":          { "min": 3.75, "max": 5.00, "available": true },
        "leasingVehicles":             { "min": 4.00, "max": 6.00, "available": true },
        "leasingEquipment":            { "min": 4.50, "max": 6.50, "available": true }
      }
    }
  ],
  "summary": "ملخص قصير عن أبرز التغييرات في هوامش الربح"
}

معرّفات البنوك بالترتيب: rajhi, snb, inma, riyadh, jazira, saab, fransi, anb, bilad, sibc, gib.
إذا لم يقدم بنك منتجاً معيناً، ضع available: false وقيم min/max = 0.
استخدم أحدث المعلومات المتاحة. لا تُضف أي نص خارج JSON.`;

// ─── Scheduled: تحديث هوامش الربح يومياً 10:00 صباحاً بتوقيت الرياض (07:00 UTC) ──

export const updateProfitMargins = functions
  .region("us-central1")
  .runWith({ secrets: ["GROK_API_KEY"] })
  .pubsub.schedule("0 7 * * *")
  .timeZone("UTC")
  .onRun(async () => {
    functions.logger.info("updateProfitMargins: starting daily run");

    const apiKey = grokApiKey.value();
    if (!apiKey) {
      functions.logger.error("updateProfitMargins: GROK_API_KEY is not set");
      return;
    }

    const requestBody = JSON.stringify({
      model: "grok-3",
      messages: [
        { role: "user", content: PROFIT_MARGIN_PROMPT },
      ],
      max_tokens: 2048,
      temperature: 0.2,
    });

    const options: https.RequestOptions = {
      hostname: "api.x.ai",
      path: "/v1/chat/completions",
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${apiKey}`,
        "Content-Length": Buffer.byteLength(requestBody),
      },
    };

    let rawResponse: string;
    try {
      rawResponse = await httpsPost(options, requestBody);
    } catch (e) {
      functions.logger.error("updateProfitMargins: API call failed", e);
      return;
    }

    let parsed: Record<string, unknown>;
    try {
      const apiResponse = JSON.parse(rawResponse) as Record<string, unknown>;
      const choices = apiResponse.choices as Array<{ message: { content: string } }>;
      const content = choices?.[0]?.message?.content ?? "";

      const jsonMatch = content.match(/\{[\s\S]*\}/);
      if (!jsonMatch) {
        functions.logger.error("updateProfitMargins: no JSON found in response", content);
        return;
      }
      parsed = JSON.parse(jsonMatch[0]) as Record<string, unknown>;
    } catch (e) {
      functions.logger.error("updateProfitMargins: JSON parse failed", e);
      return;
    }

    try {
      await firestore.doc("bank_rates/profit_margins").set({
        banks: parsed.banks ?? [],
        aiSummary: parsed.summary ?? "",
        lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        updatedBy: "grok-scheduled",
      }, { merge: true });
      functions.logger.info("updateProfitMargins: Firestore updated successfully");
    } catch (e) {
      functions.logger.error("updateProfitMargins: Firestore write failed", e);
    }
  });

export const triggerProfitMarginsUpdate = functions.region("us-central1").runWith({ secrets: ["GROK_API_KEY"] }).https.onCall(
  async (_data: unknown, context: functions.https.CallableContext) => {
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "You must be signed in.");
    }
    const uid = context.auth.uid;
    const managerDoc = await firestore.collection(MANAGERS_COLLECTION).doc(uid).get();
    if (!managerDoc.exists) {
      throw new functions.https.HttpsError("permission-denied", "Managers only.");
    }

    functions.logger.info("triggerProfitMarginsUpdate: manual run by", uid);

    const apiKey = grokApiKey.value();
    if (!apiKey) {
      throw new functions.https.HttpsError("internal", "فشل الحصول على مفتاح Grok.");
    }

    const requestBody = JSON.stringify({
      model: "grok-3",
      messages: [{ role: "user", content: PROFIT_MARGIN_PROMPT }],
      max_tokens: 2048,
      temperature: 0.2,
    });

    const options: https.RequestOptions = {
      hostname: "api.x.ai",
      path: "/v1/chat/completions",
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${apiKey}`,
        "Content-Length": Buffer.byteLength(requestBody),
      },
    };

    let rawResponse: string;
    try {
      rawResponse = await httpsPost(options, requestBody);
    } catch (e) {
      const errMsg = e instanceof Error ? e.message : String(e);
      functions.logger.error("triggerProfitMarginsUpdate: Grok API call failed", { error: errMsg, keyLength: apiKey?.length ?? 0 });
      throw new functions.https.HttpsError("internal", `فشل الاتصال بـ Grok API: ${errMsg}`);
    }

    let parsed: Record<string, unknown>;
    try {
      const apiResponse = JSON.parse(rawResponse) as Record<string, unknown>;
      const choices = apiResponse.choices as Array<{ message: { content: string } }>;
      const content = choices?.[0]?.message?.content ?? "";
      const jsonMatch = content.match(/\{[\s\S]*\}/);
      if (!jsonMatch) {
        throw new functions.https.HttpsError("internal", "لم يُرجع Grok بيانات JSON صالحة.");
      }
      parsed = JSON.parse(jsonMatch[0]) as Record<string, unknown>;
    } catch (e) {
      if (e instanceof functions.https.HttpsError) throw e;
      throw new functions.https.HttpsError("internal", "فشل تحليل رد Grok.");
    }

    try {
      await firestore.doc("bank_rates/profit_margins").set({
        banks: parsed.banks ?? [],
        aiSummary: parsed.summary ?? "",
        lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        updatedBy: "grok-manual",
      }, { merge: true });
    } catch (e) {
      throw new functions.https.HttpsError("internal", "فشل حفظ البيانات في Firestore.");
    }

    return { success: true, summary: parsed.summary ?? "" };
  }
);

// ─── Auto-create Firestore user doc on Auth signup ────────────────────────────
export const onUserCreated = functions
  .region("us-central1")
  .auth.user()
  .onCreate(async (user) => {
    const providerId = user.providerData[0]?.providerId ?? "password";
    let provider = "email";
    if (providerId.includes("google")) provider = "google";
    else if (providerId.includes("apple")) provider = "apple";
    else if (providerId.includes("password")) provider = "email";

    try {
      await firestore.collection("users").doc(user.uid).set({
        email: user.email ?? "",
        displayName: user.displayName ?? "",
        provider,
        providerId,
        createdAt: admin.firestore.Timestamp.fromDate(new Date(user.metadata.creationTime)),
      }, { merge: true });
    } catch (e) {
      functions.logger.error("onUserCreated: failed to create Firestore doc", e);
    }
  });

// ─── Sync Auth users → Firestore users collection ─────────────────────────────
export const syncAuthUsers = functions.region("us-central1").https.onCall(
  async (_data: unknown, context: functions.https.CallableContext) => {
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "You must be signed in.");
    }
    const callerUid = context.auth.uid;
    const managerDoc = await firestore.collection(MANAGERS_COLLECTION).doc(callerUid).get();
    if (!managerDoc.exists) {
      throw new functions.https.HttpsError("permission-denied", "Managers only.");
    }

    let nextPageToken: string | undefined;
    let created = 0;
    let updated = 0;
    let total = 0;

    do {
      const result = await auth.listUsers(1000, nextPageToken);
      for (const u of result.users) {
        total++;
        const providerId = u.providerData[0]?.providerId ?? "password";
        let provider = "email";
        if (providerId.includes("google")) provider = "google";
        else if (providerId.includes("apple")) provider = "apple";
        else if (providerId.includes("password")) provider = "email";

        const docRef = firestore.collection("users").doc(u.uid);
        const existing = await docRef.get();
        const baseData = {
          email: u.email ?? "",
          displayName: u.displayName ?? "",
          provider,
          providerId,
          createdAt: admin.firestore.Timestamp.fromDate(new Date(u.metadata.creationTime)),
        };
        if (!existing.exists) {
          await docRef.set(baseData);
          created++;
        } else {
          await docRef.set({ provider, providerId }, { merge: true });
          updated++;
        }
      }
      nextPageToken = result.pageToken;
    } while (nextPageToken);

    return { success: true, total, created, updated };
  }
);

// ─── Send FCM push when a new notification is created ─────────────────────────
export const sendNotificationPush = functions
  .region("us-central1")
  .firestore.document("app_notifications/{notifId}")
  .onCreate(async (snap, context) => {
    const data = snap.data();
    if (!data) return;

    const title = (data.title as string) ?? "";
    const message = (data.message as string) ?? "";
    const isMandatory = (data.isMandatory as boolean) ?? false;
    const notifId = context.params.notifId;

    // Collect FCM tokens from users collection
    const usersSnap = await firestore.collection("users").get();
    const tokens: string[] = [];
    usersSnap.forEach((doc) => {
      const t = doc.data().fcmToken;
      if (typeof t === "string" && t.length > 0) tokens.push(t);
    });

    if (tokens.length === 0) {
      functions.logger.info("sendNotificationPush: no tokens");
      return;
    }

    // FCM allows max 500 tokens per multicast call
    const chunks: string[][] = [];
    for (let i = 0; i < tokens.length; i += 500) {
      chunks.push(tokens.slice(i, i + 500));
    }

    let totalSent = 0;
    let totalFailed = 0;
    for (const chunk of chunks) {
      const res = await admin.messaging().sendEachForMulticast({
        tokens: chunk,
        notification: { title, body: message },
        data: {
          notifId,
          isMandatory: isMandatory ? "true" : "false",
        },
        android: { priority: "high" },
        apns: { payload: { aps: { sound: "default", contentAvailable: true } } },
      });
      totalSent += res.successCount;
      totalFailed += res.failureCount;
    }
    functions.logger.info(`sendNotificationPush: sent=${totalSent} failed=${totalFailed}`);
  });

// ─── Acknowledge notification (called from mobile app) ────────────────────────
export const acknowledgeNotification = functions.region("us-central1").https.onCall(
  async (data: { notifId?: string }, context: functions.https.CallableContext) => {
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "Sign in required.");
    }
    const notifId = data.notifId;
    if (!notifId) {
      throw new functions.https.HttpsError("invalid-argument", "notifId is required.");
    }
    const uid = context.auth.uid;
    await firestore
      .doc(`app_notifications/${notifId}/acknowledgments/${uid}`)
      .set({
        acknowledgedAt: admin.firestore.FieldValue.serverTimestamp(),
        uid,
      });
    return { success: true };
  }
);