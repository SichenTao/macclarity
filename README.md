# MacClarity

**Clarity in every gigabyte. Confidence in every action.**

[Chinese](README.zh-CN.md) · [Japanese](README.ja.md) · [Website](docs/en/index.html)

![MacClarity combines a disk flower with evidence-backed performance diagnosis](docs/assets/hero.svg)

MacClarity is an open-source, local-first diagnostic for Mac storage and performance. Its interactive disk flower reveals where space has gone, while measured system trends help explain why the Mac feels slow. Every recommendation stays tied to visible evidence, and every action remains yours to approve.

## Why it is different

- **Space + performance:** inspect allocated storage and a bounded performance session in one evidence model.
- **One source of truth:** the command-line tool, native viewer, and HTML report share one versioned snapshot.
- **Personalized, grounded guidance:** recommendations explain their evidence and never authorize actions.
- **Privacy by construction:** diagnostics work offline; shareable exports deterministically redact local identifiers.
- **Safe actions:** broad roots, symlinks, changed targets, expired approvals, and inherited confirmations fail closed.

![From collection to verified action](docs/assets/diagnosis-flow.svg)

## Install and start

Requires macOS 14+ and Swift 6.

```bash
git clone https://github.com/SichenTao/macclarity.git
cd macclarity
./install.sh
```

Start with the private synthetic demo—no scan required:

```bash
swift run macclarity demo --output macclarity-demo.html
open macclarity-demo.html
```

When you are ready, run a short, read-only diagnosis and open the report:

```bash
swift run macclarity diagnose --path "$HOME" --duration 30 --output report.html
```

The generated report is local-full. Add `--share-redacted` before sharing it.

## What to use first

1. **Disk flower** — best when free space is low or “System Data” looks unusually large.
2. **Performance trend** — best when the Mac feels slow, hot, or frequently pauses.
3. **Checkup** — combines both views when the cause is unclear.

The first release is a source preview. A signed, notarized app download will appear only after the distribution gate is complete.

## Product surfaces

| Surface | Purpose | Status |
|---|---|---|
| Command line | bounded storage/performance collection, JSON and HTML | available |
| Web report | interactive disk flower, diagnosis and trend | available |
| Native app | simple Space / Performance / Checkup entry | preview |
| Personalized guidance | evidence-linked recommendations and read-only inspectors | contract available |
| Cleanup | exact manifest + expiring receipt + Trash staging | developer preview |

## Verify from source

```bash
./scripts/verify.sh
```

The verification gate builds every target, runs tests, validates fixtures, checks resource-budget controls, scans for private data, and renders the demo.

## Privacy and safety

MacClarity requires no network connection for deterministic diagnosis. Exact paths remain in a local-full report; a share-redacted export replaces local identifiers with stable report-local pseudonyms. Never post a local-full report in a public issue. Read [PRIVACY.md](PRIVACY.md), [SECURITY.md](SECURITY.md), and [THREAT_MODEL.md](THREAT_MODEL.md).

## Roadmap

- **Current:** deterministic schema, bounded CLI, rules, interactive HTML, native preview, privacy gate.
- **Next:** signed/notarized binary, deeper application-family attribution, accessibility testing.
- **Later:** opt-in personalized guidance and stable Homebrew distribution after external validation.

Apache-2.0 licensed. Contributions and reproducible bug reports are welcome.
