# dsh-trust-suite — the deterministic trust chain for DeepSeek Harness

One thesis, three plugins, zero LLM calls in the trust path:

> The dsh plugin ecosystem reviews agents with LLMs — answer reviewers,
> advisor loops, goal verifiers. Everything that *must not be an LLM* —
> the parts a probabilistic reviewer can be injected past — is what this
> family owns.

| Plugin | Guards | What it does |
|---|---|---|
| [dsh-read-guard](https://github.com/zhengqiuyang/dsh-read-guard) | what the agent **reads** | Prompt-injection interception in the `tools/post-execute` waterfall: file reads, repo searches, and web fetches are scanned before they enter model context — quarantined, blocked, or passed. Engine: [repo-inject-guard](https://github.com/zhengqiuyang/repo-inject-guard) |
| [dsh-pr-gate](https://github.com/zhengqiuyang/dsh-pr-gate) | what the agent **writes** | Deterministic write gate: scope policy denies out-of-scope writes before they touch the disk, residue rules scan the written text, a content-hashed JSONL ledger records every decision. The CI gate moved to the moment of the write. Engine: [agent-pr-gate](https://github.com/zhengqiuyang/agent-pr-gate) |
| [dsh-attest](https://github.com/zhengqiuyang/dsh-attest) | what the agent **did** | Signed chain-of-custody: every watched tool result appends a hash-chained, ed25519-signed record. Tamper with a line, break the chain; delete the tail, break the published head. Engine: [agent-attest](https://github.com/zhengqiuyang/agent-attest) |
| [dsh-mcp-test](https://github.com/zhengqiuyang/dsh-mcp-test) | what the agent **can call** | Tool-surface snapshot and drift gate: the full visible registry (first-party, plugin, MCP tools) is baselined and diffed — upgrades that silently change the model-visible surface fail loud. Methodology: [mcp-test](https://github.com/zhengqiuyang/mcp-test) |
| [dsh-janitor](https://github.com/zhengqiuyang/dsh-janitor) | what the agent **leaves behind** | Deterministic cleanup plans for session debris (plan docs, scratch scripts): scan → verdicts with evidence → review. The janitor is never an agent; v0.1 never deletes. Engine: [agent-janitor](https://github.com/zhengqiuyang/agent-janitor) |

Read + write + do + call + leave-behind: the five channels through which an
agent session can go wrong, each gated by a deterministic rule engine with
its own upstream test suite, Windows+Linux CI, and an honest kill-criteria
section.

## Install the family

```sh
dsh plugin --profile default add github:zhengqiuyang/dsh-read-guard
dsh plugin --profile default add github:zhengqiuyang/dsh-pr-gate
dsh plugin --profile default add github:zhengqiuyang/dsh-attest
dsh plugin --profile default add github:zhengqiuyang/dsh-mcp-test
dsh plugin --profile default add github:zhengqiuyang/dsh-janitor
```

Each also installs standalone as an npm tarball; each ships its own config in
`cordis.patch.yml`. They compose without interference (different pipeline
stages: read-guard observes results, pr-gate gates writes, attest records
everything, mcp-test watches the registry, janitor scans on demand).

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

- **dsh-bench** — port of [agentbench-local](https://github.com/zhengqiuyang/agentbench-local):
  SWE-bench for YOUR repo, on YOUR machine; mines tasks from git history,
  grades with your own tests, drives agents via `dsh headless`. Answers
  "which model/plugin config for this repo".
- **skills lockfile** — hermetic pinning (`--frozen`) for skills/plugins à la
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
