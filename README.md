# proto-interactions-api

Minimal local demo for the Gemini **Interactions API** that shows streaming events in a browser UI.

## Prereqs

- Python 3.10+ (3.12+ recommended)
- `GEMINI_API_KEY` exported in your shell

## Run

```bash
uv sync

uv run python -m web_demo --reload --port 8000
```

Open:

- `http://localhost:8000/`

Notes:

- Send text; the server calls Interactions API with `model="gemini-2.5-flash"` and `stream=true`.
- Use `/new` (or `/reset`) to clear `previous_interaction_id` for that browser session.
