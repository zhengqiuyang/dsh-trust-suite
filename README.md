# dsh-trust-suite — the deterministic trust chain for DeepSeek Harness

> **If this helps you, please give it a star** — it helps others find it. Thanks!

One thesis, three plugins, zero LLM calls in the trust path:

> The dsh plugin ecosystem reviews agents with LLMs — answer reviewers,
> advisor loops, goal verifiers. Everything that *must not be an LLM* —
> the parts a probabilistic reviewer can be injected past — is what this
> family owns.

| Plugin | Guards | What it does |
|---|---|---|
| [dsh-read-guard](https://github.com/zhengqiuyang/dsh-read-guard) | what the agent **reads** | Prompt-injection interception in the `tools/post-execute` waterfall: file reads, repo searches, and web fetches are scanned before they enter model context — quarantined, blocked, or passed. Engine: [repo-inject-guard](https://github.com/zhengqiuyang/repo-inject-guard) |
| [dsh-pr-gate](https://github.com/zhengqiuyang/dsh-pr-gate) | what the agent **writes** | Deterministic write gate: scope policy denies out-of-scope writes before they touch the disk, residue rules scan the written text, a content-hashed JSONL ledger records every decision. The CI gate moved to the moment of the write. Engine: [agent-pr-gate](https://github.com/zhengqiuyang/agent-pr-gate) |
| [dsh-attest-chain](https://github.com/zhengqiuyang/dsh-attest-chain) | what the agent **did** | Signed chain-of-custody: every watched tool result appends a hash-chained, ed25519-signed record. Tamper with a line, break the chain; delete the tail, break the published head. Engine: [agent-attest](https://github.com/zhengqiuyang/agent-attest) |
| [dsh-mcp-test](https://github.com/zhengqiuyang/dsh-mcp-test) | what the agent **can call** | Tool-surface snapshot and drift gate: the full visible registry (first-party, plugin, MCP tools) is baselined and diffed — upgrades that silently change the model-visible surface fail loud. Methodology: [mcp-test](https://github.com/zhengqiuyang/mcp-test) |
| [dsh-janitor](https://github.com/zhengqiuyang/dsh-janitor) | what the agent **leaves behind** | Deterministic cleanup plans for session debris (plan docs, scratch scripts): scan → verdicts with evidence → review. The janitor is never an agent; v0.1 never deletes. Engine: [agent-janitor](https://github.com/zhengqiuyang/agent-janitor) |
| [dsh-egress-gate](https://github.com/zhengqiuyang/dsh-egress-gate) | **where data may flow** | Destination allowlist for web fetches/searches, denied in `tools/pre-execute` before they run; shell fetch-verbs observed (enforcement opt-in). The other half of exfil defense: content scanning guards what enters, this guards where it leaves. |
| [dsh-prompt-drift](https://github.com/zhengqiuyang/dsh-prompt-drift) | what the model is **told** | System-prompt surface drift gate: every section contributed by any plugin/preset is hashed and baselined; a silent rewrite of the prompt fails loud. |
| [dsh-freeze](https://github.com/zhengqiuyang/dsh-freeze) | what exactly is **running** | Hermetic composition lock: the profile's dependencies, bundle order, lockfile hash, and patch layer are fingerprinted; booting a drifted composition warns — or fails under `strict` (the `--frozen` posture for CI). |

| [dsh-compaction-guard](https://github.com/zhengqiuyang/dsh-compaction-guard) | what the agent **forgets** | Compaction integrity: directive lines from the compacted range are extracted and verified against the summary — verbatim or in substance; every constraint the agent silently forgot is reported and ledgered. |

Read + write + do + call + leave-behind + egress + told + running / remembered: the eight
channels through which an agent session can go wrong, each gated by a
deterministic rule engine with its own upstream test suite, Windows+Linux
CI, and an honest kill-criteria section.

| [dsh-trust-panel](https://github.com/zhengqiuyang/dsh-trust-panel) | what the user **sees** | The plain-language dashboard for all nine channels: one status light, event cards a non-security user can act on, bilingual (zh/en). |

## Install the family

One command, from npm (v0.3.0+, the whole family in a single meta-bundle):

```sh
dsh plugin --profile web add dsh-trust-suite   # 9 guards + the trust-panel dashboard
```

Prefer git checkouts? One command per plugin, all prebuilt (no `allowBuilds`
step):

```sh
curl -fsSL https://raw.githubusercontent.com/zhengqiuyang/dsh-trust-suite/main/install.sh | bash -s -- web
# or explicitly:
dsh plugin --profile web add github:zhengqiuyang/dsh-read-guard   # + pr-gate, attest-chain, mcp-test, janitor, egress-gate, prompt-drift, freeze
```

Each ships its own config in `cordis.patch.yml` and composes without
interference (different pipeline stages: read-guard observes results,
pr-gate gates writes, attest records everything, mcp-test watches the
registry, egress-gate checks destinations, prompt-drift watches the
assembled prompt, freeze pins the composition, janitor scans on demand).

## Why a family, and against whom

The dsh security lane (checked 2026-10-12) is a long tail without a winner:
~15 injection-defense plugins, none above 85★, the strongest being a
model-callable scanner (the model can decline to call it) and one
three-point interceptor with literal pattern lists. Nothing on the write
side, nothing on custody. The family's edge is not being first — it is that
every rule engine here is vendored from a battle-tested upstream repository
with its own CI, competitive analysis, and kill criteria, instead of being a
weekend pattern list. Few plugins, deep engines, upstream ownership — the
deliberate opposite of the 90-plugin land-grab strategy visible in the
ecosystem today.

## Roadmap (next in the family)

- **dsh-bench** has shipped as its own repo —
  [zhengqiuyang/dsh-bench](https://github.com/zhengqiuyang/dsh-bench-local): bench
  your dsh configuration against your own tasks via `dsh headless`
  (live-verified). Its mining pillar (tasks from git history, graded by your
  own tests) ports agentbench-local next.
- **skills lockfile** — hermetic pinning for skills/plugins à la
  [vendor-skills](https://github.com/zhengqiuyang/vendor-skills); today's
  supply-chain plugins all static-scan, none reproducibly pin.
- **mcp-test probe pillar** — behavioral + injection probes against running
  MCP servers (the headline feature of upstream mcp-test) on top of
  dsh-mcp-test's drift gate.

## Kill criteria

Per-plugin kill criteria live in each README. Family-level: if dsh ships a
first-party deterministic trust layer covering read/write/custody, the family
freezes and this README records the postmortem. The engines live on in their
upstream repositories regardless.
