# Claude automation

Workflows added by the Claude Code Action pilot. All Claude jobs are pinned, run with `--permission-mode auto`, scrub secrets from subprocess env (`CLAUDE_CODE_SUBPROCESS_ENV_SCRUB`), and stay inactive until the steps below are done.

## Turn it on
1. Add the repository secret `CLAUDE_CODE_OAUTH_TOKEN`.
2. Install the Claude GitHub App (https://github.com/apps/claude) on this repo. `claude.yml` and `claude-review.yml` use it (`id-token: write`), so comments come from claude[bot] and its pushes trigger CI.
3. Optional repository variables:
   - `CLAUDE_MODEL`: overrides the model for every Claude job (defaults: claude-opus-5-5 for `@claude`, claude-sonnet-5-5 elsewhere).
   - `CLAUDE_RUNNER=ubuntu-24.04-firewall`: use the egress-firewall runner (technical preview) with `.github/egress-firewall.yaml`.
   - `CLAUDE_PAUSE=true`: pauses every Claude job (the deterministic content-graph job keeps running).
4. Keep `asshat1981ar/project-chimera` public for the weekly parity job.
5. After one green run, optionally mark `agent-approval-check` and the `graph` job of `claude-content-gate` as required status checks on `main`. Do not make any other Claude job a required check: `explain`, `claude`, `review` and `parity` fail whenever the subscription limit is hit.

## Workflows
| File | Trigger | Does |
|---|---|---|
| `claude.yml` | `@claude` in issues, PR comments, reviews (owner only) | edits and commits on `claude/` branches; refuses cross-repo PRs |
| `claude-review.yml` | non-draft same-repo PRs touching code, scenes, data | read-only review, sticky comment |
| `claude-content-gate.yml` | every PR | `graph`: deterministic check of ids, links and choiceType (the verdict); `explain`: advisory Claude commentary |
| `claude-port-parity.yml` | weekly (Thursday) and manual | compares rules with project-chimera, maintains one `Port parity report` issue |
| `agent-approval-check.yml` | PRs and comments | requires `/approve <head-sha>` from a human on PRs with claude[bot] commits |

Commands: `@claude <task>`, `/approve <head-sha>`.

## What Claude can and cannot run
- No Claude job has build, test, package-manager or repo-script tools. `claude.yml` allows read-only `git` and `gh pr/issue view|diff` plus the action's own file edit and commit tools; the review job allows `gh pr diff` and comment posting only. Claude therefore cannot run Godot or `validate_gdscript.py`; it relies on CI (`godot.yml`, the content graph) running on its pushed branch, which has no Claude secrets.
- `claude.yml` first runs a fork guard (`gh pr view --json isCrossRepository`); on a cross-repo PR, or if that lookup fails, the Claude step is skipped.
- Comment-author filters (`include_comments_by_actor`) only apply in tag mode (`claude.yml`). Agent-mode jobs are told not to read PR comments and have no `gh pr view`.

## Content graph
`scripts/check_content_graph.py` (stdlib only) checks unique ids, that referenced npc, node, scene, quest, tree, item, recipe and reveal ids resolve, that `choiceType` is in the CLAUDE.md set, and map reachability. Run it locally with `python3 -I scripts/check_content_graph.py data`; its tests are `python3 -I -m unittest discover -s tests`. In CI the `graph` job runs the copy from the base commit against the PR's `data/` (under `pr-head/`), so a PR cannot change the checker that judges it. Consequence: the very PR that introduces the script passes with "checker not on base yet". The `explain` job's Claude output is advisory; empty output is a WARN, never a pass, and the script result is always the verdict.

## Residual risks
- Claude reads PR diffs and file contents, which can carry prompt injection. Bounded by the small tool sets and the owner-only trigger on `claude.yml`.
- `CLAUDE.md` and `.claude/` are restored from the base branch on PR runs; other repo files on a same-repo branch are not.
- The `explain` job checks out PR data for Claude to read (no Bash), with only `GITHUB_TOKEN` read access.
- `godot.yml` is unchanged. It still downloads Godot without a checksum and exposes keystore secrets to `pull_request` jobs on same-repo branches.
