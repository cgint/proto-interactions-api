# Gemini API “Interactions API” — research notes + Python sample

## First attempty goal

What the user wants to get in a first attempt is to get a 'feel' of the interactive nature. So an example of a minimal application could be a Web-GUI that allows to send text message at any time and this is sent via Interactions API. And whenever an event is received from Interactions API then it is simply displayed.
Only text is fully fine for this first attempts.

## Your request (captured)

You asked for:

- What the “Google Interactions API” is
- A simple sample application (terminal or GUI), ideally Python
- Good samples (ideally Google-authored code on GitHub)
- A written analysis in Markdown

You later clarified you mean *specifically and only*:

- `https://blog.google/innovation-and-ai/technology/developers-tools/interactions-api/`
- `https://ai.google.dev/gemini-api/docs/interactions`

## Correction (why this file changed)

The directory was initially empty, so I had to guess what “Interactions API” referred to. With your links, it’s clearly the **Gemini API Interactions API** (not Business Messages / Android).

## What the Interactions API is (high-level)

From the announcement + docs:

- A **single API surface** to interact with:
  - Gemini **models**
  - Built-in Gemini **agents** (the announcement mentions Gemini Deep Research)
- Designed for **agentic workflows** (multi-turn, tool use, thoughts vs. final responses)
- Supports **server-side state** for conversations via `previous_interaction_id`
- Supports **background execution** (long-running inference loops handled server-side)
- Supports tool calls, including **Remote MCP tool support** (mentioned in the announcement)
- **Beta/preview** and subject to change

## How to call it (endpoints + SDK)

### REST endpoint

- `POST https://generativelanguage.googleapis.com/v1beta/interactions`
- OpenAPI spec: `https://ai.google.dev/api/interactions.openapi.json`

## Most important behavioral notes (practical)

- **1 request = 1 Interaction**: Each `interactions.create` call creates a new `Interaction` resource representing a full “turn” (inputs, tool calls/results, outputs). Source: Interactions docs “How the Interactions API works” (`https://ai.google.dev/gemini-api/docs/interactions`) and API reference (`https://ai.google.dev/api/interactions-api`).
- **Server-side conversation state is explicit**: Pass `previous_interaction_id` to continue a conversation without resending history. Only *history* is preserved; other settings (tools, system instruction, generation config) are **interaction-scoped** and must be re-specified each call. Source: “Server-side state management” (`https://ai.google.dev/gemini-api/docs/interactions`).
- **Ordering/concurrency is client-managed**:
  - The docs describe `previous_interaction_id` as using the `id` of a completed interaction to continue the conversation. Source: “Server-side state management” (`https://ai.google.dev/gemini-api/docs/interactions`).
  - The API does not document any server-side queuing/serialization guarantee for multiple simultaneous `interactions.create` calls; treat strict ordering as a **client responsibility**. (Practical implication of the above.)
  - If you need strict in-order turns, wait for interaction A to complete, then call B with `previous_interaction_id=A.id`.
- **Streaming is SSE**: With `stream=true`, the response is Server-Sent Events. Source: Interactions docs + API reference (`https://ai.google.dev/gemini-api/docs/interactions`, `https://ai.google.dev/api/interactions-api`).
- **Resume streaming (OpenAPI)**: `GET /v1beta/interactions/{id}?stream=true` supports `last_event_id` to resume “from the next chunk”. Source: OpenAPI spec (`https://ai.google.dev/api/interactions.openapi.json`), `GetInteraction` query parameter `last_event_id`.
- **Background execution + cancel**: `background=true` runs the interaction asynchronously server-side; cancellation exists for background interactions via `POST /v1beta/interactions/{id}/cancel`. Source: Interactions docs + OpenAPI spec (`https://ai.google.dev/gemini-api/docs/interactions`, `https://ai.google.dev/api/interactions.openapi.json`).

## Sources (primary)

- Announcement blog post: `https://blog.google/innovation-and-ai/technology/developers-tools/interactions-api/`
- Interactions docs: `https://ai.google.dev/gemini-api/docs/interactions`
- API reference: `https://ai.google.dev/api/interactions-api`
- OpenAPI spec: `https://ai.google.dev/api/interactions.openapi.json`

### Python SDK

The docs use the Google GenAI SDK:

- Python package: `google-genai` (docs state “from 1.55.0 version onwards”)
- Usage pattern:
  - `client = genai.Client()`
  - `client.interactions.create(...)`
  - Use `previous_interaction_id=<prior_interaction.id>` to continue a conversation

## Data storage + retention (important for “stateful” mode)

The docs note that interactions are stored by default (`store=true`) to enable state management and background execution.

Retention periods called out in the docs:

- Paid tier: **55 days**
- Free tier: **1 day**

If you need “no server-side storage”, use the stateless pattern (include full conversation history each call) and/or explicitly disable storage per the docs.

## Google(-maintained) samples and repos worth using

### Official docs and cookbook

- Interactions API docs: `https://ai.google.dev/gemini-api/docs/interactions`
- Gemini API Cookbook: `https://github.com/google-gemini/cookbook`
  - Includes links to official SDK repos and multiple end-to-end demo repos.

### Official SDK repo (Python)

- `https://github.com/googleapis/python-genai`

### “Simple app” starter (Python Flask)

The cookbook lists a Gemini API quickstart Flask app:

- `https://github.com/google-gemini/gemini-api-quickstart`

### Agent Development Kit (ADK) integration example (Interactions API)

The Google Developers Blog post “Building agents with the ADK and the new Interactions API” links to:

- `https://github.com/google/adk-python/tree/main/contributing/samples/interactions_api`

### A2A transport sample using Interactions API

Same post links to an A2A sample transport branch:

- `https://github.com/a2aproject/a2a-samples/tree/interactions-api/samples/python/transports/interactions_api`

#### What’s in the A2A sample (and how it can help us)

You extracted `a2a-samples` to `/Users/cgint/dev-external/a2a-samples`.

Key detail: the `interactions_api` transport is **not** on `main` in that checkout; it’s on the repo’s `interactions-api` branch (you can see it locally as `origin/interactions-api`).

That branch includes a ready-to-run Interactions API *proxy* and a reusable transport implementation:

- `samples/python/transports/interactions_api/interactions_api_transport.py`: an A2A `ClientTransport` that calls:
  - `POST /v1beta/interactions` (streaming via SSE for streaming mode)
  - `GET /v1beta/interactions/{id}` (including `?stream=true` for resubscribe)
  - `POST /v1beta/interactions/{id}/cancel`
- `samples/python/transports/interactions_api/__main__.py`: runs a local Starlette/uvicorn server that exposes a standard A2A JSON-RPC endpoint (default `http://localhost:10000`) and forwards requests to Interactions API.
- `samples/python/transports/interactions_api/request_handler.py`: a thin adapter that forwards A2A server requests to the transport.

Why this is useful for a “simple app”:

- If you want a GUI without building one: you can run the proxy and then connect existing A2A clients/tools (e.g. an inspector UI) to `localhost:10000` as if it were a normal A2A agent.
- The transport shows *concrete mechanics* for Interactions streaming:
  - sets `store: True` and uses `previous_interaction_id` to continue conversations
  - uses SSE `last_event_id` to re-attach if the stream disconnects
  - maps “thought summaries” into A2A `TaskStatusUpdateEvent` updates

Notes/caveats:

- The transport uses raw `httpx` + `httpx-sse` (it includes a `TODO` to migrate to the GenAI SDK once Interactions API support is available).
- It expects an API key via `GOOGLE_API_KEY` or `GEMINI_API_KEY`.

## Simple Python “terminal app” (minimal)

This is a small REPL-style sample that:

- Sends a prompt via `client.interactions.create`
- Persists `previous_interaction_id` in a local file so you can continue the conversation

```python
from __future__ import annotations

from pathlib import Path

from google import genai

STATE_FILE = Path(".interaction_id")


def main() -> None:
    client = genai.Client()
    previous_id = STATE_FILE.read_text().strip() if STATE_FILE.exists() else None

    print("Type a message. Empty line exits. Type /new to start a new interaction.")
    while True:
        user_text = input("> ").strip()
        if not user_text:
            break
        if user_text == "/new":
            previous_id = None
            if STATE_FILE.exists():
                STATE_FILE.unlink()
            print("(started new interaction)")
            continue

        interaction = client.interactions.create(
            model="gemini-2.5-flash",
            input=user_text,
            previous_interaction_id=previous_id,
        )
        previous_id = interaction.id
        STATE_FILE.write_text(previous_id)
        print(interaction.outputs[-1].text)


if __name__ == "__main__":
    main()
```

To run, you’ll need:

- `pip install 'google-genai>=1.55.0'`
- `export GEMINI_API_KEY='…'` (or whatever auth mechanism you choose per `python-genai` docs)

## Open questions (so we build the right “simple app”)

1. Do you want the sample to target a **model** (`model=...`) or a built-in **agent** (`agent=...`, e.g. Deep Research)?
2. Should the sample default to **stateful** (`previous_interaction_id`) or **stateless** (full history each call) given the storage/retention implications?
3. Do you prefer a **terminal REPL** (fast) or a small **local GUI** (Tkinter) for a demo?
