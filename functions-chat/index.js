/**
 * Nesab AI — Chat Cloud Function (xAI Grok)
 * Codebase: "chat" — independent from Dashboard functions.
 *
 * Called by nesab-ai.js (WebView / browser) to get AI replies.
 * Saves every turn to Firestore collection "ai_conversations"
 * with source = "app" (Flutter) or "web" (browser).
 *
 * xAI API key is loaded from GCP Secret Manager (XAI_API_KEY).
 */
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const fetch = require("node-fetch");
const { dispatchTool } = require("./calculators");
const { SYSTEM_PROMPT, getRelevantKnowledge } = require("./knowledge");

// Initialize Firebase Admin SDK once
if (!admin.apps.length) {
  admin.initializeApp();
}
const db = admin.firestore();

const XAI_BASE_URL = "https://api.x.ai/v1";
const XAI_MODEL = "grok-4.20-reasoning";
const INPUT_MAX_LENGTH = 1500;
const RATE_LIMIT_MAX = 30;

// In-memory rate limiter (resets on cold start)
const rateBuckets = {};

function checkRateLimit(clientId) {
  const now = Date.now();
  if (!rateBuckets[clientId] || now - rateBuckets[clientId].start > 60000) {
    rateBuckets[clientId] = { start: now, count: 0 };
  }
  rateBuckets[clientId].count++;
  return rateBuckets[clientId].count <= RATE_LIMIT_MAX;
}

function guardInput(message) {
  message = message.replace(/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/g, "");
  message = message.replace(/[ \t]{2,}/g, " ").replace(/\n{3,}/g, "\n\n").trim();
  if (message.length > INPUT_MAX_LENGTH) return { error: "رسالتك طويلة جداً. الحد الأقصى " + INPUT_MAX_LENGTH + " حرف." };
  if (!message) return { error: "الرسالة فارغة." };
  const blockPatterns = [/<\?php/i, /<\?=/i, /\bDROP\s+TABLE\b/i, /\bDELETE\s+FROM\b/i, /\bUNION\s+SELECT\b/i, /<script\b/i, /\beval\s*\(/i, /\bignore\s+previous\s+instructions\b/i];
  for (const pat of blockPatterns) {
    if (pat.test(message)) return { error: "تم رفض الرسالة لاحتوائها على محتوى غير مسموح به." };
  }
  return { clean: message };
}

async function xaiCall(input, temperature = 0.3) {
  const apiKey = process.env.XAI_API_KEY;
  if (!apiKey) {
    console.error("[Nesab Chat] XAI_API_KEY not set in Secret Manager");
    return null;
  }
  try {
    const res = await fetch(XAI_BASE_URL + "/responses", {
      method: "POST",
      headers: {
        "Content-Type": "application/json; charset=utf-8",
        Authorization: "Bearer " + apiKey,
      },
      body: JSON.stringify({ model: XAI_MODEL, input, temperature }),
    });
    if (!res.ok) {
      const errText = await res.text();
      console.error("[Nesab Chat] xAI API error:", res.status, errText);
      return null;
    }
    return await res.json();
  } catch (e) {
    console.error("[Nesab Chat] xAI fetch error:", e);
    return null;
  }
}

/**
 * chat — HTTP Cloud Function
 * Secret: XAI_API_KEY from GCP Secret Manager
 */
exports.chat = functions
  .region("us-central1")
  .runWith({
    timeoutSeconds: 60,
    memory: "256MB",
    secrets: ["XAI_API_KEY"],
  })
  .https.onRequest(async (req, res) => {
    // ── CORS + UTF-8 headers ──────────────────────────────────────────────
    res.set("Access-Control-Allow-Origin", "*");
    res.set("Access-Control-Allow-Methods", "POST, OPTIONS");
    res.set("Access-Control-Allow-Headers", "Content-Type");
    res.set("Content-Type", "application/json; charset=utf-8");

    if (req.method === "OPTIONS") return res.status(204).send("");
    if (req.method !== "POST") {
      return res.status(405).json({ reply: "Method not allowed.", source: "error" });
    }

    const data = req.body || {};
    const rawMessage = (data.message || "").trim();
    if (!rawMessage) {
      return res.status(400).json({ reply: "الرسالة فارغة.", source: "error" });
    }

    // Client ID
    const clientId = data.user_id || req.headers["x-forwarded-for"] || req.ip || "unknown";

    // Conversation tracking
    const incomingConvId = (data.conversation_id || "").trim() || null;
    const source = (data.source || "app").trim(); // "app" from Flutter, "web" from browser

    // Rate limit
    if (!checkRateLimit(clientId)) {
      return res.status(429).json({
        reply: "لقد تجاوزت الحد المسموح به من الطلبات. يرجى الانتظار دقيقة.",
        source: "error",
      });
    }

    // Input guard
    const guard = guardInput(rawMessage);
    if (guard.error) return res.status(400).json({ reply: guard.error, source: "error" });
    const message = guard.clean;

    const context = (data.context || "").trim();
    const history = Array.isArray(data.history) ? data.history : [];

    // Build full prompt
    let systemPrompt = SYSTEM_PROMPT + getRelevantKnowledge(context);
    let input = systemPrompt + "\n\n";
    if (context) input += "الصفحة الحالية للمستخدم: " + context + "\n\n";

    // Add history (last 8 turns)
    const recentHistory = history.slice(-8);
    for (const turn of recentHistory) {
      if (turn.role && turn.content && ["user", "assistant"].includes(turn.role)) {
        const label = turn.role === "user" ? "المستخدم" : "نِسَب";
        input += label + ": " + turn.content + "\n";
      }
    }
    input += "المستخدم: " + message + "\nنِسَب:";

    // xAI call
    const response1 = await xaiCall(input);
    if (!response1) {
      return res.status(500).json({
        reply: "عذراً، حدث خطأ مؤقت في الخادم. حاول مرة أخرى.",
        source: "error",
      });
    }

    // Extract reply
    let finalReply = null;
    if (response1.output_text) {
      finalReply = response1.output_text;
    } else if (response1.output && Array.isArray(response1.output)) {
      for (const item of response1.output) {
        if (item.type === "message" && item.content) {
          for (const c of item.content) {
            if (c.type === "output_text" || c.type === "text") {
              finalReply = c.text;
              break;
            }
          }
        }
        if (finalReply) break;
      }
    }
    if (!finalReply && response1.choices && response1.choices[0]) {
      finalReply = response1.choices[0].message?.content;
    }
    if (!finalReply) {
      finalReply = "عذراً، لم أتمكن من معالجة طلبك. حاول مرة أخرى.";
    }

    // ── SAVE TO FIRESTORE (non-blocking) ──────────────────────────────────
    const conversationId = incomingConvId || db.collection("ai_conversations").doc().id;
    const newMessages = [
      { role: "user", content: message },
      { role: "assistant", content: finalReply },
    ];

    const saveToFirestore = async () => {
      const convRef = db.collection("ai_conversations").doc(conversationId);
      const convDoc = await convRef.get();
      if (convDoc.exists) {
        await convRef.update({
          messages: admin.firestore.FieldValue.arrayUnion(...newMessages),
          messageCount: admin.firestore.FieldValue.increment(1),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      } else {
        await convRef.set({
          userId: clientId,
          source: source,
          pageContext: context,
          messages: newMessages,
          messageCount: 1,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
    };

    saveToFirestore().catch((err) =>
      console.error("[Nesab Chat] Firestore save failed:", err)
    );

    return res.status(200).json({
      reply: finalReply,
      source: "ai",
      conversation_id: conversationId,
    });
  });
