# Implementation Status — Minimal Interactions API Web Demo

## Goal / success criteria

Build a minimal **text-only** local web GUI that gives a “feel” for Gemini **Interactions API** interactivity:

- Browser UI can send a text message at any time
- Server sends that text to Interactions API using `model="gemini-2.5-flash"` and `stream=true`
- Every event received from Interactions API is forwarded to the browser and displayed
- Conversation stays stateful per browser session (tracks `previous_interaction_id`)

## Constraints / safety notes

- `GEMINI_API_KEY` is already available in your environment; the demo will read it from env.
- Do not edit `.env` files (per repo rules).

## Plan

1. Create a small Python server with:
   - `GET /` serves a single static HTML page
   - `WS /ws` accepts user messages and streams Interactions API SSE events back to the browser
2. Add a minimal `index.html` UI (single page) that prints events as they arrive.
3. Add `README`-style run instructions.
4. Run quick local sanity checks (import + basic start-up).

## Status

- Current: in progress
- Default model: `gemini-2.5-flash`
  - Per-session state: `previous_interaction_id` tracked per WebSocket connection

## Findings / learnings (so far)

- The Interactions API streams results via Server-Sent Events (SSE); event types observed in existing samples include `interaction.status_update`, `content.start`, `content.delta`, `content.stop`, `error`.
- The A2A sample transport (branch `origin/interactions-api` in `/Users/cgint/dev-external/a2a-samples`) shows how to:
  - call `POST /v1beta/interactions` with `stream=true`
  - resume with `last_event_id` on `GET /v1beta/interactions/{id}?stream=true`
  - continue a conversation via `previous_interaction_id`
- `uv` will not install `project.scripts` entry points unless the project is packaged; using `uv run python -m web_demo ...` keeps the demo runnable without packaging boilerplate.

## Implementation log

- 2026-01-15: Initialized status file and started implementing the web demo.
- 2026-01-15: Added minimal Starlette server (`web_demo/app.py`) + single-page UI (`web_demo/static/index.html`) + deps (`requirements.txt`) + run docs (`README.md`).
- 2026-01-15: Sanity checks: `web_demo/app.py` compiles and imports.
- 2026-01-15: Converted to `uv` + `pyproject.toml`; added `interactions-web` entrypoint; removed `requirements.txt`.
- 2026-01-15: Adjusted `uv` workflow to use `uv run python -m web_demo` (no packaged entry points).
- 2026-01-15: Rewrote `README.md` to explain the repo from a user perspective (what you’ll experience and how to try it).
