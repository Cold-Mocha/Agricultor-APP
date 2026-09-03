import { createClient } from "jsr:@supabase/supabase-js@2";

type Coordinate = { latitude: number; longitude: number };

const openMeteoBaseUrl = Deno.env.get("OPEN_METEO_FORECAST_URL") ??
  "https://api.open-meteo.com/v1/forecast";
const attributionUrl = "https://open-meteo.com/";

const summaries: Record<number, string> = {
  0: "Despejado",
  1: "Mayormente despejado",
  2: "Parcialmente nublado",
  3: "Nublado",
  45: "Niebla",
  48: "Niebla con escarcha",
  51: "Llovizna ligera",
  53: "Llovizna moderada",
  55: "Llovizna intensa",
  56: "Llovizna helada ligera",
  57: "Llovizna helada intensa",
  61: "Lluvia ligera",
  63: "Lluvia moderada",
  65: "Lluvia intensa",
  66: "Lluvia helada ligera",
  67: "Lluvia helada intensa",
  71: "Nevada ligera",
  73: "Nevada moderada",
  75: "Nevada intensa",
  77: "Granos de nieve",
  80: "Chubascos ligeros",
  81: "Chubascos moderados",
  82: "Chubascos intensos",
  85: "Chubascos de nieve ligeros",
  86: "Chubascos de nieve intensos",
  95: "Tormenta eléctrica",
  96: "Tormenta con granizo ligero",
  99: "Tormenta con granizo intenso",
};

function weatherSummary(code: unknown): string {
  return typeof code === "number" && summaries[code]
    ? summaries[code]
    : "Condición sin descripción";
}

function numberAt(values: unknown, index: number): number {
  if (!Array.isArray(values) || typeof values[index] !== "number") {
    throw new Error("weather_contract_invalid");
  }
  return Number(values[index]);
}

export function normalizeOpenMeteo(
  locality: string,
  payload: Record<string, any>,
  fetchedAt = new Date(),
) {
  const current = payload.current;
  const daily = payload.daily;
  if (
    !current ||
    typeof current.temperature_2m !== "number" ||
    typeof current.relative_humidity_2m !== "number" ||
    typeof current.precipitation !== "number" ||
    typeof current.time !== "string" ||
    !daily ||
    !Array.isArray(daily.time)
  ) {
    throw new Error("weather_contract_invalid");
  }

  const forecast = daily.time.slice(0, 3).map(
    (date: unknown, index: number) => {
      if (typeof date !== "string") throw new Error("weather_contract_invalid");
      return {
        date,
        minimum_c: numberAt(daily.temperature_2m_min, index),
        maximum_c: numberAt(daily.temperature_2m_max, index),
        rain_chance_percent: numberAt(
          daily.precipitation_probability_max,
          index,
        ),
        summary: weatherSummary(numberAt(daily.weather_code, index)),
      };
    },
  );

  const offsetSeconds = typeof payload.utc_offset_seconds === "number"
    ? payload.utc_offset_seconds
    : 0;
  const observedAt = new Date(`${current.time}:00Z`).getTime() -
    offsetSeconds * 1000;
  if (!Number.isFinite(observedAt)) throw new Error("weather_contract_invalid");

  return {
    locality: locality.trim(),
    temperature_c: Number(current.temperature_2m),
    humidity_percent: Math.round(Number(current.relative_humidity_2m)),
    rain_mm: Number(current.precipitation),
    summary: weatherSummary(current.weather_code),
    observed_at: new Date(observedAt).toISOString(),
    fetched_at: fetchedAt.toISOString(),
    expires_at: new Date(fetchedAt.getTime() + 60 * 60 * 1000).toISOString(),
    provider: "open-meteo",
    attribution: "Datos meteorológicos por Open-Meteo.com",
    attribution_url: attributionUrl,
    forecast,
    // Open-Meteo forecast data does not represent official weather warnings.
    alerts: [],
  };
}

export function buildOpenMeteoUrl(coordinate: Coordinate): URL {
  const url = new URL(openMeteoBaseUrl);
  url.searchParams.set("latitude", String(coordinate.latitude));
  url.searchParams.set("longitude", String(coordinate.longitude));
  url.searchParams.set(
    "current",
    [
      "temperature_2m",
      "relative_humidity_2m",
      "apparent_temperature",
      "precipitation",
      "weather_code",
      "wind_speed_10m",
      "wind_direction_10m",
      "wind_gusts_10m",
    ].join(","),
  );
  url.searchParams.set(
    "daily",
    [
      "weather_code",
      "temperature_2m_max",
      "temperature_2m_min",
      "precipitation_sum",
      "precipitation_probability_max",
      "wind_speed_10m_max",
      "wind_gusts_10m_max",
    ].join(","),
  );
  url.searchParams.set(
    "hourly",
    [
      "temperature_2m",
      "relative_humidity_2m",
      "apparent_temperature",
      "precipitation",
      "wind_speed_10m",
      "wind_direction_10m",
      "wind_gusts_10m",
    ].join(","),
  );
  url.searchParams.set("forecast_days", "3");
  url.searchParams.set("timezone", "auto");
  return url;
}

export function coordinateFromGeometry(value: unknown): Coordinate | null {
  if (typeof value === "string") {
    try {
      return coordinateFromGeometry(JSON.parse(value));
    } catch {
      return null;
    }
  }
  if (!value || typeof value !== "object") return null;
  const rings = (value as { coordinates?: unknown }).coordinates;
  if (!Array.isArray(rings) || !Array.isArray(rings[0])) return null;
  const points = rings[0].filter(
    (point): point is [number, number] =>
      Array.isArray(point) &&
      typeof point[0] === "number" &&
      typeof point[1] === "number",
  );
  if (points.length === 0) return null;
  const latitudes = points.map((point) => point[1]);
  const longitudes = points.map((point) => point[0]);
  return {
    latitude: (Math.min(...latitudes) + Math.max(...latitudes)) / 2,
    longitude: (Math.min(...longitudes) + Math.max(...longitudes)) / 2,
  };
}

function defaultCoordinate(): Coordinate | null {
  const latitude = Number(Deno.env.get("OPEN_METEO_DEFAULT_LATITUDE"));
  const longitude = Number(Deno.env.get("OPEN_METEO_DEFAULT_LONGITUDE"));
  return Number.isFinite(latitude) && Number.isFinite(longitude)
    ? { latitude, longitude }
    : null;
}

function projectClientKey(): string | null {
  const legacy = Deno.env.get("SUPABASE_ANON_KEY");
  if (legacy) return legacy;
  const raw = Deno.env.get("SUPABASE_PUBLISHABLE_KEYS");
  if (!raw) return null;
  try {
    const parsed = JSON.parse(raw) as Record<string, unknown>;
    const value = Object.values(parsed).find((entry) =>
      typeof entry === "string"
    );
    return typeof value === "string" ? value : null;
  } catch {
    return null;
  }
}

export async function handleWeatherRequest(request: Request) {
  if (request.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }
  const authorization = request.headers.get("Authorization");
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const clientKey = projectClientKey();
  if (!authorization || !supabaseUrl || !clientKey) {
    return new Response("Unauthorized", { status: 401 });
  }
  const client = createClient(supabaseUrl, clientKey, {
    global: { headers: { Authorization: authorization } },
  });
  const { data: { user } } = await client.auth.getUser();
  if (!user) return new Response("Unauthorized", { status: 401 });

  let body: Record<string, unknown>;
  try {
    body = await request.json();
  } catch {
    return new Response("Invalid request", { status: 400 });
  }
  const locality = body.locality;
  const parcelId = body.parcelId;
  if (typeof locality !== "string" || locality.trim().length < 2) {
    return new Response("Invalid locality", { status: 400 });
  }
  if (parcelId != null && typeof parcelId !== "string") {
    return new Response("Invalid parcel", { status: 400 });
  }

  let coordinate: Coordinate | null = null;
  if (typeof parcelId === "string" && parcelId.length > 0) {
    const { data: parcel, error } = await client
      .from("parcels")
      .select("boundary")
      .eq("id", parcelId)
      .maybeSingle();
    if (error) return new Response("Parcel unavailable", { status: 502 });
    if (!parcel) return new Response("Parcel unavailable", { status: 404 });
    coordinate = coordinateFromGeometry(parcel?.boundary);
  }
  coordinate ??= defaultCoordinate();
  if (!coordinate) {
    return new Response("Weather location not configured", { status: 503 });
  }

  const provider = await fetch(buildOpenMeteoUrl(coordinate), {
    headers: { Accept: "application/json" },
  });
  if (!provider.ok) {
    return new Response("Weather provider unavailable", { status: 502 });
  }
  try {
    return Response.json(normalizeOpenMeteo(locality, await provider.json()));
  } catch {
    return new Response("Weather provider contract invalid", { status: 502 });
  }
}

if (import.meta.main) Deno.serve(handleWeatherRequest);
