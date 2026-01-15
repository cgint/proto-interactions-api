from __future__ import annotations

import json
import os
from dataclasses import dataclass
from pathlib import Path
from typing import Any

import httpx
import httpx_sse
from starlette.applications import Starlette
from starlette.responses import FileResponse, JSONResponse
from starlette.routing import Route, WebSocketRoute
from starlette.websockets import WebSocket, WebSocketDisconnect


INTERACTIONS_BASE_URL = "https://generativelanguage.googleapis.com"
INTERACTIONS_VERSION = "v1beta"
DEFAULT_MODEL = "gemini-2.5-flash"


def _require_api_key() -> str:
    api_key = os.environ.get("GEMINI_API_KEY") or os.environ.get("GOOGLE_API_KEY")
    if not api_key:
        raise RuntimeError(
            "Missing API key: set GEMINI_API_KEY (or GOOGLE_API_KEY) in your environment."
        )
    return api_key


@dataclass
class SessionState:
    previous_interaction_id: str | None = None


def _static_dir() -> Path:
    return Path(__file__).resolve().parent / "static"


def _extract_interaction_id(payload: Any) -> str | None:
    if isinstance(payload, dict):
        if isinstance(payload.get("interaction"), dict):
            interaction_id = payload["interaction"].get("id")
            if isinstance(interaction_id, str) and interaction_id:
                return interaction_id
        interaction_id = payload.get("id")
        if isinstance(interaction_id, str) and interaction_id:
            return interaction_id
    return None


async def homepage(_: Any) -> FileResponse:
    return FileResponse(_static_dir() / "index.html")


async def health(_: Any) -> JSONResponse:
    return JSONResponse({"ok": True, "model": DEFAULT_MODEL})


async def ws_endpoint(websocket: WebSocket) -> None:
    await websocket.accept()

    state = SessionState()
    api_key = _require_api_key()

    async with httpx.AsyncClient(base_url=INTERACTIONS_BASE_URL, timeout=None) as client:
        while True:
            try:
                message = await websocket.receive_text()
            except WebSocketDisconnect:
                break

            user_text = message.strip()
            if not user_text:
                continue

            if user_text in {"/new", "/reset"}:
                state.previous_interaction_id = None
                await websocket.send_text(
                    json.dumps(
                        {
                            "type": "local.info",
                            "message": "Started a new interaction (cleared previous_interaction_id).",
                        }
                    )
                )
                continue

            request_body: dict[str, Any] = {
                "model": DEFAULT_MODEL,
                "input": user_text,
                "stream": True,
                "store": True,
            }
            if state.previous_interaction_id:
                request_body["previous_interaction_id"] = state.previous_interaction_id

            headers = {"x-goog-api-key": api_key, "Accept": "text/event-stream"}

            await websocket.send_text(
                json.dumps(
                    {
                        "type": "local.request",
                        "request": {
                            "model": DEFAULT_MODEL,
                            "previous_interaction_id": state.previous_interaction_id,
                            "stream": True,
                        },
                    }
                )
            )

            try:
                async with httpx_sse.aconnect_sse(
                    client,
                    "POST",
                    f"/{INTERACTIONS_VERSION}/interactions",
                    json=request_body,
                    headers=headers,
                    timeout=None,
                ) as event_source:
                    event_source.response.raise_for_status()
                    async for sse in event_source.aiter_sse():
                        payload: Any
                        try:
                            payload = sse.json()
                        except Exception:
                            payload = {"raw": sse.data}

                        interaction_id = _extract_interaction_id(payload)
                        if interaction_id:
                            state.previous_interaction_id = interaction_id

                        await websocket.send_text(
                            json.dumps(
                                {
                                    "type": "interactions.sse",
                                    "event": sse.event,
                                    "id": sse.id,
                                    "data": payload,
                                }
                            )
                        )
            except httpx.HTTPStatusError as e:
                error_text = None
                try:
                    error_text = e.response.text
                except Exception:
                    pass
                await websocket.send_text(
                    json.dumps(
                        {
                            "type": "interactions.error",
                            "status_code": e.response.status_code,
                            "body": error_text,
                        }
                    )
                )
            except Exception as e:
                await websocket.send_text(
                    json.dumps({"type": "local.error", "message": str(e)})
                )


routes = [
    Route("/", homepage),
    Route("/health", health),
    WebSocketRoute("/ws", ws_endpoint),
]

app = Starlette(debug=True, routes=routes)
