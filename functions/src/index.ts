import * as functions from "firebase-functions/v1";
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

async function getSecret(secretName: string): Promise<string> {
  const projectId = process.env.GCLOUD_PROJECT || process.env.GOOGLE_CLOUD_PROJECT || "";
  const name = `projects/${projectId}/secrets/${secretName}/versions/latest`;
  const [version] = await secretClient.accessSecretVersion({ name });
  const payload = version.payload?.data;
  if (!payload) throw new Error(`Secret ${secretName} is empty`);
  const raw = typeof payload === "string" ? payload : Buffer.from(payload).toString("utf8");
  return raw.trim();
}

function httpsPost(options: https.RequestOptions, body: string): Promise<string> {
  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      const chunks: Buffer[] = [];
      res.on("data", (chunk: Buffer) => chunks.push(chunk));
      res.on("end", () => {
        const data = Buffer.concat(chunks).toString("utf8");
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

function httpsGet(url: string, maxRedirects = 5): Promise<string> {
  return new Promise((resolve, reject) => {
    const parsed = new URL(url);
    const opts: https.RequestOptions = {
      hostname: parsed.hostname,
      path: parsed.pathname + parsed.search,
      method: "GET",
      headers: {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36",
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        "Accept-Language": "ar,en;q=0.9",
      },
      timeout: 15000,
    };
    const req = https.request(opts, (res) => {
      if (res.statusCode && [301, 302, 303, 307, 308].includes(res.statusCode) && res.headers.location && maxRedirects > 0) {
        const loc = res.headers.location;
        const next = loc.startsWith("http") ? loc : `https://${parsed.hostname}${loc}`;
        res.resume();
        resolve(httpsGet(next, maxRedirects - 1));
        return;
      }
      const chunks: Buffer[] = [];
      res.on("data", (chunk: Buffer) => chunks.push(chunk));
      res.on("end", () => {
        const raw = Buffer.concat(chunks).toString("utf8");
        if (res.statusCode && res.statusCode >= 400) reject(new Error(`HTTP ${res.statusCode}`));
        else resolve(raw);
      });
    });
    req.on("timeout", () => { req.destroy(); reject(new Error("Timeout")); });
    req.on("error", reject);
    req.end();
  });
}

function stripHtml(html: string): string {
  return html
    .replace(/<script[^>]*>[\s\S]*?<\/script>/gi, "")
    .replace(/<style[^>]*>[\s\S]*?<\/style>/gi, "")
    .replace(/<nav[^>]*>[\s\S]*?<\/nav>/gi, "")
    .replace(/<footer[^>]*>[\s\S]*?<\/footer>/gi, "")
    .replace(/<header[^>]*>[\s\S]*?<\/header>/gi, "")
    .replace(/<svg[^>]*>[\s\S]*?<\/svg>/gi, "")
    .replace(/<[^>]+>/g, " ")
    .replace(/&nbsp;/gi, " ")
    .replace(/&amp;/gi, "&")
    .replace(/&lt;/gi, "<")
    .replace(/&gt;/gi, ">")
    .replace(/&quot;/gi, "\"")
    .replace(/&#?\w+;/gi, " ")
    .replace(/\s+/g, " ")
    .trim();
}

function extractFinancialContent(text: string, maxLen = 7000): string {
  if (text.length <= maxLen) return text;

  const rateRe = /\d+\.\d+\s*%|%\s*\d+\.\d+/g;
  let m;
  const pos: number[] = [];
  while ((m = rateRe.exec(text)) !== null) {
    const val = parseFloat(m[0].replace(/[% ]/g, ""));
    if (val >= 1 && val <= 15) pos.push(m.index);
  }
  if (pos.length === 0) return text.substring(0, maxLen);

  const W = 400;
  const wins = pos.map((p) => ({ s: Math.max(0, p - W), e: Math.min(text.length, p + W) }));
  const merged = [{ ...wins[0] }];
  for (let i = 1; i < wins.length; i++) {
    const last = merged[merged.length - 1];
    if (wins[i].s <= last.e) last.e = Math.max(last.e, wins[i].e);
    else merged.push({ ...wins[i] });
  }
  let result = "";
  for (const w of merged) {
    if (result.length >= maxLen) break;
    result += text.substring(w.s, w.e) + " [...] ";
  }
  return result.substring(0, maxLen);
}

interface ChatMessage {
  role: "user" | "assistant" | "system";
  content: string;
}

interface AiChatData {
  message?: string;
  pageContext?: string;
  conversationHistory?: ChatMessage[];
  conversationId?: string;
  source?: string;
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

/** AI Chat Proxy - supports OpenAI and Grok AI (xAI) */
export const aiChatProxy = functions.region("us-central1").runWith({ secrets: ["XAI_API_KEY", "OPENAI_API_KEY"] }).https.onCall(
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
      model: "grok-4.3",
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

    // Check if message is about profit margins and fetch relevant data
    let enrichedSystemPrompt = aiConfig.systemPrompt;
    const marginKeywords = /هامش|ربح|معدل|سعر|نسبة|margin|rate|profit|percentage/i;

    if (marginKeywords.test(message)) {
      try {
        const marginsDoc = await firestore.doc("bank_rates/profit_margins").get();
        if (marginsDoc.exists) {
          const marginsData = marginsDoc.data() as Record<string, unknown>;
          const summary = marginsData?.aiSummary as string | undefined;
          if (summary) {
            enrichedSystemPrompt += `\n\nملخص هوامش الربح الحالية:\n${summary}`;
          }
        }
      } catch (e) {
        functions.logger.warn("Could not load profit margins data", e);
        // Continue without margin data
      }
    }

    // Build messages array
    const systemContent = pageContext
      ? `${enrichedSystemPrompt}\n\nالصفحة الحالية: ${pageContext}`
      : enrichedSystemPrompt;

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
      const isOpenAI = aiConfig.provider === "openai";
      const apiKey = isOpenAI
        ? await getSecret("OPENAI_API_KEY")
        : await getSecret("XAI_API_KEY");

      const options: https.RequestOptions = {
        hostname: isOpenAI ? "api.openai.com" : "api.x.ai",
        path: "/v1/chat/completions",
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

      // Save conversation to Firestore
      const conversationId = typeof data?.conversationId === "string" && data.conversationId
        ? data.conversationId
        : firestore.collection("ai_conversations").doc().id;
      const source = typeof data?.source === "string" ? data.source : "app";
      const userId = context.auth!.uid;

      const newMessages = [
        ...history.filter((m) => m.role !== "system"),
        { role: "user" as const, content: message },
        { role: "assistant" as const, content: reply },
      ];

      try {
        const convRef = firestore.collection("ai_conversations").doc(conversationId);
        const convDoc = await convRef.get();
        if (convDoc.exists) {
          await convRef.update({
            messages: newMessages,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            messageCount: newMessages.filter((m) => m.role === "user").length,
            pageContext: pageContext || convDoc.data()?.pageContext || "",
          });
        } else {
          await convRef.set({
            id: conversationId,
            userId,
            source,
            pageContext: pageContext || "",
            messages: newMessages,
            messageCount: 1,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });
        }
      } catch (e) {
        functions.logger.warn("Could not save conversation", e);
      }

      return { reply, provider: aiConfig.provider, model: aiConfig.model, conversationId };
    } catch (err: unknown) {
      if (err instanceof functions.https.HttpsError) throw err;
      const msg = err instanceof Error ? err.message : String(err);
      functions.logger.error("aiChatProxy error", msg);
      throw new functions.https.HttpsError("internal", "فشل الاتصال بخدمة الذكاء الاصطناعي.");
    }
  }
);

/**
 * Save Web Conversation — HTTP endpoint for chat.php to save conversations to Firestore.
 * Called from the PHP backend (api.nesab.sa) after each AI chat exchange.
 * Secured with a shared secret in the X-API-Key header (stored in GCP Secret Manager).
 */
export const saveWebConversation = functions.region("us-central1").runWith({ secrets: ["WEB_CHAT_SYNC_KEY"] }).https.onRequest(
  async (req, res) => {
    // CORS headers
    res.set("Access-Control-Allow-Origin", "*");
    res.set("Access-Control-Allow-Methods", "POST, OPTIONS");
    res.set("Access-Control-Allow-Headers", "Content-Type, X-API-Key");

    if (req.method === "OPTIONS") {
      res.status(204).send("");
      return;
    }

    if (req.method !== "POST") {
      res.status(405).json({ error: "Method not allowed" });
      return;
    }

    // Validate shared secret
    const apiKey = req.headers["x-api-key"] as string || "";
    let expectedKey = "";
    try {
      expectedKey = await getSecret("WEB_CHAT_SYNC_KEY");
    } catch (e) {
      functions.logger.error("Could not load WEB_CHAT_SYNC_KEY", e);
      res.status(500).json({ error: "Server configuration error" });
      return;
    }

    if (!apiKey || apiKey !== expectedKey) {
      res.status(401).json({ error: "Unauthorized" });
      return;
    }

    // Parse body
    const body = req.body;
    const userId = typeof body?.userId === "string" ? body.userId : "web_anonymous";
    const pageContext = typeof body?.pageContext === "string" ? body.pageContext : "";
    const userMessage = typeof body?.userMessage === "string" ? body.userMessage : "";
    const assistantReply = typeof body?.assistantReply === "string" ? body.assistantReply : "";
    const conversationId = typeof body?.conversationId === "string" && body.conversationId
      ? body.conversationId
      : firestore.collection("ai_conversations").doc().id;
    const calcUsed = typeof body?.calcUsed === "string" ? body.calcUsed : "";
    const source = typeof body?.source === "string" && body.source ? body.source : "web";

    if (!userMessage || !assistantReply) {
      res.status(400).json({ error: "userMessage and assistantReply are required" });
      return;
    }

    try {
      const convRef = firestore.collection("ai_conversations").doc(conversationId);
      const convDoc = await convRef.get();

      if (convDoc.exists) {
        // Append new messages to existing conversation
        const existing = convDoc.data();
        const existingMessages = Array.isArray(existing?.messages) ? existing!.messages : [];
        const updatedMessages = [
          ...existingMessages,
          { role: "user", content: userMessage },
          { role: "assistant", content: assistantReply },
        ];
        await convRef.update({
          messages: updatedMessages,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          messageCount: updatedMessages.filter((m: { role: string }) => m.role === "user").length,
          pageContext: pageContext || existing?.pageContext || "",
          ...(calcUsed ? { lastCalcUsed: calcUsed } : {}),
        });
      } else {
        // Create new conversation
        await convRef.set({
          id: conversationId,
          userId,
          source: source,
          pageContext: pageContext || "",
          messages: [
            { role: "user", content: userMessage },
            { role: "assistant", content: assistantReply },
          ],
          messageCount: 1,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          ...(calcUsed ? { lastCalcUsed: calcUsed } : {}),
        });
      }

      res.status(200).json({ success: true, conversationId });
    } catch (e) {
      functions.logger.error("saveWebConversation error", e);
      res.status(500).json({ error: "Failed to save conversation" });
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

// ─── Profit Margins: Official Bank Pricing Pages ──────────────────────────────

const BANK_PRICING_PAGES: Record<string, { urls: string[]; bankName: string }> = {
  rajhi: { urls: [
    "https://www.alrajhibank.com.sa/ar/Personal/Financing-and-Savings-products-for-individuals",
    "https://www.alrajhibank.com.sa/en/Personal/Financing-and-Savings-products-for-individuals",
  ], bankName: "مصرف الراجحي" },
  snb: { urls: [
    "https://www.alahli.com/ar/pages/personal-banking/finance/finance-and-saving-pricing-personal-finance",
    "https://www.alahli.com/ar/pages/personal-banking/finance/finance-and-saving-pricing",
  ], bankName: "البنك الأهلي السعودي" },
  inma: { urls: [
    "https://alinma.com/Prices-Finance-and-Products",
  ], bankName: "مصرف الإنماء" },
  riyadh: { urls: [
    "https://www.riyadbank.com/ar/information/special-pages/arp-disclosure",
    "https://www.riyadbank.com/information/special-pages/arp-disclosure",
  ], bankName: "بنك الرياض" },
  saab: { urls: [
    "https://www.sab.com/ar/personal/prices-of-financing-and-savings-products/",
    "https://www.sab.com/en/personal/prices-of-financing-and-savings-products/",
  ], bankName: "البنك السعودي الأول (ساب)" },
  fransi: { urls: [
    "https://bsf.sa/english/interest-rate-of-finance-and-savings-products",
  ], bankName: "البنك السعودي الفرنسي" },
  anb: { urls: [
    "https://anb.com.sa/web/anb/annual-profit-rate",
  ], bankName: "البنك العربي الوطني" },
  saib: { urls: [
    "https://www.saib.com.sa/en/prices-financing-and-savings-products",
  ], bankName: "البنك السعودي للاستثمار" },
  bilad: { urls: [
    "https://www.bankalbilad.com/en/personal/financing",
  ], bankName: "بنك البلاد" },
  jazira: { urls: [
    "https://www.baj.com.sa/en-us/Personal/Finance/PersonalFinance",
  ], bankName: "بنك الجزيرة" },
  enbd: { urls: [
    "https://www.emiratesnbd.com.sa/en/personal-banking/loans",
  ], bankName: "بنك الإمارات دبي الوطني" },
};

interface BankPageResult { bankId: string; bankName: string; text: string; ok: boolean }

async function fetchBestPage(urls: string[]): Promise<string> {
  for (const url of urls) {
    try {
      const html = await httpsGet(url);
      const raw = stripHtml(html);
      const hasRates = /\d+\.\d+\s*%|%\s*\d+\.\d+/.test(raw);
      if (raw.length >= 200 && hasRates) return extractFinancialContent(raw);
    } catch { /* try next URL */ }
  }
  throw new Error("No URL returned usable content");
}

async function fetchBankPricingPages(): Promise<BankPageResult[]> {
  const entries = Object.entries(BANK_PRICING_PAGES);
  const settled = await Promise.allSettled(
    entries.map(async ([bankId, { urls, bankName }]): Promise<BankPageResult> => {
      try {
        const text = await fetchBestPage(urls);
        return { bankId, bankName, text, ok: true };
      } catch {
        return { bankId, bankName, text: "", ok: false };
      }
    }),
  );
  return settled.map((s) =>
    s.status === "fulfilled" ? s.value : { bankId: "", bankName: "", text: "", ok: false },
  );
}

function buildExtractionPrompt(pages: BankPageResult[]): string {
  let body = "";
  const failed: string[] = [];
  for (const p of pages) {
    if (p.ok) {
      body += `\n\n========== ${p.bankName} (${p.bankId}) ==========\n${p.text}\n`;
    } else {
      failed.push(`${p.bankName} (${p.bankId})`);
    }
  }

  return `أنت خبير استخراج بيانات مالية للبنوك السعودية.

المهمة: استخرج هامش الربح / معدل النسبة السنوي (APR) من صفحات أسعار البنوك الرسمية أدناه.

قواعد صارمة:
1. استخرج فقط الأرقام الرسمية الثابتة الموجودة صراحةً في النصوص.
2. احذف أي عروض ترويجية أو خصومات مؤقتة — احتفظ فقط بالأسعار الرسمية.
3. لا تخترع أو تخمّن أي نسبة. إذا لم تجد المنتج: available:false, min:0, max:0.
4. "min" = أقل نسبة رسمية (أفضل حالة: أطول مدة، تحويل راتب، مبلغ كبير).
5. "max" = أعلى نسبة رسمية (أسوأ حالة: أقصر مدة، بدون تحويل راتب، مبلغ صغير).
6. هامش الربح / معدل النسبة السنوي يشمل الرسوم الإدارية.

المنتجات المطلوبة لكل بنك:

تمويل شخصي:
  - personalBasic: تمويل شخصي جديد (مع المدة والشروط)
  - personalSpecial: تمويل شخصي تكميلي أو شراء مديونية (مع المدة والشروط)

تمويل عقاري مدعوم:
  - realEstateSupportedProgram: عقاري مدعوم — جاهز أو شراء على الخارطة
  - realEstateSupportedMinistry: عقاري مدعوم — بناء ذاتي أو رهن عقار

تمويل عقاري اعتيادي:
  - realEstateCommercial: تمويل عقاري اعتيادي (غير مدعوم)

تمويل تأجيري:
  - leasingVehicles: تأجيري — سيارات بنظام قسط شهري أو نظام 50/50
${failed.length > 0 ? `\nبنوك بدون بيانات (لم يتم جلب صفحتها — ضع جميع منتجاتها available:false):\n${failed.join("\n")}\n` : ""}
=== صفحات البنوك الرسمية ===
${body}

أرجع JSON فقط — بدون markdown أو شرح. الشكل المطلوب:
{"banks":[{"bankId":"rajhi","bankName":"مصرف الراجحي","products":{"personalBasic":{"min":5.47,"max":5.67,"available":true},"personalSpecial":{"min":0,"max":0,"available":false},"realEstateSupportedProgram":{"min":3.25,"max":4.50,"available":true},"realEstateSupportedMinistry":{"min":2.80,"max":3.90,"available":true},"realEstateCommercial":{"min":4.00,"max":5.50,"available":true},"leasingVehicles":{"min":5.80,"max":7.00,"available":true}}}],"summary":"تم الاستخراج من صفحات البنوك الرسمية"}`;
}

// ─── أنواع مساعدة لهوامش الربح ────────────────────────────────────────
interface ProductRate { min?: number; max?: number; available?: boolean }
interface BankRecord { bankId?: string; bankName?: string; products?: Record<string, ProductRate> }

// استخراج النص النهائي من بنية Responses API (دفاعي — يدعم أكثر من شكل)
function extractResponsesText(resp: Record<string, unknown>): string {
  // (1) حقل output_text المختصر
  if (typeof resp.output_text === "string" && resp.output_text.trim()) {
    return resp.output_text;
  }
  // (2) المرور على output[] واستخراج نص الرسالة
  const output = resp.output;
  if (Array.isArray(output)) {
    let text = "";
    for (const item of output) {
      const content = (item as Record<string, unknown>)?.content;
      if (Array.isArray(content)) {
        for (const c of content) {
          const t = (c as Record<string, unknown>)?.text;
          if (typeof t === "string") text += t;
        }
      }
    }
    if (text.trim()) return text;
  }
  // (3) توافق احتياطي مع شكل chat completions
  const choices = resp.choices as Array<{ message?: { content?: string } }> | undefined;
  const fallback = choices?.[0]?.message?.content;
  return typeof fallback === "string" ? fallback : "";
}

function parseBanksJson(content: string): { banks: unknown[]; summary: string } {
  const jsonMatch = content.match(/\{[\s\S]*\}/);
  if (!jsonMatch) throw new Error("No JSON found in Grok response");
  const parsed = JSON.parse(jsonMatch[0]) as { banks: unknown[]; summary: string };
  if (!Array.isArray(parsed.banks) || parsed.banks.length === 0) {
    throw new Error("Grok returned empty banks array");
  }
  return parsed;
}

// هل يحتوي الناتج على أي نسبة صالحة فعلاً؟ (لتقرير الرجوع للاحتياطي)
function hasUsableData(banks: unknown[]): boolean {
  return banks.some((b) => {
    const products = (b as BankRecord)?.products ?? {};
    return Object.values(products).some(
      (p) => p?.available === true && ((p.min ?? 0) > 0 || (p.max ?? 0) > 0),
    );
  });
}

// دمج آمن: لا يمحو نسبة صحيحة قديمة ببيانات جديدة فارغة (available:false / 0)
function mergeBanks(existing: unknown, incoming: unknown[]): unknown[] {
  const existingArr: BankRecord[] = Array.isArray(existing) ? (existing as BankRecord[]) : [];
  const byId = new Map<string, BankRecord>();
  for (const b of existingArr) {
    if (b?.bankId) byId.set(b.bankId, b);
  }

  const usedIds = new Set<string>();
  const result: BankRecord[] = incoming.map((inc) => {
    const incBank = inc as BankRecord;
    const id = incBank?.bankId;
    if (!id) return incBank;
    usedIds.add(id);
    const old = byId.get(id);
    if (!old) return incBank;

    const merged: Record<string, ProductRate> = { ...(old.products ?? {}) };
    for (const [key, prod] of Object.entries(incBank.products ?? {})) {
      const hasValue = prod?.available === true && ((prod.min ?? 0) > 0 || (prod.max ?? 0) > 0);
      if (hasValue) merged[key] = prod; // قيمة جديدة صالحة فقط تُحدّث
    }
    return { bankId: id, bankName: incBank.bankName ?? old.bankName, products: merged };
  });

  // احتفظ بأي بنوك قديمة لم ترد في النتيجة الجديدة
  for (const [id, old] of byId) {
    if (!usedIds.has(id)) result.push(old);
  }
  return result;
}

// ─── المصدر الأساسي: بحث Grok المباشر عبر web_search (Responses API) ────
function buildLiveSearchPrompt(): string {
  const bankLines = Object.entries(BANK_PRICING_PAGES)
    .map(([id, b]) => `- ${id} (${b.bankName}): ${b.urls[0]}`)
    .join("\n");

  return `أنت خبير استخراج بيانات مالية للبنوك السعودية. ابحث الآن في الإنترنت داخل الصفحات الرسمية للبنوك أدناه واستخرج هامش الربح / معدل النسبة السنوي (APR) لكل منتج.

البنوك وصفحاتها الرسمية:
${bankLines}

قواعد صارمة:
1. ابحث في المواقع الرسمية للبنوك أعلاه فقط (ومصادر رسمية مثل SAMA).
2. استخرج "معدل النسبة السنوي التمثيلي المعلَن" (Representative APR) الأبرز قانونياً على صفحة المنتج. وإن لم يُعلن البنك معدلاً تمثيلياً واحداً صريحاً، فخذ نطاق الأرقام الرسمية المعروضة فعلياً على الصفحة (أدنى وأعلى نسبة معلنة). تجاهل أمثلة الحاسبة التفاعلية المتغيرة لحظياً حسب المبلغ والمدة، وتجاهل العروض الترويجية المؤقتة.
3. "min" = المعدل التمثيلي الأدنى المعلَن (أفضل حالة: تحويل راتب + أطول مدة). "max" = المعدل التمثيلي الأعلى المعلَن. وإن أعلن البنك رقماً واحداً فقط (مثل "يبدأ من X%") فاجعل min وmax كلاهما = X.
4. اعتمد الأرقام الرسمية المعلَنة فقط لا الأمثلة العشوائية؛ يجب أن تكون النتيجة قابلة للتكرار (نفس الأرقام عند إعادة البحث).
5. لا تخترع أو تخمّن. إذا لم تجد رقماً رسمياً صريحاً للمنتج: available:false, min:0, max:0.
6. معدل النسبة السنوي يشمل الرسوم الإدارية.

المنتجات المطلوبة لكل بنك:
- personalBasic: تمويل شخصي جديد
- personalSpecial: تمويل شخصي تكميلي أو شراء مديونية
- realEstateSupportedProgram: عقاري مدعوم (جاهز / على الخارطة)
- realEstateSupportedMinistry: عقاري مدعوم (بناء ذاتي / رهن عقار)
- realEstateCommercial: عقاري اعتيادي غير مدعوم
- leasingVehicles: تأجيري سيارات

أرجع JSON فقط بلا markdown أو شرح، بهذا الشكل:
{"banks":[{"bankId":"rajhi","bankName":"مصرف الراجحي","products":{"personalBasic":{"min":5.47,"max":5.67,"available":true},"personalSpecial":{"min":0,"max":0,"available":false},"realEstateSupportedProgram":{"min":3.25,"max":4.50,"available":true},"realEstateSupportedMinistry":{"min":2.80,"max":3.90,"available":true},"realEstateCommercial":{"min":4.00,"max":5.50,"available":true},"leasingVehicles":{"min":5.80,"max":7.00,"available":true}}}],"summary":"ملخص قصير بالعربية"}

استخدم معرّفات البنوك التالية فقط: ${Object.keys(BANK_PRICING_PAGES).join(", ")}.`;
}

async function fetchViaWebSearch(apiKey: string): Promise<{ banks: unknown[]; summary: string }> {
  const prompt = buildLiveSearchPrompt();
  const reqBody = JSON.stringify({
    model: "grok-4.3",
    input: [{ role: "user", content: prompt }],
    tools: [{ type: "web_search" }],
    max_output_tokens: 8192,
  });

  const opts: https.RequestOptions = {
    hostname: "api.x.ai",
    path: "/v1/responses",
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${apiKey.trim()}`,
      "Content-Length": Buffer.byteLength(reqBody),
    },
  };

  const raw = await httpsPost(opts, reqBody);
  const resp = JSON.parse(raw) as Record<string, unknown>;
  const content = extractResponsesText(resp);
  functions.logger.info("profitMargins: web_search response preview", { content: content.substring(0, 600) });
  if (!content.trim()) throw new Error("Empty response from Grok web_search");
  return parseBanksJson(content);
}

// ─── الاحتياطي: جلب الصفحات يدوياً ثم استخراج عبر chat completions ──────
async function fetchViaScraping(apiKey: string): Promise<{ banks: unknown[]; summary: string }> {
  functions.logger.info("profitMargins: fetching official bank pricing pages…");
  const pages = await fetchBankPricingPages();
  const okCount = pages.filter((p) => p.ok).length;
  const failedNames = pages.filter((p) => !p.ok).map((p) => p.bankName);
  functions.logger.info(`profitMargins: ${okCount}/${pages.length} pages fetched`, { failed: failedNames });

  if (okCount === 0) {
    throw new Error("All bank page fetches failed — aborting to avoid saving empty data");
  }

  const prompt = buildExtractionPrompt(pages);
  functions.logger.info("profitMargins: prompt built", { chars: prompt.length });

  const reqBody = JSON.stringify({
    model: "grok-4.3",
    messages: [{ role: "user", content: prompt }],
    max_tokens: 4096,
    temperature: 0.1,
  });

  const opts: https.RequestOptions = {
    hostname: "api.x.ai",
    path: "/v1/chat/completions",
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${apiKey.trim()}`,
      "Content-Length": Buffer.byteLength(reqBody),
    },
  };

  const raw = await httpsPost(opts, reqBody);
  const resp = JSON.parse(raw) as Record<string, unknown>;
  const content = extractResponsesText(resp);
  functions.logger.info("profitMargins: scraping response preview", { content: content.substring(0, 600) });
  return parseBanksJson(content);
}

// ─── المنسّق: web_search أساسي، ثم scraping عند فشله أو خلوّه من النسب ──
async function executeProfitMarginsUpdate(apiKey: string): Promise<{ banks: unknown[]; summary: string }> {
  try {
    const viaSearch = await fetchViaWebSearch(apiKey);
    if (hasUsableData(viaSearch.banks)) {
      functions.logger.info("profitMargins: using Grok web_search result", { count: viaSearch.banks.length });
      return viaSearch;
    }
    functions.logger.warn("profitMargins: web_search returned no usable rates, falling back to scraping");
  } catch (e) {
    functions.logger.warn("profitMargins: web_search failed, falling back to scraping", e);
  }
  return fetchViaScraping(apiKey);
}

// ─── Scheduled: تحديث هوامش الربح يومياً (07:00 UTC = 10:00 AM KSA) ──────────

export const updateProfitMargins = functions
  .region("us-central1")
  .runWith({ secrets: ["XAI_API_KEY"], timeoutSeconds: 540 })
  .pubsub.schedule("30 6 * * *")
  .timeZone("UTC")
  .onRun(async () => {
    functions.logger.info("updateProfitMargins: starting daily run");

    let apiKey: string;
    try {
      apiKey = await getSecret("XAI_API_KEY");
    } catch (e) {
      functions.logger.error("updateProfitMargins: XAI_API_KEY is not set", e);
      return;
    }

    try {
      const result = await executeProfitMarginsUpdate(apiKey);
      const currentSnap = await firestore.doc("bank_rates/profit_margins").get();
      const mergedBanks = mergeBanks(currentSnap.data()?.banks, result.banks);
      await firestore.doc("bank_rates/profit_margins").set({
        banks: mergedBanks,
        aiSummary: result.summary,
        lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        updatedBy: "grok-scheduled",
      }, { merge: true });
      functions.logger.info("updateProfitMargins: Firestore updated successfully");
    } catch (e) {
      functions.logger.error("updateProfitMargins: update failed", e);
    }
  });

// ─── Manual trigger from dashboard ────────────────────────────────────────────

export const triggerProfitMarginsUpdate = functions.region("us-central1").runWith({ secrets: ["XAI_API_KEY"], timeoutSeconds: 540 }).https.onCall(
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

    let apiKey: string;
    try {
      apiKey = await getSecret("XAI_API_KEY");
    } catch (e) {
      throw new functions.https.HttpsError("internal", "فشل الحصول على مفتاح Grok.");
    }

    try {
      const result = await executeProfitMarginsUpdate(apiKey);
      const currentSnap = await firestore.doc("bank_rates/profit_margins").get();
      const mergedBanks = mergeBanks(currentSnap.data()?.banks, result.banks);
      await firestore.doc("bank_rates/profit_margins").set({
        banks: mergedBanks,
        aiSummary: result.summary,
        lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        updatedBy: "grok-manual",
      }, { merge: true });
      return { success: true, summary: result.summary };
    } catch (e) {
      const errMsg = e instanceof Error ? e.message : String(e);
      functions.logger.error("triggerProfitMarginsUpdate: failed", { error: errMsg });
      throw new functions.https.HttpsError("internal", `فشل التحديث: ${errMsg}`);
    }
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