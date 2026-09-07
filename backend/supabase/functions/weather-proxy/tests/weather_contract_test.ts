import { assertEquals, assertRejects } from "jsr:@std/assert";
import {
  buildOpenMeteoUrl,
  coordinateFromGeometry,
  normalizeOpenMeteo,
} from "../index.ts";

const payload = {
  utc_offset_seconds: -10800,
  current: {
    time: "2026-09-03T12:00",
    temperature_2m: 18.5,
    relative_humidity_2m: 72,
    precipitation: 1.2,
    weather_code: 3,
  },
  daily: {
    time: ["2026-09-03", "2026-09-04", "2026-09-05"],
    weather_code: [3, 61, 0],
    temperature_2m_min: [8, 7, 9],
    temperature_2m_max: [19, 16, 21],
    precipitation_probability_max: [35, 80, 5],
  },
};

Deno.test("normalizes Open-Meteo without inventing official alerts", () => {
  const fetchedAt = new Date("2026-09-03T16:00:00Z");
  const result = normalizeOpenMeteo("Temuco", payload, fetchedAt);
  assertEquals(result.temperature_c, 18.5);
  assertEquals(result.humidity_percent, 72);
  assertEquals(result.rain_mm, 1.2);
  assertEquals(result.summary, "Nublado");
  assertEquals(result.observed_at, "2026-09-03T15:00:00.000Z");
  assertEquals(result.provider, "open-meteo");
  assertEquals(result.attribution_url, "https://open-meteo.com/");
  assertEquals(result.forecast.length, 3);
  assertEquals(result.forecast[1].summary, "Lluvia ligera");
  assertEquals(result.alerts, []);
  assertEquals("key" in result, false);
  assertEquals("apikey" in result, false);
});

Deno.test("builds the requested Open-Meteo forecast contract", () => {
  const url = buildOpenMeteoUrl({ latitude: -38.7363, longitude: -72.5974 });
  assertEquals(
    url.origin + url.pathname,
    "https://api.open-meteo.com/v1/forecast",
  );
  assertEquals(url.searchParams.get("latitude"), "-38.7363");
  assertEquals(url.searchParams.get("longitude"), "-72.5974");
  assertEquals(url.searchParams.get("timezone"), "auto");
  assertEquals(url.searchParams.get("forecast_days"), "3");
  assertEquals(
    url.searchParams.get("daily"),
    "weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum,precipitation_probability_max,wind_speed_10m_max,wind_gusts_10m_max",
  );
  assertEquals(
    url.searchParams.get("hourly"),
    "temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,wind_speed_10m,wind_direction_10m,wind_gusts_10m",
  );
  assertEquals(url.searchParams.has("apikey"), false);
});

Deno.test("uses the center of an authorized parcel GeoJSON boundary", () => {
  assertEquals(
    coordinateFromGeometry({
      type: "Polygon",
      coordinates: [[
        [-72.61, -38.75],
        [-72.58, -38.75],
        [-72.58, -38.72],
        [-72.61, -38.72],
        [-72.61, -38.75],
      ]],
    }),
    { latitude: -38.735, longitude: -72.595 },
  );
  assertEquals(coordinateFromGeometry("invalid"), null);
});

Deno.test("rejects a malformed Open-Meteo current payload", async () => {
  await assertRejects(
    async () => {
      normalizeOpenMeteo("Temuco", { current: {} });
    },
    Error,
    "weather_contract_invalid",
  );
});
