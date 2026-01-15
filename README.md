# proto-interactions-api

This repo is a tiny “first feel” demo for Google’s Gemini **Interactions API**.

You open a local web page, type a message, and immediately see the **live stream of events** coming back (status updates, incremental output chunks, etc.). It’s intentionally text-only and minimal—meant for learning what “interactive” feels like, not for building a full chat product.

## What you can do here

- Ask a question in the browser and watch the response arrive as a stream of events.
- Send another message and keep the same conversation going (the demo keeps context for your current browser session).
- Type `/new` to start a fresh conversation.

## Quick start

Prereq: `GEMINI_API_KEY` must be set in your environment.

```bash
uv sync
uv run python -m web_demo --reload --port 8000
```

Open `http://localhost:8000/`.

## Defaults (so you know what you’re testing)

- Model: `gemini-2.5-flash`
- Streaming: on (events are forwarded to the browser as they arrive)
- Session behavior: conversation state is kept per browser session while the WebSocket is open

## Elixir / Phoenix LiveView Playgrounds

We also provide two Elixir-based implementations for those who prefer Phoenix LiveView.

### 1. Scripted Variant (`playground/`)
A lightweight, script-based approach using `Mix.install`. Great for quick experiments without a full project structure.

**Run it:**
```bash
elixir playground/run.exs
```
It will find an available port and log the URL (e.g., `http://localhost:56722`).

### 2. Mix Project Variant (`playground_mix/`)
A minimal but standard Mix project structure. Supports hot-reloading and standard tooling.

**Run it:**
```bash
cd playground_mix
mix deps.get
mix phx.server
```
Open `http://localhost:4000`.

## Notes

- The Interactions API can store interactions to support state/background work; be mindful of what you send and check the official docs for retention details.
