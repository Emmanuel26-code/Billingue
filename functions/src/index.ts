import Anthropic from "@anthropic-ai/sdk";
import { initializeApp } from "firebase-admin/app";
import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { defineSecret } from "firebase-functions/params";
import { HttpsError, onCall } from "firebase-functions/v2/https";

initializeApp();

// La clé vit uniquement côté serveur (Secret Manager en prod,
// functions/.secret.local avec l'émulateur). Jamais dans l'app.
const ANTHROPIC_API_KEY = defineSecret("ANTHROPIC_API_KEY");

const MODEL = "claude-opus-5-5";
const MAX_HISTORY = 20; // messages envoyés par requête
const MAX_CHARS = 2000; // par message
const DAILY_LIMIT = 50; // messages par utilisateur et par jour

const SYSTEM_PROMPT = `Tu es Aya, une assistante spécialisée dans la langue Baoulé de Côte d'Ivoire 🇨🇮.
Tu aides les utilisateurs à apprendre le Baoulé à travers l'application Billingue.

Tes règles :
- Tu réponds TOUJOURS en français, mais tu inclus les mots/phrases en Baoulé quand c'est pertinent
- Tu donnes des exemples concrets avec la prononciation quand possible
- Tu es encourageante, chaleureuse et pédagogique
- Si on te demande une traduction, tu donnes le mot en Baoulé + un exemple d'usage
- Tu expliques aussi la culture Akan et ivoirienne quand c'est lié
- Tu ne réponds qu'aux sujets liés au Baoulé, à la Côte d'Ivoire et à l'apprentissage des langues
- Si on te pose une question hors sujet, tu ramènes gentiment la conversation au Baoulé
- Tu te présentes comme Aya au premier message
- Réponses courtes (quelques phrases), adaptées à un écran de téléphone

Vocabulaire de base que tu maîtrises :
- Akwaba = Bienvenue/Bonjour
- N'dɛ = Comment vas-tu ?
- Mi si = Je vais bien
- Mɛ = Merci
- Yako = Courage/Condoléances
- Ngon = 1, Abien = 2, Abla = 3, Anon = 4, Nyo = 5, Nsia = 6, Ason = 7, Asien = 8, Akron = 9, Bla = 10
- Ni = Mère, Ba = Père, Wa = Enfant, Kaka = Grand-mère
- Fiɛ = Rouge, Fitɛ = Blanc, Tete = Noir, Blɔ = Vert, Sran = Jaune
- Nzue = Eau, Mlo = Igname, Mi di = Je mange, Mi nuan = Je bois, Kpɔ = Poisson`;

type ChatMessage = { role: "user" | "assistant"; content: string };

function parseHistory(raw: unknown): ChatMessage[] {
  if (!Array.isArray(raw) || raw.length === 0) {
    throw new HttpsError("invalid-argument", "messages doit être une liste non vide.");
  }
  const msgs = raw.slice(-MAX_HISTORY).map((m) => {
    const role = (m as ChatMessage)?.role;
    const content = (m as ChatMessage)?.content;
    if ((role !== "user" && role !== "assistant") || typeof content !== "string") {
      throw new HttpsError("invalid-argument", "Message mal formé.");
    }
    const text = content.trim().slice(0, MAX_CHARS);
    if (!text) throw new HttpsError("invalid-argument", "Message vide.");
    return { role, content: text };
  });
  // L'API exige que la conversation commence et finisse par l'utilisateur.
  while (msgs.length && msgs[0].role !== "user") msgs.shift();
  if (!msgs.length || msgs[msgs.length - 1].role !== "user") {
    throw new HttpsError("invalid-argument", "Le dernier message doit venir de l'utilisateur.");
  }
  return msgs;
}

async function checkQuota(uid: string): Promise<void> {
  const day = new Date().toISOString().slice(0, 10);
  const ref = getFirestore().doc(`chat_usage/${uid}_${day}`);
  await getFirestore().runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const count = (snap.get("count") as number | undefined) ?? 0;
    if (count >= DAILY_LIMIT) {
      throw new HttpsError("resource-exhausted", "Limite quotidienne atteinte, reviens demain 🌙");
    }
    tx.set(ref, { uid, day, count: FieldValue.increment(1) }, { merge: true });
  });
}

export const chatWithAya = onCall(
  { region: "europe-west1", secrets: [ANTHROPIC_API_KEY], maxInstances: 5, timeoutSeconds: 60 },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Connecte-toi pour parler à Aya.");
    }
    const messages = parseHistory((request.data as { messages?: unknown })?.messages);

    const apiKey = ANTHROPIC_API_KEY.value();
    if (!apiKey) {
      throw new HttpsError("failed-precondition", "Le serveur n'a pas de clé Anthropic configurée.");
    }

    await checkQuota(request.auth.uid);

    const client = new Anthropic({ apiKey });
    try {
      const response = await client.beta.messages.create({
        model: MODEL,
        max_tokens: 2000,
        system: SYSTEM_PROMPT,
        output_config: { effort: "low" },
        betas: ["server-side-fallback-2026-07-01"],
        fallbacks: "default",
        messages,
      });

      if (response.stop_reason === "refusal") {
        return { reply: "Je ne peux pas répondre à ça. Parlons plutôt du Baoulé ! 🌺" };
      }
      const reply = response.content
        .flatMap((b) => (b.type === "text" ? [b.text] : []))
        .join("")
        .trim();
      return { reply: reply || "…" };
    } catch (err) {
      if (err instanceof Anthropic.RateLimitError) {
        throw new HttpsError("resource-exhausted", "Aya est très sollicitée, réessaie dans un instant.");
      }
      if (err instanceof Anthropic.AuthenticationError) {
        console.error("Clé Anthropic invalide");
        throw new HttpsError("internal", "Configuration du serveur invalide.");
      }
      if (err instanceof Anthropic.APIError) {
        console.error("Erreur API Anthropic", err.status, err.message);
        throw new HttpsError("unavailable", "Aya est momentanément indisponible.");
      }
      throw err;
    }
  },
);
