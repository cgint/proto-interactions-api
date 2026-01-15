# Tech-Stack Know-How Cheat-Sheet

Quick reference for leveraging Phoenix, LiveView, and Ash generators (and other conveniences) **without violating our “no database, CSV only, zero new dependencies” rule.**

---
## 1. Phoenix / LiveView Generators

| Command | Purpose | Notes |
|---------|---------|-------|
| `mix phx.gen.live <Context> <Schema> <plural> <field:type> … --no-schema` | Scaffolds a LiveView, templates, route updates, and tests **without** creating an Ecto schema or migration. | Great for copying patterns—delete unused Ecto bits afterwards. |
| `mix phx.gen.html … --no-schema` | Same idea but produces controller/views instead of LiveView. | Use if you need non-LiveView HTML pages. |
| `mix phx.gen.component Sidebar sidebar list assigns` | Stubs a stateless HEEx function component. | Handy for quick component shells. |

**Tip:** Run generators in a scratch branch or throw-away commit, cherry-pick the parts you like, and discard the rest to keep history clean.

---
## 2. Ash Generators (when/if we expose resources)

Ash expects *some* data-layer, but you can scaffold and then point the resource to our custom CSV layer.

| Command | Outcome | Post-gen Tweaks |
|---------|---------|-----------------|
| `mix ash.gen.resource MyApp Chat conversations --data-layer simple` | Creates a `Chat` resource module with a Simple data-layer stub. | Replace `data_layer` with `LiveAiChat.CsvStorage`. Remove repo references. |
| `mix ash.gen.domain MyApp.ChatDomain --resources Chat,Message` | Produces a domain module wiring resources together. | Keep; ensures Ash DSL consistency. |
| `mix ash.gen.auth` | Sets up AshAuthentication scaffolding. | We’ve deferred auth; good reference for later stages. |

---
## 3. Boilerplate Helpers

* `mix phx.gen.tailwind` – Re-generates Tailwind config if ever required.
* `mix format --check-formatted` – Sanity check after pasting generator snippets.
* `mix test --failed --max-failures 1` – Fast feedback loop during TDD.

---
## 4. When Hand-Crafting Is Faster

* **CSV persistence** (`CsvStorage.ex`) and **ChatRegistry** are simpler to write manually.
* **AI streaming client** is bespoke; no generator covers it.
* LiveView stream logic (`stream_insert/4`, `handle_info/2`) still needs explicit coding.

---
## 5. Suggested Hybrid Workflow

1. Generate a LiveView scaffold:
   ```bash
   mix phx.gen.live Chat ChatLive chats title:string --no-schema
   ```
2. Strip out Ecto-specific pieces; wire the view to CSV-backed data per PLAN 2.
3. Copy useful route/test snippets into real modules.
4. Delete generator by-products (schemas, migrations, context modules).
5. Commit only the adapted, database-free code.

---
*Last updated: 2025-08-03*
