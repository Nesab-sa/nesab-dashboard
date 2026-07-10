/**
 * Nesab AI — Chat Cloud Function (OpenAI)
 * Codebase: "chat" — independent from Dashboard functions.
 *
 * Called by nesab-ai.js (WebView / browser) to get AI replies.
 * Saves every turn to Firestore collection "ai_conversations"
 * with source = "app" (Flutter) or "web" (browser).
 *
 * OpenAI API key is loaded from GCP Secret Manager (OPENAI_API_KEY).
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

const OPENAI_BASE_URL = "https://api.openai.com/v1";
const OPENAI_MODEL = "gpt-4o-mini";
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

async function openaiCall(messages, temperature = 0.3) {
  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey) {
    console.error("[Nesab Chat] OPENAI_API_KEY not set in Secret Manager");
    return null;
  }
  try {
    const res = await fetch(OPENAI_BASE_URL + "/chat/completions", {
      method: "POST",
      headers: {
        "Content-Type": "application/json; charset=utf-8",
        Authorization: "Bearer " + apiKey,
      },
      body: JSON.stringify({ model: OPENAI_MODEL, messages, temperature }),
    });
    if (!res.ok) {
      const errText = await res.text();
      console.error("[Nesab Chat] OpenAI API error:", res.status, errText);
      return null;
    }
    return await res.json();
  } catch (e) {
    console.error("[Nesab Chat] OpenAI fetch error:", e);
    return null;
  }
}

/**
 * chat — HTTP Cloud Function
 * Secret: OPENAI_API_KEY from GCP Secret Manager
 */
exports.chat = functions
  .region("us-central1")
  .runWith({
    timeoutSeconds: 60,
    memory: "256MB",
    secrets: ["OPENAI_API_KEY"],
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

    // Build messages array (system + optional page context + history + user)
    let systemPrompt = SYSTEM_PROMPT + getRelevantKnowledge(context);
    if (context) systemPrompt += "\n\nالصفحة الحالية للمستخدم: " + context;
    const messages = [{ role: "system", content: systemPrompt }];

    // Add history (last 8 turns)
    const recentHistory = history.slice(-8);
    for (const turn of recentHistory) {
      if (turn.role && turn.content && ["user", "assistant"].includes(turn.role)) {
        messages.push({ role: turn.role, content: String(turn.content) });
      }
    }
    messages.push({ role: "user", content: message });

    // OpenAI call
    const response1 = await openaiCall(messages);
    if (!response1) {
      return res.status(500).json({
        reply: "عذراً، حدث خطأ مؤقت في الخادم. حاول مرة أخرى.",
        source: "error",
      });
    }

    // Extract reply
    let finalReply = response1.choices?.[0]?.message?.content;
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
