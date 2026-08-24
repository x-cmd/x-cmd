#!/usr/bin/env -S deno run --allow-read
// SPDX-License-Identifier: AGPL-3.0
//
// x ajv — JSON Schema validator / compiler / migrator / tester.
//
// Invoked by the x-cmd dispatcher in lib/main with clean positional args.
// Do NOT add flag parsing here — the shell wrapper handles -s/-d/-o/--valid/--invalid.
//
// Usage (called as):
//   ajv.ts validate <schema> <data>
//   ajv.ts compile   <schema>
//   ajv.ts migrate   <schema> <output>
//   ajv.ts test      <schema> <data> --valid|--invalid
//
// Exit codes:
//   0  — success / expectation met
//   1  — validation / compilation / test failure
//   2  — runtime error (bad JSON, IO error)
//  64  — usage error (unknown subcommand)

import Ajv from "npm:ajv@8.17.1";
import addFormats from "npm:ajv-formats@3.0.1";
import { parse as parseYaml } from "jsr:@std/yaml@1.0.10";
import { parse as parseToml } from "jsr:@std/toml@1.0.0";

// ---------------------------------------------------------------------------
// CLI
// ---------------------------------------------------------------------------
//
// Per-subcommand positional layout (clean args from the x-cmd dispatcher):
//   validate <schema> <file1> [<file2> ...]            → ≥2 positional
//   compile  <schema>                                  → 1 positional
//   migrate  <schema> <output>                         → 2 positional
//   test     <schema> <file> --valid|--invalid         → 2 positional + flag

const sub: string = Deno.args[0] ?? "";
const schema: string = Deno.args[1] ?? ""; // shared: schema path
const arg2:   string = Deno.args[2] ?? ""; // data path or output path
const flag:   string = Deno.args[3] ?? ""; // --valid / --invalid (test only)

let output: string | undefined;
let expect: string | undefined;

switch (sub) {
    case "validate":
        // No single `data` slot — see dataFiles() for the multi-file list.
        break;
    case "compile":
        break;
    case "migrate":
        output = arg2;
        break;
    case "test":
        // `arg2` is the data file path; the flag carries --valid/--invalid.
        expect = flag === "--valid" || flag === "--invalid" ? flag.slice(2) : undefined;
        break;
}

// ---------------------------------------------------------------------------
// IO
// ---------------------------------------------------------------------------

// Wraps a low-level I/O failure (file missing, is a directory,
// permission denied, …) so callers can distinguish from parse errors
// and report the right result code.
class IoError extends Error {
    readonly path: string;
    readonly code?: string;
    constructor(path: string, cause: unknown) {
        const m = cause instanceof Error ? cause.message : String(cause);
        super(m);
        this.name = "IoError";
        this.path = path;
        if (cause instanceof Error && "code" in cause) {
            this.code = String((cause as { code: unknown }).code);
        }
    }
}

// Read a data file.  Throws IoError if the file can't be read, or
// ParseError if the format-specific parser rejects the content.
async function readJson<T = unknown>(p: string): Promise<T> {
    let text: string;
    try {
        text = await Deno.readTextFile(p);
    } catch (e) {
        throw new IoError(p, e);
    }
    return parseData(p, text) as T;
}

// Read a schema file.  Same error semantics as readJson.
async function readSchema(p: string): Promise<Record<string, unknown>> {
    let text: string;
    try {
        text = await Deno.readTextFile(p);
    } catch (e) {
        throw new IoError(p, e);
    }
    return parseData(p, text) as Record<string, unknown>;
}

// Pick JSON / YAML / TOML parsing based on file extension.  Parser errors
// already carry line/column info — we just re-prefix with the path so the
// caller can identify which file failed.
function parseData(p: string, text: string): unknown {
    if (/\.toml$/i.test(p)) {
        try {
            return parseToml(text);
        } catch (e) {
            throw new ParseError(p, "TOML", e);
        }
    }
    if (/\.ya?ml$/i.test(p)) {
        try {
            return parseYaml(text);
        } catch (e) {
            throw new ParseError(p, "YAML", e);
        }
    }
    try {
        return JSON.parse(text);
    } catch (e) {
        throw new ParseError(p, "JSON", e);
    }
}

// Wrap a parser error so the path is recorded (for callers that want it)
// but the message itself stays free of duplication — the TSV output
// already prefixes every line with the path.  Carries `format` and best-effort
// line/column for the JSON detail column.
class ParseError extends Error {
    readonly path: string;
    readonly format: "JSON" | "YAML" | "TOML";
    readonly line?: number;
    readonly column?: number;
    constructor(path: string, format: "JSON" | "YAML" | "TOML", cause: unknown) {
        const m = cause instanceof Error ? cause.message : String(cause);
        super(`${format} parse error: ${m}`);
        this.name = "ParseError";
        this.path = path;
        this.format = format;
        const loc = ParseError.extractLocation(format, m);
        if (loc) {
            this.line = loc.line;
            this.column = loc.column;
        }
    }
    private static extractLocation(
        format: string,
        msg: string,
    ): { line: number; column: number } | null {
        // JSON: "(line L column C)" or "at position N (line L column C)"
        let m = /\(line\s+(\d+)\s+column\s+(\d+)\)/i.exec(msg);
        if (m) return { line: +m[1], column: +m[2] };
        // YAML / TOML: "at line N, column M" or "on line N, column M"
        m = /(?:at|on)\s+line\s+(\d+),?\s+column\s+(\d+)/i.exec(msg);
        if (m) return { line: +m[1], column: +m[2] };
        // YAML fallback: "line N, column M"
        m = /\bline\s+(\d+),?\s+column\s+(\d+)/i.exec(msg);
        if (m) return { line: +m[1], column: +m[2] };
        return null;
    }
}

// Emit an error in x-cmd's log format so it integrates with the rest of
// the toolchain.  Metadata is rendered as siblings of the main message
// (no `more:` block) so it stays easy to grep / pipe.
function logError(msg: string, meta?: Record<string, string>): void {
    console.error(`- E|ajv: ${msg}`);
    if (meta) {
        for (const [k, v] of Object.entries(meta)) {
            console.error(`  ${k}: ${v}`);
        }
    }
}

// ---------------------------------------------------------------------------
// AJV factory
// ---------------------------------------------------------------------------

// Build a single AJV instance.  We always use AJV's default (draft-07)
// Build a single AJV instance.  We always use AJV's default (draft-07)
// build with `strict: false`, which is permissive enough to accept most
// keywords from earlier and later drafts.  The `draft` parameter is
// currently informational only — it could be used later to switch to
// ajv/dist/2019 or ajv/dist/2020 if strict draft-specific behaviour is
// ever required.
function makeAjv(_draft: string | undefined): Ajv {
    const ajv = new Ajv({ allErrors: true, strict: false, verbose: true });
    try {
        addFormats(ajv);
    } catch {
        // ajv-formats may not match a non-07 draft; ignore.
    }
    return ajv;
}

// ---------------------------------------------------------------------------
// Schema migration
// ---------------------------------------------------------------------------

const DRAFTS = [
    "http://json-schema.org/draft-04/schema#",
    "http://json-schema.org/draft-06/schema#",
    "http://json-schema.org/draft-07/schema#",
    "https://json-schema.org/draft/2019-09/schema",
    "https://json-schema.org/draft/2020-12/schema",
];

function migrateSchema(input: Record<string, unknown>): Record<string, unknown> {
    const schema = JSON.parse(JSON.stringify(input)) as Record<string, unknown>;

    const cur = (typeof schema.$schema === "string")
        ? DRAFTS.findIndex((d) => (schema.$schema as string).includes(d.replace(/^https?:/, "")))
        : -1;

    // draft-04/06 → 07+: rename `id` to `$id`.
    if (cur >= 0 && cur < 2 && "id" in schema && !("$id" in schema)) {
        schema.$id = schema.id;
        delete schema.id;
    }

    // Set target $schema (2020-12).
    schema.$schema = DRAFTS[DRAFTS.length - 1];

    return schema;
}

// ---------------------------------------------------------------------------
// Subcommands
// ---------------------------------------------------------------------------

// Result vocabulary — single source of truth so every per-file outcome
// can be grep'd / piped consistently.
const R = {
    Valid:         "valid",
    Invalid:       "invalid",
    Compiled:      "compiled",
    SchemaError:   "schema-error",
    SyntaxError:   "syntax-error",
    IoError:       "io-error",
    WriteError:    "write-error",
    Pass:          "pass",
    Mismatch:      "mismatch",
    Migrated:      "migrated",
} as const;

const SUCCESS_RESULTS: ReadonlySet<string> = new Set([
    R.Valid,
    R.Compiled,
    R.Pass,
    R.Migrated,
]);

// By default we only emit failure rows (errors surface to the user).
// The shell wrapper turns `--all` into AJV_SHOW_ALL=1 so this script
// never has to know about the flag itself.
const SHOW_ALL = Deno.env.get("AJV_SHOW_ALL") === "1";

// Per-run statistics — accumulated as files are processed, then dumped
// to a YAML summary on stderr at the end of each command.
const STATS = {
    total: 0,
    result: { success: 0, "syntax-error": 0, "schema-error": 0 },
    format: { json: 0, yml: 0, toml: 0 },
};

// Collapse the fine-grained result code (Valid / Compiled / Pass / Migrated /
// SyntaxError / SchemaError / Invalid / Mismatch / IoError / WriteError)
// into the three buckets the user actually reads.  Schema-level and
// file-system errors are both reported as "schema-error" — debugging
// an individual row always uses the per-file detail anyway.
function collapseResult(result: string): "success" | "syntax-error" | "schema-error" {
    if (result === R.Valid || result === R.Compiled || result === R.Pass || result === R.Migrated) {
        return "success";
    }
    if (result === R.SyntaxError) return "syntax-error";
    return "schema-error";
}

function detectFormat(file: string): "json" | "yml" | "toml" | null {
    if (/\.ya?ml$/i.test(file)) return "yml";
    if (/\.toml$/i.test(file)) return "toml";
    if (/\.json$/i.test(file)) return "json";
    return null;
}

function bumpStats(result: string, format: string | null): void {
    STATS.total++;
    STATS.result[collapseResult(result)]++;
    if (format !== null) STATS.format[format]++;
}

function emitSummary(): void {
    if (STATS.total === 0) return;
    const lines: string[] = [
        "---",
        `total: ${STATS.total}`,
        "result:",
        `  success: ${STATS.result.success}`,
        `  syntax-error: ${STATS.result["syntax-error"]}`,
        `  schema-error: ${STATS.result["schema-error"]}`,
        "format:",
        `  json: ${STATS.format.json}`,
        `  yml: ${STATS.format.yml}`,
        `  toml: ${STATS.format.toml}`,
        "---",
    ];
    console.error(lines.join("\n"));
}

// Emit one TSV row:
//   <file>\t<result>\t<text>[\t<json>]
// Cols 1-3 are always present (text is a short human description);
// col 4 is an OPTIONAL single-line JSON blob for machine consumption.
// Anything that could break the row (tabs / newlines) is escaped.
function emitResult(
    file: string,
    result: string,
    text: string,
    detail?: Record<string, unknown>,
): void {
    bumpStats(result, detectFormat(file));
    if (!SHOW_ALL && SUCCESS_RESULTS.has(result)) return;
    const safeText = text
        .replace(/\\/g, "\\\\")
        .replace(/\t/g, " ")
        .replace(/\r?\n/g, "\\n");
    const json = detail ? "\t" + JSON.stringify(detail) : "";
    console.log(`${file}\t${result}\t${safeText}${json}`);
}

// Recursively expand a directory into its .yml / .yaml / .json leaf
// files.  Hidden entries (names starting with '.') are skipped so we
// don't walk into .git / .vscode / .DS_Store and friends.  Symlinks
// are not followed — that could otherwise loop on cycles.  The walker
// yields paths in deterministic (sorted) order so a streaming summary
// stays reproducible.
async function* walkFiles(root: string): AsyncIterableIterator<string> {
    let entries: Deno.DirEntry[];
    try {
        entries = [];
        for await (const e of Deno.readDir(root)) entries.push(e);
    } catch {
        return;
    }
    entries.sort((a, b) => (a.name < b.name ? -1 : a.name > b.name ? 1 : 0));
    for (const entry of entries) {
        if (entry.name.startsWith(".")) continue;
        const full = `${root}/${entry.name}`;
        if (entry.isDirectory) {
            yield* walkFiles(full);
        } else if (entry.isFile && /\.(ya?ml|json|toml)$/i.test(entry.name)) {
            yield full;
        }
    }
}

// Resolve a single positional path: file paths pass through; directory
// paths expand into their .yml/.yaml/.json files; missing paths still
// pass through (the caller surfaces the io-error).
async function* expandOne(p: string): AsyncIterableIterator<string> {
    let stat: Deno.FileInfo;
    try {
        stat = await Deno.stat(p);
    } catch {
        yield p;
        return;
    }
    if (stat.isFile) {
        yield p;
    } else if (stat.isDirectory) {
        yield* walkFiles(p);
    } else {
        yield p;
    }
}

// Stream input file paths: positional args from Deno.args first (starting
// at `startIdx`), then (only if there were none) line-by-line from stdin.
// Directories are recursively walked for .yml / .yaml / .json files.
// Throws if no input source is available so callers can map it to exit 64.
async function* iterInputFiles(startIdx: number): AsyncIterableIterator<string> {
    const cli = Deno.args.slice(startIdx).filter((a) => a !== "" && !a.startsWith("--"));
    if (cli.length > 0) {
        for (const p of cli) yield* expandOne(p);
        return;
    }

    if (Deno.stdin.isTerminal()) {
        throw new Error("no input files (positional args or pipe via stdin)");
    }

    let buf = "";
    for await (const chunk of Deno.stdin.readable.pipeThrough(new TextDecoderStream())) {
        buf += chunk;
        let i;
        while ((i = buf.indexOf("\n")) >= 0) {
            const line = buf.slice(0, i).trim();
            buf = buf.slice(i + 1);
            if (line) yield line;
        }
    }
    const tail = buf.trim();
    if (tail) yield tail;
}

// `validate` streams data files: positional args first, then (if none)
// paths from stdin line-by-line.  Output is TSV: <file>\t<result>.
// Exits 1 if any file is invalid.
async function cmdValidate(): Promise<number> {
    let s: Record<string, unknown>;
    try {
        s = await readJson<Record<string, unknown>>(schema);
    } catch (e) {
        const msg = e instanceof Error ? e.message : String(e);
        if (e instanceof IoError) {
            emitResult(schema, R.IoError, msg, { code: e.code });
        } else if (e instanceof ParseError) {
            emitResult(schema, R.SyntaxError, msg, { format: e.format, line: e.line, column: e.column });
        } else {
            emitResult(schema, R.IoError, msg);
        }
        return 1;
    }
    const ajv = makeAjv(typeof s.$schema === "string" ? s.$schema : undefined);
    let v: ReturnType<typeof ajv.compile>;
    try {
        v = ajv.compile(s);
    } catch (e) {
        emitResult(
            schema,
            R.SchemaError,
            e instanceof Error ? e.message : String(e),
        );
        return 1;
    }

    let bad = 0;
    let seen = 0;
    for await (const f of iterInputFiles(2)) {
        seen++;
        let d: unknown;
        try {
            d = await readJson<unknown>(f);
        } catch (e) {
            const msg = e instanceof Error ? e.message : String(e);
            if (e instanceof IoError) {
                emitResult(f, R.IoError, msg, { code: e.code });
            } else if (e instanceof ParseError) {
                emitResult(f, R.SyntaxError, msg, {
                    format: e.format,
                    line: e.line,
                    column: e.column,
                });
            } else {
                emitResult(f, R.IoError, msg);
            }
            bad++;
            continue;
        }
        if (v(d)) {
            emitResult(f, R.Valid, "OK");
            continue;
        }
        // AJV rejection — one row per file; first error drives the text,
        // the JSON column carries structured info.
        const errs = v.errors ?? [];
        const first = errs[0];
        const text = first?.message ?? "invalid";
        const detail = first
            ? {
                instancePath: first.instancePath || undefined,
                schemaPath: first.schemaPath,
                keyword: first.keyword,
                errors: errs.length > 1 ? errs.slice(1).map((e) => ({
                    instancePath: e.instancePath,
                    message: e.message,
                    keyword: e.keyword,
                })) : undefined,
            }
            : undefined;
        emitResult(f, R.Invalid, text, detail);
        bad++;
    }
    if (seen === 0) {
        logError("no data files (positional args or stdin)");
        return 64;
    }
    return bad > 0 ? 1 : 0;
}

// `compile` streams schema files: positional args first, then (if none)
// paths from stdin line-by-line.  Each file is emitted as a TSV row.
async function cmdCompile(): Promise<number> {
    let bad = 0;
    let seen = 0;
    for await (const f of iterInputFiles(1)) {
        seen++;
        let s: Record<string, unknown>;
        try {
            s = await readSchema(f);
        } catch (e) {
            const msg = e instanceof Error ? e.message : String(e);
            if (e instanceof IoError) {
                emitResult(f, R.IoError, msg, { code: e.code });
            } else if (e instanceof ParseError) {
                emitResult(f, R.SyntaxError, msg, {
                    format: e.format,
                    line: e.line,
                    column: e.column,
                });
            } else {
                emitResult(f, R.IoError, msg);
            }
            bad++;
            continue;
        }
        const ajv = makeAjv(typeof s.$schema === "string" ? s.$schema : undefined);
        try {
            ajv.compile(s);
            emitResult(f, R.Compiled, "OK");
        } catch (e) {
            emitResult(
                f,
                R.SchemaError,
                e instanceof Error ? e.message : String(e),
            );
            bad++;
        }
    }
    if (seen === 0) {
        logError("no schema files (positional args or stdin)");
        return 64;
    }
    return bad > 0 ? 1 : 0;
}

async function cmdMigrate(): Promise<number> {
    let original: Record<string, unknown>;
    try {
        original = await readJson<Record<string, unknown>>(schema);
    } catch (e) {
        const msg = e instanceof Error ? e.message : String(e);
        emitResult(schema, R.SyntaxError, msg, e instanceof ParseError ? { format: e.format } : undefined);
        return 1;
    }
    const migrated = migrateSchema(original);
    try {
        await Deno.writeTextFile(output!, JSON.stringify(migrated, null, 2) + "\n");
        emitResult(schema, R.Migrated, `wrote ${output}`, { target: output! });
        return 0;
    } catch (e) {
        emitResult(
            output!,
            R.WriteError,
            e instanceof Error ? e.message : String(e),
            { target: output! },
        );
        return 1;
    }
}

async function cmdTest(): Promise<number> {
    let s: Record<string, unknown>;
    try {
        s = await readJson<Record<string, unknown>>(schema);
    } catch (e) {
        const msg = e instanceof Error ? e.message : String(e);
        emitResult(schema, R.SyntaxError, msg, e instanceof ParseError ? { format: e.format } : undefined);
        return 1;
    }
    let d: unknown;
    try {
        d = await readJson<unknown>(arg2);
    } catch (e) {
        const msg = e instanceof Error ? e.message : String(e);
        emitResult(arg2, R.SyntaxError, msg, e instanceof ParseError ? { format: e.format } : undefined);
        return 1;
    }
    const ajv = makeAjv(typeof s.$schema === "string" ? s.$schema : undefined);
    let v: ReturnType<typeof ajv.compile>;
    try {
        v = ajv.compile(s);
    } catch (e) {
        emitResult(
            schema,
            R.SchemaError,
            e instanceof Error ? e.message : String(e),
        );
        return 1;
    }
    const actual = v(d);
    const wanted = expect === "valid";
    if (actual === wanted) {
        emitResult(arg2, R.Pass, `expected ${expect}, got ${actual ? "valid" : "invalid"}`, { expected: expect });
        return 0;
    }
    const errs = v.errors ?? [];
    const detail = {
        expected: expect,
        got: actual ? "valid" : "invalid",
        instancePath: errs[0]?.instancePath || undefined,
        keyword: errs[0]?.keyword || undefined,
    };
    const text = `expected ${expect}, got ${actual ? "valid" : "invalid"}`;
    emitResult(arg2, R.Mismatch, text, detail);
    return 1;
}

// ---------------------------------------------------------------------------
// Entry
// ---------------------------------------------------------------------------

async function main(): Promise<number> {
    if (!sub) {
        console.error("x ajv: subcommand required (validate | compile | migrate | test)");
        return 64;
    }
    switch (sub) {
        case "validate": return await cmdValidate();
        case "compile":  return await cmdCompile();
        case "migrate":  return await cmdMigrate();
        case "test":     return await cmdTest();
        default:
            console.error(`x ajv: unknown subcommand: ${sub}`);
            return 64;
    }
}

let code = 0;
try {
    code = await main();
} catch (e) {
    console.error(`x ajv: ${e instanceof Error ? e.message : String(e)}`);
    code = 2;
}
emitSummary();
Deno.exit(code);