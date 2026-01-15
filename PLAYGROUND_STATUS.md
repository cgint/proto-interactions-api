# Status — Single-file Phoenix LiveView Playground (Interactions demo)

## Goal / success criteria

Create a **shareable single-file** Phoenix LiveView Playground script that mimics the current demo:

- `GET /` shows a minimal “Interactions API streaming demo” UI with:
  - left pane: raw event log
  - right pane: human-friendly summary (per turn: status/id + assistant text)
- User can type a message and see Interactions API SSE events arrive incrementally.
- Per tab session tracks `previous_interaction_id` (cleared by `/new` or `/reset`).
- Uses `model="gemini-2.5-flash"`, `stream=true`, `store=true`.
- Requires `GEMINI_API_KEY` (or `GOOGLE_API_KEY`) from environment.

## Plan / steps (tracked)

1. Bootstrap a minimal Phoenix Playground endpoint + LiveView route in one `.exs` file.
2. Implement an Interactions API SSE streaming client in Elixir (parse SSE, JSON decode).
3. Implement LiveView UI/state updates to match the existing Python+JS behavior.
4. Add a small `/health` JSON endpoint.
5. Document how to run and known caveats.

## Current status

- Done:
  - `interactions_playground.exs` contains endpoint/router/liveview + SSE client + `/health`.
  - Syntax sanity check: `elixir -e 'Code.string_to_quoted!(File.read!(\"interactions_playground.exs\"))'` passes.
  - Fixed LiveView reconnect loop caused by missing CSRF params + duplicate LiveSocket init:
    - Added `InteractionsPlayground.Layout` with `<meta name="csrf-token" ...>` and a single LiveSocket init passing `_csrf_token`.
    - Removed the extra LiveSocket init script from the LiveView template.
  - Fixed noisy/crashing 404s:
    - Added `GET /sw.js` (no-op) to satisfy browsers trying to load a service worker.
    - Added `InteractionsPlayground.ErrorView` so `NoRouteError` can render a 404 instead of crashing.
  - Fixed runtime 500 on `/` by setting `secret_key_base` (cookie session requires ≥64 bytes).
- Not verified (runtime):
  - Running `Mix.install/1` may need network access to fetch deps the first time.
  - Interactions API SSE field shapes should be validated against real traffic.
  - LiveView should no longer spam “session misconfigured/outdated” or “Cannot bind multiple views…”, but needs confirmation in a normal terminal/browser session.

## What worked / didn’t (evidence)

- Evidence from repo: there is no Alpine; existing implementation is Starlette + vanilla JS (`web_demo/app.py`, `web_demo/static/index.html`).
- Regression fixed: an accidental removal/revert introduced mid-line breaks and partial deletions (router/endpoint + long lines), causing syntax errors; `interactions_playground.exs` is now repaired and parses cleanly.
- Note (tooling): in restricted sandboxes, `Mix.install/1` can fail with `failed to start Mix.PubSub ... reason: :eperm` (TCP socket permission). Running from a normal terminal session should avoid this.
- Bug observed (your local run): repeating “LiveView session was misconfigured…” and browser console “Cannot bind multiple views…”.
  - Root cause: the page was initializing a LiveSocket without CSRF params and (depending on layout behavior) initializing multiple LiveSockets.
  - Fix: centralized LiveSocket init in `InteractionsPlayground.Layout` and pass `_csrf_token`. Also fixed a subtle ordering bug: `defer` on inline scripts is ignored by browsers, so initialization must run on `DOMContentLoaded` to ensure the external `phoenix.js` + `phoenix_live_view.js` are loaded first.

## Important findings (future-relevant)

- LiveView removes the need for a custom browser↔server WebSocket message protocol; “raw event log” can be rendered directly from server assigns.
- Streaming pattern: `handle_event/3` starts a `Task` to consume SSE; the task `send/2`s parsed events to the LiveView process; `handle_info/2` updates assigns incrementally.
- Product decision to revisit: whether `previous_interaction_id` should survive refresh/reconnect (session/db) vs being ephemeral per connected LiveView process (current Python demo is ephemeral per WebSocket).
- Bug fixed: the streaming `Task` originally called `InteractionsClient.stream_interaction(self(), ...)` from inside the task, which sends SSE updates to the task itself (not the LiveView), leaving the UI stuck on “Streaming…”. Fix: capture `lv_pid = self()` before `Task.start/1` and pass `lv_pid` to the client.

## How to run

Prereqs:

- Elixir installed
- `GEMINI_API_KEY` (or `GOOGLE_API_KEY`) set in your environment

Run:

```bash
elixir playground/run.exs
```

Compatibility shim (old command still works):

```bash
elixir interactions_playground.exs
```

Then open:

- `http://localhost:4000/`
- `http://localhost:4000/health`
