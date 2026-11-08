# Claude automation

Workflows added by the Claude Code Action pilot. All Claude jobs are pinned, run with `--permission-mode auto`, and stay inactive until the steps below are done.

## Turn it on
1. Add the repository secret `CLAUDE_CODE_OAUTH_TOKEN`.
2. Install the Claude GitHub App (https://github.com/apps/claude) on this repo. `claude.yml` and `claude-review.yml` use it (`id-token: write`), so comments come from claude[bot] and its pushes trigger CI.
3. Optional repository variables:
   - `GODOT_SHA512`: SHA-512 of `Godot_v4.2.2-stable_linux.x86_64.zip` from Godot's official `SHA512-SUMS.txt`. When set, `claude.yml` and `claude-review.yml` install Godot with a checksum check so Claude can run the headless import and simulation tests. Without it Claude runs only the Python validators and says so.
   - `CLAUDE_MODEL`: overrides the model for every Claude job (defaults: claude-opus-5-5 for `@claude`, claude-sonnet-5-5 elsewhere).
   - `CLAUDE_RUNNER=ubuntu-24.04-firewall`: use the egress-firewall runner (technical preview) with `.github/egress-firewall.yaml`.
   - `CLAUDE_PAUSE=true`: pauses every Claude job.
4. Keep `asshat1981ar/project-chimera` public for the weekly parity job.
5. After one green run, optionally mark `agent-approval-check` as a required status check on `main`. Do not make any Claude job a required check.

## Workflows
| File | Trigger | Does |
|---|---|---|
| `claude.yml` | `@claude` in issues, PR comments, reviews (owner only) | implements on `claude/` branches |
| `claude-review.yml` | non-draft same-repo PRs touching code, scenes, data | read-only review, sticky comment |
| `claude-content-gate.yml` | PRs touching `data/**` | typed check of ids, links, choiceType; summary in the run, informational |
| `claude-port-parity.yml` | weekly (Thursday) and manual | compares rules with project-chimera, maintains one `Port parity report` issue |
| `agent-approval-check.yml` | PRs and comments | requires `/approve <head-sha>` from a human on PRs with claude[bot] commits |

Commands: `@claude <task>`, `/approve <head-sha>`.

An empty content-gate or parity result (for example when the subscription limit is hit) is reported as a warning, never as a pass.

`godot.yml` is unchanged. It still downloads Godot without a checksum and exposes keystore secrets to `pull_request` jobs on same-repo branches.
