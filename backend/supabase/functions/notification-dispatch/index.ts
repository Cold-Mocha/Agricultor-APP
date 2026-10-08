import { createClient } from "jsr:@supabase/supabase-js@2";
import { importPKCS8, SignJWT } from "npm:jose@6";

type ServiceAccount = {
  client_email: string;
  private_key: string;
  project_id: string;
};

async function accessToken(account: ServiceAccount): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const key = await importPKCS8(account.private_key, "RS256");
  const assertion = await new SignJWT({
    scope: "https://www.googleapis.com/auth/firebase.messaging",
  })
    .setProtectedHeader({ alg: "RS256", typ: "JWT" })
    .setIssuer(account.client_email)
    .setSubject(account.client_email)
    .setAudience("https://oauth2.googleapis.com/token")
    .setIssuedAt(now)
    .setExpirationTime(now + 3600)
    .sign(key);
  const response = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "content-type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion,
    }),
  });
  if (!response.ok) throw new Error(`OAuth token request failed: ${response.status}`);
  return (await response.json()).access_token;
}

Deno.serve(async (request) => {
  const authorization = request.headers.get("Authorization");
  if (!authorization) return new Response("Unauthorized", { status: 401 });
  const userClient = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_ANON_KEY")!,
    { global: { headers: { Authorization: authorization } } },
  );
  const { data: { user } } = await userClient.auth.getUser();
  if (!user) return new Response("Unauthorized", { status: 401 });
  const { reminder_id: reminderId } = await request.json();
  const { data: reminder } = await userClient
    .from("reminders")
    .select("id,title,scheduled_at,owner_id")
    .eq("id", reminderId)
    .single();
  if (!reminder) return new Response("Not found", { status: 404 });
  const serviceRole = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );
  const { data: installations, error } = await serviceRole
    .from("device_installations")
    .select("fcm_token")
    .eq("owner_id", user.id);
  if (error) return new Response("Installation lookup failed", { status: 500 });

  const account = JSON.parse(Deno.env.get("FIREBASE_SERVICE_ACCOUNT_JSON")!) as ServiceAccount;
  const token = await accessToken(account);
  const results = await Promise.allSettled((installations ?? []).map(({ fcm_token: fcmToken }) =>
    fetch(`https://fcm.googleapis.com/v1/projects/${account.project_id}/messages:send`, {
      method: "POST",
      headers: {
        authorization: `Bearer ${token}`,
        "content-type": "application/json",
      },
      body: JSON.stringify({
        message: {
          token: fcmToken,
          notification: { title: reminder.title, body: "Tienes una labor pendiente en AgroCampo." },
          data: { reminder_id: reminder.id, deep_link: `/recordatorios?id=${reminder.id}` },
        },
      }),
    })
  ));
  const delivered = results.filter((result) => result.status === "fulfilled" && result.value.ok).length;
  return Response.json({ accepted: true, reminder_id: reminder.id, delivered });
});
