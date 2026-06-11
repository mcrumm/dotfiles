# Claude Code dotfiles

Personal Claude Code configuration. `install.sh` symlinks
`settings.json` into `~/.claude/settings.json`. Hook scripts in
`hooks/` are referenced by absolute path from `settings.json`, so
they run straight from this directory — no symlink needed.

## Files

- `settings.json` — symlinked into `~/.claude/`. Hooks, plugins,
  effort level, attribution, etc.
- `env.zsh` — sourced by zsh. Currently just a placeholder for
  `CLAUDE_CODE_EFFORT_LEVEL`.
- `install.sh` — run once per new machine.
- `hooks/` — shell hooks invoked by Claude Code lifecycle events.

## ntfy long-turn notification

When a Claude turn takes ≥ 5 minutes, a notification is POSTed to
the homelab ntfy at `http://ntfy.lan/claude-code`. Subscribe to
that topic in the ntfy mobile app to get pinged when you can walk
away from the keyboard.

**How it works**

- `hooks/claude-turn-start.sh` runs on `UserPromptSubmit`. Writes
  start epoch, prompt's first line, and cwd to
  `$TMPDIR/claude-turn/<session_id>.json`.
- `hooks/claude-turn-stop.sh` runs on `Stop`. Reads that state,
  computes elapsed, and if ≥ threshold curls a notification to
  ntfy. State file is deleted either way. Files older than 24h
  are GC'd opportunistically.

Both hooks run with `async: true` so they never block the UI.

**Env vars** (read at hook execution time; export from your shell
or set inline before launching `claude`)

| Var                          | Default                       | Effect                              |
| ---------------------------- | ----------------------------- | ----------------------------------- |
| `CLAUDE_NTFY_THRESHOLD_SECS` | `300`                         | Skip POST if turn was shorter.      |
| `CLAUDE_NTFY_URL`            | `http://ntfy.lan/claude-code` | Full ntfy publish URL (host+topic). |

**Activating changes**

`settings.json` reloads on session start or after opening `/hooks`
once. Restart `claude` or open `/hooks` for edits to take effect
in the current session; new sessions pick them up automatically.

**Disabling temporarily**

Set the threshold absurdly high for a session:

```sh
CLAUDE_NTFY_THRESHOLD_SECS=999999 claude
```

Or comment out the `hooks` block in `settings.json` and restart.

**Debugging**

Hooks fail silently by design (curl is `|| true`). To see what
fired, prefix the command in `settings.json` with a sentinel and
tail the file:

```sh
echo "$(date) hook fired" >> /tmp/claude-hook-check.txt;
```

## ntfy unanswered-question notification

When Claude shows an `AskUserQuestion` prompt and you don't answer
within 2 minutes, a notification is POSTed to the same ntfy topic
(`http://ntfy.lan/claude-code`). Useful for catching a session
that has quietly stalled waiting on your input while you're away.

**How it works**

The obvious approach — a `PreToolUse` hook on `AskUserQuestion` to
start a timer — is unusable: a `PreToolUse` hook on that tool
strips the answers you select from the tool's response
([anthropics/claude-code#12031]). And the `Notification` event
isn't documented to fire for `AskUserQuestion`. So instead we
watch the session transcript, which records the question at
ask-time and your answer at answer-time:

- `hooks/claude-ask-start.sh` runs on `UserPromptSubmit`
  (synchronously, but it just spawns and exits). It launches a
  detached background poller for the turn and records its PID in
  `$TMPDIR/claude-ask/<session_id>.pid`.
- `hooks/claude-ask-poll.sh` is that poller. Every
  `CLAUDE_NTFY_ASK_POLL_SECS` it reads the transcript JSONL: if the
  most recent `AskUserQuestion` `tool_use` has no matching
  `tool_result`, the question is still pending. Once it has been
  pending ≥ threshold it curls one notification to ntfy — at most
  once per question. It only re-parses when the transcript's mtime
  changes (a pending question is a quiet file), so the waiting case
  is a cheap `stat` + arithmetic.
- `hooks/claude-ask-stop.sh` runs on `Stop`. The turn is over, so
  it kills the poller and removes the PID file. The poller sleeps
  via `sleep & wait` so this kill takes effect immediately rather
  than after the poll interval.

A turn (`UserPromptSubmit` → `Stop`) spans the whole question wait —
`Stop` does not fire when Claude pauses to ask — so the poller is
alive exactly when it needs to be. Stale PID files are GC'd after
24h.

[anthropics/claude-code#12031]: https://github.com/anthropics/claude-code/issues/12031

**Env vars** (read at hook execution time; export from your shell
or set inline before launching `claude`)

| Var                              | Default                       | Effect                                              |
| -------------------------------- | ----------------------------- | --------------------------------------------------- |
| `CLAUDE_NTFY_ASK_THRESHOLD_SECS` | `120`                         | Ping after a question is unanswered this long. `0` disables. |
| `CLAUDE_NTFY_ASK_POLL_SECS`      | `15`                          | How often the poller checks the transcript.         |
| `CLAUDE_NTFY_ASK_MAX_SECS`       | `14400`                       | Safety cap on poller lifetime (zombie backstop).    |
| `CLAUDE_NTFY_URL`                | `http://ntfy.lan/claude-code` | Shared with the long-turn notification.             |

**Activating / disabling**

Same as the long-turn hooks — restart `claude` or open `/hooks` to
pick up edits. Disable for a session with:

```sh
CLAUDE_NTFY_ASK_THRESHOLD_SECS=0 claude
```

(`0` skips spawning the poller entirely — no lingering process,
unlike the long-turn "set it absurdly high" trick.)

**Debugging**

Tail the running poller's effect by watching the state dir while a
question is open:

```sh
ls -l "${TMPDIR:-/tmp}/claude-ask/"   # one <session>.pid per active turn
```

To see exactly what a poller would send without touching real
ntfy, run it by hand against a transcript that ends on an
unanswered question (drop the lines after the last
`AskUserQuestion`) with a fake `curl` first on `PATH`.
