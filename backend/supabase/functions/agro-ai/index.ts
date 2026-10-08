import { createClient } from "jsr:@supabase/supabase-js@2";
import { isValidQuestion, systemPrompt } from "./prompt.ts";

Deno.serve(async (request) => {
  const authorization = request.headers.get("Authorization");
  if (!authorization) return new Response("Unauthorized", { status: 401 });
  const client = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_ANON_KEY")!, { global: { headers: { Authorization: authorization } } });
  const { data: { user } } = await client.auth.getUser();
  if (!user) return new Response("Unauthorized", { status: 401 });
  const body = await request.json();
  const allowed = new Set(["client_message_id", "text", "locale", "policy"]);
  if (!body || typeof body !== "object" || Object.keys(body).some((key) => !allowed.has(key)) ||
      typeof body.client_message_id !== "string" || !isValidQuestion(body.text) ||
      typeof body.locale !== "string" || body.policy?.version !== "agroia-general-v1") {
    return new Response("Invalid request", { status: 400 });
  }
  const key = Deno.env.get("GEMINI_API_KEY");
  if (!key) return new Response("AI provider not configured", { status: 503 });
  const model = Deno.env.get("GEMINI_MODEL") ?? "gemini-2.5-flash";
  const endpoint = new URL(`https://generativelanguage.googleapis.com/v1beta/models/${encodeURIComponent(model)}:generateContent`);
  endpoint.searchParams.set("key", key);
  const provider = await fetch(endpoint, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ system_instruction: { parts: [{ text: systemPrompt }] }, contents: [{ role: "user", parts: [{ text: body.text.trim() }] }], generationConfig: { temperature: 0.2, maxOutputTokens: 400 } }),
  });
  if (!provider.ok) return new Response("AI provider unavailable", { status: 502 });
  const payload = await provider.json();
  const answer = payload.candidates?.[0]?.content?.parts?.[0]?.text;
  if (typeof answer !== "string") return new Response("Invalid AI response", { status: 502 });
  return Response.json({
    answer,
    client_message_id: body.client_message_id,
    response_id: payload.responseId ?? `${body.client_message_id}:response`,
    policy_version: "agroia-general-v1",
  });
});
