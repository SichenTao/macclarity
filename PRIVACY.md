# Privacy

MacClarity performs deterministic diagnosis locally and does not require a network connection. The CLI does not include telemetry.

## Data classes

| Data | Purpose | Local-full | Share-redacted |
|---|---|---:|---:|
| paths and filenames | attribute storage | exact | pseudonymized |
| allocated/logical bytes | quantify usage | retained | retained |
| CPU, memory pressure, Swap | diagnose slowdown | retained | retained |
| process arguments | optional deep inspection | local only | excluded |
| Guidance notes | explain evidence | opt-in | evidence-linked only |

Reports are user-owned files and remain until the user removes them. Partial results explicitly record scope and quality. Full Disk Access is optional; without it, inaccessible scopes are reported as partial.

Never attach a local-full report to a public issue. Use `--share-redacted` and inspect the result before sharing.
