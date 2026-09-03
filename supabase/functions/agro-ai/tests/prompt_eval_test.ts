import { assert, assertEquals } from "jsr:@std/assert";
import { isValidQuestion, systemPrompt } from "../prompt.ts";

Deno.test("consultive policy rejects invalid prompts and states safety rules", () => {
  assertEquals(isValidQuestion(""), false);
  assertEquals(isValidQuestion("¿Cuándo regar mis tomates?"), true);
  assert(systemPrompt.includes("nunca inventes"));
  assert(systemPrompt.includes("No ejecutes acciones"));
  assert(systemPrompt.includes("no realices cálculos de riego"));
  assert(systemPrompt.includes("no afirmes leer parcelas"));
});
