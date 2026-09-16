// eget AssetReport — single-file TS port of `x eget assetfit`.
//
//   import { AssetReport } from "./assetfit";
//   const r = AssetReport.parse(json, "owner/repo");
//   r.getFitFor("linux", "x64", "gnu");
//   r.getCoverage();

export class AssetReport {
  static parse(input: unknown, repo: string = ""): AssetReport {
    const release = AssetReport.unwrapRelease(input);
    const pairByBase = AssetReport.indexPairs(release.assets ?? []);
    const rows: AssetRow[] = [];
    for (const a of release.assets ?? []) {
      const fit = AssetReport.classify(a.name, repo);
      if (!fit) continue;
      const row: AssetRow = { asset: a, fit };
      const base = AssetReport.baseName(a.name);
      const hash = pairByBase.sha256.get(base);
      if (hash) row.sha256 = hash;
      const sig = pairByBase.sig.get(base);
      if (sig) row.sig = sig;
      rows.push(row);
    }
    return new AssetReport(release.tag_name, release.name, rows);
  }

  getFitFor(os: string, arch: string, libc?: string): AssetRow[] {
    const target = libc
      ? `native/${os}/${arch}/${libc}`
      : `native/${os}/${arch}`;
    return this.assets.filter((r) => r.fit === target);
  }

  getRuntimeFor(type: string, arch?: string): AssetRow[] {
    const target = arch ? `runtime/${type}/${arch}` : `runtime/${type}`;
    return this.assets.filter((r) => r.fit === target);
  }

  getPackageFor(type: string, arch: string): AssetRow[] {
    return this.assets.filter((r) => r.fit === `package/${type}/${arch}`);
  }

  getCoverage(): { native: string[]; package: string[]; runtime: string[] } {
    const native = new Set<string>();
    const pkg = new Set<string>();
    const runtime = new Set<string>();
    for (const r of this.assets) {
      if (r.fit.startsWith("native/"))  native.add(r.fit.slice("native/".length));
      else if (r.fit.startsWith("package/")) pkg.add(r.fit.slice("package/".length));
      else if (r.fit.startsWith("runtime/")) runtime.add(r.fit.slice("runtime/".length));
    }
    return {
      native: [...native].sort(),
      package: [...pkg].sort(),
      runtime: [...runtime].sort(),
    };
  }

  fitHistogram(): Record<string, number> {
    const out: Record<string, number> = {};
    for (const r of this.assets) {
      out[r.fit] = (out[r.fit] ?? 0) + 1;
    }
    return out;
  }

  readonly tag: string;
  readonly name: string;
  readonly assets: AssetRow[];

  private constructor(tag: string, name: string, assets: AssetRow[]) {
    this.tag = tag;
    this.name = name;
    this.assets = assets;
  }

  private static readonly OS_TOKENS: Record<string, string[]> = {
    darwin:        ["darwin", "macos", "mac-os", "osx", "sonoma", "ventura",
                   "monterey", "catalina", "mojave", "sequoia", "tahoe"],
    "linux-gnu":    ["linux-gnu"],
    "linux-musl":   ["linux-musl"],
    linux:          ["linux", "ubuntu", "debian", "fedora", "centos", "rhel",
                   "alpine", "amzn", "archlinux", "manjaro", "suse",
                   "opensuse", "gentoo", "nixos"],
    "windows-msvc": ["windows-msvc", "pc-windows-msvc", "msvc"],
    "windows-gnu":  ["windows-gnu", "pc-windows-gnu", "mingw"],
    "win-msvc":     ["windows-msvc", "pc-windows-msvc", "msvc"],
    "win-gnu":      ["windows-gnu", "pc-windows-gnu", "mingw"],
    win:            ["windows", "win32", "win64"],
    freebsd:        ["freebsd"],
    openbsd:        ["openbsd"],
    netbsd:         ["netbsd"],
  };

  private static readonly ARCH_TOKENS: Record<string, string[]> = {
    x64:   ["x86_64", "amd64", "x64"],
    arm64: ["aarch64", "armv8", "arm64"],
    "386":  ["i686", "i386", "x86", "386"],
    arm:   ["armv7l", "armv7", "armhf", "armv6", "arm"],
  };

  private static readonly RUNTIME_SUFFIXES: Record<string, string> = {
    ".pex": "pex",   ".whl": "whl",   ".jar": "jar",   ".pyz": "pyz",
    ".js":  "js",    ".sh":  "sh",    ".py":  "py",    ".crate": "crate",
    ".wasm": "wasm", ".ts":  "ts",    ".gem": "gem",  ".nupkg": "nupkg",
    ".vsix": "vsix", ".cosmo": "cosmo", ".rpm": "rpm", ".deb": "deb",
    ".dmg":  "dmg",  ".msi": "msi",   ".apk": "apk",  ".appimage": "appimage",
    ".flatpak": "flatpak", ".snap": "snap", ".pkg.tar.zst": "pkg.tar.zst",
    ".node": "node",
  };

  private static readonly BARE_RUNTIME_TOKENS = new Set<string>([
    "pex", "whl", "jar", "pyz", "js", "sh", "py", "crate",
    "wasm", "ts", "gem", "nupkg", "vsix", "cosmo",
  ]);

  private static readonly OS_BOUND_RUNTIME = new Set<string>([
    "rpm", "deb", "dmg", "msi", "apk", "appimage", "flatpak",
    "snap", "pkg.tar.zst", "node",
  ]);

  private static readonly PAIR_SUFFIXES: readonly string[] = [
    ".sig", ".asc", ".minisig", ".minisig.json", ".pem",
    ".sha256", ".sha256sum", ".sha1", ".sha384", ".sha512",
    ".sha512sum", ".md5", ".sum",
  ];

  private static readonly HASH_SUFFIXES: readonly string[] = [
    ".sha256", ".sha256sum", ".sha1", ".sha384", ".sha512",
    ".sha512sum", ".md5", ".sum",
  ];

  private static readonly SIG_SUFFIXES: readonly string[] = [
    ".sig", ".asc", ".minisig", ".minisig.json", ".pem",
  ];

  private static readonly SKIP_SUFFIXES = new Set<string>([
    ".txt", ".md", ".json", ".jsonl", ".sbom", ".bundle",
    ".bsdiff", ".provenance", ".intoto",
  ]);

  private static readonly PROJECT_RUNTIME_KW: Record<string, string> = {
    "jart/cosmopolitan": "cosmo",
  };

  private static readonly NATIVE_SLOTS: readonly string[] = [
    "darwin/arm64",
    "darwin/x64",
    "linux/x64/gnu",
    "linux/x64/musl",
    "linux/x64",
    "linux/arm64/gnu",
    "linux/arm64/musl",
    "linux/arm64",
    "win/x64/msvc",
    "win/x64/gnu",
    "win/x64",
    "win/arm64/msvc",
  ];

  private static toksContain(tokens: string[], name: string): boolean {
    return tokens.some((t) => name.includes(t));
  }

  private static endsWith(name: string, suf: string): boolean {
    return name.length > suf.length && name.endsWith(suf);
  }

  private static hasAnySuffix(name: string, suffixes: readonly string[]): boolean {
    return suffixes.some((s) => AssetReport.endsWith(name, s));
  }

  private static osHit(lname: string, target: string): number {
    let hitAny = 0;
    for (const [bucket, tokens] of Object.entries(AssetReport.OS_TOKENS)) {
      if (!AssetReport.toksContain(tokens, lname)) continue;
      if (bucket === target) return 1;
      hitAny = 1;
    }
    return hitAny ? -1 : 0;
  }

  private static archHit(lname: string, target: string): number {
    for (const [bucket, tokens] of Object.entries(AssetReport.ARCH_TOKENS)) {
      if (AssetReport.toksContain(tokens, lname)) {
        return bucket === target ? 1 : -1;
      }
    }
    return 0;
  }

  private static archTag(lname: string): "x64" | "arm64" | "" {
    if (AssetReport.toksContain(AssetReport.ARCH_TOKENS.x64, lname))   return "x64";
    if (AssetReport.toksContain(AssetReport.ARCH_TOKENS.arm64, lname)) return "arm64";
    return "";
  }

  private static libcOf(lname: string): string {
    for (const sub of ["linux-gnu", "linux-musl", "windows-msvc", "windows-gnu"]) {
      if (lname.includes(sub)) return sub.split("-")[1];
    }
    return "";
  }

  // Boundary check keeps "xcosmo" from matching the project
  // keyword "cosmo".
  private static projectKeywordHit(lname: string, kw: string): boolean {
    const idx = lname.indexOf(kw);
    if (idx < 0) return false;
    if (idx > 0 && !"-_.".includes(lname[idx - 1])) return false;
    if (idx + kw.length < lname.length &&
        !"-_.".includes(lname[idx + kw.length])) return false;
    return true;
  }

  // Longest-suffix match. Bare-token fallback covers projects
  // that ship a single self-contained file with no extension.
  private static runtimeOf(lname: string): string {
    const dotted = Object.keys(AssetReport.RUNTIME_SUFFIXES)
      .sort((a, b) => b.length - a.length);
    for (const suf of dotted) {
      if (AssetReport.endsWith(lname, suf)) {
        return AssetReport.RUNTIME_SUFFIXES[suf];
      }
    }
    if (AssetReport.BARE_RUNTIME_TOKENS.has(lname)) return lname;
    return "";
  }

  // Universal triggers (literal "universal" keyword or both
  // arch tokens) win over BISCORING's tied score — qjs-linux-
  // riscv64 has no arch token, so its tie isn't a genuine
  // fat binary.
  private static pickBestNative(name: string): string {
    const lname = name.toLowerCase();

    if (/(?:^|[-_.])(?:universal|anyarch|allarch|multiarch)(?:[-_.]|$)/.test(lname)) {
      for (const bucket of ["darwin", "linux", "win", "windows"]) {
        const tokens = AssetReport.OS_TOKENS[bucket];
        if (tokens && AssetReport.toksContain(tokens, lname)) {
          return `native/${bucket}/universal`;
        }
      }
    }

    let hasX64 = false, hasArm64 = false;
    for (const t of AssetReport.ARCH_TOKENS.x64)   if (lname.includes(t)) hasX64   = true;
    for (const t of AssetReport.ARCH_TOKENS.arm64) if (lname.includes(t)) hasArm64 = true;
    if (hasX64 && hasArm64) {
      for (const bucket of ["darwin", "linux", "win", "windows"]) {
        const tokens = AssetReport.OS_TOKENS[bucket];
        if (tokens && AssetReport.toksContain(tokens, lname)) {
          return `native/${bucket}/universal`;
        }
      }
    }

    type Slot = { slot: string; score: number; key: string };
    const candidates: Slot[] = [];
    for (const slot of AssetReport.NATIVE_SLOTS) {
      const parts = slot.split("/");
      const osKey = parts[2] ? `${parts[1]}-${parts[2]}` : parts[1];
      const arch  = parts[1];
      const isFallback = parts.length === 2 || parts[2] === "";
      if (isFallback && AssetReport.libcOf(lname) !== "") continue;
      const oh = AssetReport.osHit(lname, osKey);
      const ah = AssetReport.archHit(lname, arch);
      if (oh === 0 && ah === 0) continue;
      if (!((oh > 0 || ah > 0) && !(oh < 0 && ah < 0))) continue;
      candidates.push({ slot, score: oh + ah, key: slot });
    }
    if (candidates.length === 0) return "";
    candidates.sort((a, b) => b.score - a.score || a.key.localeCompare(b.key));
    return `native/${candidates[0].slot}`;
  }

  private static classify(name: string, repo: string): string {
    const lname = name.toLowerCase();

    if (AssetReport.hasAnySuffix(lname, [...AssetReport.SKIP_SUFFIXES])) return "";
    if (AssetReport.hasAnySuffix(lname, AssetReport.PAIR_SUFFIXES))     return "";

    if (repo) {
      const proj = AssetReport.PROJECT_RUNTIME_KW[repo];
      if (proj && AssetReport.projectKeywordHit(lname, proj)) {
        return `runtime/${proj}`;
      }
    }

    const rtype = AssetReport.runtimeOf(lname);
    if (rtype !== "") {
      if (AssetReport.OS_BOUND_RUNTIME.has(rtype)) {
        const rarch = AssetReport.libcOf(lname) || AssetReport.archTag(lname);
        if (rarch) return `runtime/${rtype}/${rarch}`;
      }
      return `runtime/${rtype}`;
    }

    return AssetReport.pickBestNative(name);
  }

  private static baseName(name: string): string {
    const lname = name.toLowerCase();
    for (const s of AssetReport.PAIR_SUFFIXES) {
      if (AssetReport.endsWith(lname, s)) {
        return name.slice(0, name.length - s.length);
      }
    }
    return name;
  }

  private static indexPairs(assets: GitHubAsset[]): {
    sha256: Map<string, string>;
    sig:    Map<string, string>;
  } {
    const sha256 = new Map<string, string>();
    const sig    = new Map<string, string>();
    for (const a of assets) {
      const lname = a.name.toLowerCase();
      const base = AssetReport.baseName(a.name);
      const url = a.browser_download_url ?? "";
      if (AssetReport.hasAnySuffix(lname, AssetReport.HASH_SUFFIXES)) {
        sha256.set(base, url);
      } else if (AssetReport.hasAnySuffix(lname, AssetReport.SIG_SUFFIXES)) {
        sig.set(base, url);
      }
    }
    return { sha256, sig };
  }

  private static unwrapRelease(input: unknown): GitHubRelease {
    if (input && typeof input === "object" &&
        "release-report" in (input as Record<string, unknown>)) {
      const env = (input as Record<string, unknown>)["release-report"];
      if (env && typeof env === "object" && "release" in (env as Record<string, unknown>)) {
        return (env as Record<string, unknown>).release as GitHubRelease;
      }
    }
    return input as GitHubRelease;
  }
}

export interface GitHubAsset {
  name: string;
  size: number;
  browser_download_url?: string;
  digest?: string;
}

export interface GitHubRelease {
  tag_name: string;
  name: string;
  body?: string;
  published_at?: string;
  assets: GitHubAsset[];
}

export interface AssetRow {
  asset: GitHubAsset;
  fit: string;
  sha256?: string;
  sig?: string;
}
