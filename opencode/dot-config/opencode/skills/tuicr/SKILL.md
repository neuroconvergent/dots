---
name: tuicr
description: Use tuicr's review CLI to read and add comments in active TUI review sessions, and launch tuicr in kitty or wezterm (WSL) when a user needs an interactive review pane. This user does not use tmux or zellij.
---

# tuicr Review Workflow

Use `tuicr review` as the default agent interface. The TUI is where the human
reviews code; the CLI is how the agent discovers active sessions, reads user
comments, and, only when appropriate, adds agent-authored comments.

## Core Rule

First decide which workflow the user is asking for:

1. **User-led review of agent-generated changes**
   - The user wants to inspect the patch and write comments in tuicr.
   - Your job is to open or find the session, then retrieve the user's comments
     with `tuicr review comments` when they say comments are ready. If you are
     explicitly waiting while the user reviews, poll the same command
     periodically and look for new comment IDs.
   - Do not add your own review comments, do not preemptively review your own
     patch, and do not impersonate the user's comments.

2. **Agent review of an AI-generated patch**
   - The user wants you to understand, critique, or summarize a patch.
   - You may inspect the patch and propose findings.
   - If you can confidently identify this workflow and the target session, add
     findings directly with `tuicr review add` and an explicit `--username`
     identifying the agent. Ask first when the workflow or session is ambiguous.

If the user's intent is ambiguous, ask which workflow they want.

## Attach To A Session

1. Determine the repository directory from the user's request, current working
   directory, or recent file operations. Ask if it is ambiguous.

2. List persisted sessions:

   ```bash
   tuicr review list --repo /path/to/repo   # checkout + its repo's PR sessions
   tuicr review list --repo owner/repo      # all sessions for a forge repo
   tuicr review list --all                  # every session across all repos
   ```

   `--repo` is a selector: a checkout path also surfaces PR sessions for that
   checkout's `origin` repo, and a forge coordinate like `owner/repo` matches
   local and PR sessions by owner/repo. Each row carries a `kind` (`local` or
   `pr`) and a usable `slug`. Use `--all` when you don't know the repo.

3. Choose the session:
   - If the CLI clearly reports exactly one relevant active session with
     `"active": true`, attach to it.
   - If multiple sessions are active, or the correct session is not clear, ask
     the user which slug to use.
   - If the user provided a slug or session JSON path, use it directly.
   - For a PR review, pass the PR slug from the listing (e.g.
     `gh:owner/repo/pr/N`) to `--session`; it is self-contained and needs no
     `--repo`.
   - If there is no active session, start or wait for one as described below.
   - Until active-session discovery is formalized as a stable protocol, treat
     `"active": true` as a convenience signal. If slug resolution fails, ask the
     user for the slug or repo path used by the session.

The CLI works even if the agent is not running inside a multiplexer, so do not
require a multiplexer just to connect to an existing active session.

## Start A Session

When the user needs an interactive tuicr pane and no active session exists,
this user uses **kitty** (native Linux) or **wezterm** (under WSL). They do NOT
use tmux or zellij.

Detect the environment and dispatch to the matching wrapper. Wrapper paths are
relative to this skill directory:

| Environment | Detection | Action |
|-------------|-----------|--------|
| native Linux, kitty | `$KITTY_WINDOW_ID` set, or `TERM == xterm-kitty`, and NOT inside WSL | `<skill-directory>/tuicr-wrapper-kitty.sh /path/to/repo` |
| WSL, wezterm | WSL detected (`grep -qi microsoft /proc/version`) and wezterm-hosted | `<skill-directory>/tuicr-wrapper-wezterm.sh /path/to/repo` |
| Neither, or unclear | — | Tell the user you are waiting for them to start `tuicr` in the repo, then attach with `tuicr review list` after they say it is ready |

WSL detection: `grep -qi microsoft /proc/version`. When inside WSL, the
terminal GUI is a Windows process, so the wrapper must call the Windows
`wezterm.exe` (via WSL interop) rather than the Linux `wezterm` build — the
Linux build cannot control the Windows mux. `wezterm.exe` is invoked directly
from bash; no `cmd.exe` wrapper is required as long as it is on the Windows
PATH.

If your tool supports command timeouts, use a long timeout, such as 10 minutes,
because the wrappers wait for the TUI to exit. Once the TUI creates its active
session, use `tuicr review list --repo /path/to/repo` to capture the slug. If
your environment cannot run another command while the wrapper is waiting, read
the comments after the user exits tuicr.

## Read User Comments

This is the main review loop for user-led review.

There is no push stream from tuicr to the agent. Read comments by running the
CLI on demand. After the user says comments are ready, or after the TUI exits,
run:

```bash
tuicr review comments --repo /path/to/repo --session <slug>
```

The command emits JSON. Each comment includes fields like:

- `id`
- `location`
- `path`
- `start_line`
- `end_line`
- `side`
- `comment_type`
- `lifecycle_state`
- `content`

Treat these comments as the user's review feedback:

- `issue`: blocking problem to fix first
- `suggestion`: consider implementing or explain why not
- `note`: answer or acknowledge
- `praise`: no action required

If you are waiting during an active review, poll this command about every 30
seconds and compare comment IDs with the previous result. Read immediately when
the user says comments are ready. Stop polling once the user says the review is
done or your tooling would block other work.

If the result is empty, ask whether the user saved comments in the intended
session or whether another active session should be selected. If the review may
have continued while you were working, rerun `tuicr review comments` before
claiming completion.

## Add Agent Comments

Only add comments when the workflow allows it and, for agent-authored review,
after the user approves writing them into tuicr.

Defaults:

- Prefer line comments when a specific file and line are known.
- Use file comments for file-scoped feedback.
- Use review-level comments only for whole-review summaries.
- Use `--type issue` for problems by default.
- Use `suggestion`, `note`, or `praise` when that better matches the intent.
- Pass `--username` so agent comments are visually distinguishable.

Examples:

```bash
tuicr review add --repo /path/to/repo --session <slug> \
  --target-file src/main.rs \
  --line 42 \
  --side new \
  --type issue \
  --username "Codex" \
  "Handle the empty case here."
```

```bash
tuicr review add --repo /path/to/repo --session <slug> \
  --target-file src/main.rs \
  --type suggestion \
  --username "Codex" \
  "Consider splitting this file-level concern into a helper."
```

Omit `--target-file` for a review-level comment. Add `--end-line` for a range
comment. Use `--side old` for removed lines and `--side new` for added or
unchanged lines in the new file.

For structured input, use `--input` with literal JSON, `@path/to/file.json`, or
`-` for stdin. Supported target types are `review`, `file`, `line`, and
`line_range`.

## Legacy Export Output

Older wrapper-driven flows may emit:

```text
=== TUICR INSTRUCTIONS ===
...
=== END TUICR INSTRUCTIONS ===
```

If present, process those instructions. Otherwise prefer
`tuicr review comments`; it is the primary source of review feedback. If the
wrapper mentions clipboard export, ask the user to paste it only when the CLI
comments are unavailable.

## Terminal Tips

This user does not use tmux or zellij. Multiplexer-style pane keybindings do
not apply.

kitty (native Linux, the user launches projects with
`@dots/path/PATH/autokitten.sh` which opens kitty tabs via `kitten @`):

- The user runs tuicr in its own kitty **tab** (see `autokitten.sh`), not a
  split pane. Prefer launching tuicr as a new kitty tab via
  `kitten @ launch --type tab` to match their workflow.
- Switch tabs: `Ctrl+Shift+Right` / `Ctrl+Shift+Left`, or `kitten @ focus-tab`.
- Close a tab: `Ctrl+Shift+Q` (close window), or the tab's close button.
- New tab: `Ctrl+Shift+T`.
- Remote control (`kitten @`) requires `allow_remote_control yes` or running
  with `--single-instance --listen-on=unix:/tmp/kitty`. The user's environment
  already has `KITTY_LISTEN_ON` set.

wezterm (WSL):

- Switch tabs: `Ctrl+Shift+Tab` / `Ctrl+Tab`, or `wezterm.exe cli` commands.
- Close tab/window via wezterm keybinding (default `Ctrl+Shift+W` closes window).
- New tab: `Ctrl+Shift+T`, or `wezterm.exe cli spawn --domain`.
- Pane/window control from CLI uses `wezterm.exe cli ...`.

## Error Handling

| Situation | Action |
|-----------|--------|
| Multiple plausible active sessions | Ask which session slug to use |
| No active session, kitty available (native Linux) | Start a new tuicr tab with `tuicr-wrapper-kitty.sh` |
| No active session, wezterm available (WSL) | Start a new tuicr tab with `tuicr-wrapper-wezterm.sh` |
| No active session, no supporting terminal | Tell the user you are waiting for them to start `tuicr` |
| `tuicr` not installed | Tell the user to install tuicr |
| Not a repository | Ask for the correct repo directory |
| Comments are empty | Confirm the selected session or ask the user to save/add comments |
| WSL but `wezterm.exe` not on PATH | Tell the user to ensure the Windows wezterm install is on their Windows PATH so WSL interop can find `wezterm.exe` |

## When Not To Use

- The user only wants raw `git diff` output.
- The user explicitly asks for a non-tuicr review workflow.
- The task is remote PR review and no tuicr PR session is involved.