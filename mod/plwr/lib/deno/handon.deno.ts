import { chromium } from "npm:playwright";

const url = Deno.args?.[0];
if (!url) {
  console.error("Usage: handon.deno.ts <url>");
  Deno.exit(64);
}

const home = Deno.env.get("HOME") || Deno.env.get("USERPROFILE") || "";
const dataDir = Deno.env.get("plwr_DATA_DIR") ||
  `${home}/.x-cmd.root/var/x0/mod/plwr`;
const sessionsFile = `${dataDir}/sessions.json`;

let host: string;
try {
  host = new URL(url).host;
} catch {
  console.error(`Invalid URL: ${url}`);
  Deno.exit(64);
}

type Session = {
  url: string;
  savedAt: string;
  storageState: { cookies: unknown[]; origins: unknown[] };
};
type SessionsFile = { version: number; sessions: Record<string, Session> };

let data: SessionsFile = { version: 1, sessions: {} };
try {
  const text = await Deno.readTextFile(sessionsFile);
  const parsed = JSON.parse(text);
  if (parsed && typeof parsed === "object" && parsed.sessions) {
    data = parsed;
  }
} catch (e) {
  if (!(e instanceof Deno.errors.NotFound)) {
    console.error(`Cannot read ${sessionsFile}: ${(e as Error).message}`);
    Deno.exit(1);
  }
}

const existing = data.sessions[host];
(async () => {
  const browser = await chromium.launch({ headless: false });
  const context = await browser.newContext(
    existing?.storageState ? { storageState: existing.storageState } : {},
  );
  const page = await context.newPage();
  await page.goto(url, { waitUntil: "load" });

  console.log(`[plwr] Browser opened for: ${url}`);
  console.log(`[plwr] Host: ${host}`);
  console.log(
    `[plwr] Existing session: ${
      existing ? "yes (will be overwritten)" : "none (creating new)"
    }`,
  );
  console.log(
    `[plwr] Log in / do whatever you need, then press Enter in THIS terminal to save & close.`,
  );
  console.log(`[plwr] Press Ctrl+C to abort — nothing will be saved.`);

  const buf = new Uint8Array(64);
  await Deno.stdin.read(buf);

  const state = await context.storageState();
  data.sessions[host] = {
    url,
    savedAt: new Date().toISOString(),
    storageState: state,
  };

  await Deno.mkdir(dataDir, { recursive: true });
  await Deno.writeTextFile(sessionsFile, JSON.stringify(data, null, 2));

  console.log(`[plwr] Saved session for ${host} -> ${sessionsFile}`);

  await browser.close();
})().catch((err: Error) => {
  console.error(`[plwr] Error: ${err.message || err}`);
  Deno.exit(1);
});
