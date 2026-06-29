# flutter_offline_sync — project reference

## Purpose

Offline-first mobile app for **field reviewers and inspectors**. Users visit sites (restaurants, construction sites, etc.), start an inspection for a selected category, and complete a dynamic form. Data is stored locally first and synced to a remote API when connectivity allows.

## Monorepo packages

| Package | Role |
|---------|------|
| `apps/mobile_app` | Flutter UI, wires packages, implements `SyncTransport` (REST) |
| `packages/foundation` | Design tokens, theme, shared UI components |
| `packages/dynamic_form` | JSON-driven form definitions and rendering (per inspection type) |
| `packages/sync_engine` | Offline storage, outbox sync, conflict handling — **no HTTP knowledge** |

## Phases

1. **Current** — `sync_engine` scaffold + mobile UI (forms, inspection flows)
2. **Next** — local backend + database on dev machine for REST APIs

## Inspection flow (target)

1. Reviewer picks a category (e.g. restaurant, construction).
2. App loads the matching form JSON from `dynamic_form`.
3. Form renders with `foundation` theme and components.
4. Submissions are saved via `sync_engine` with a domain `eventType` (e.g. `restaurantInspection`, `constructionInspection`).
5. When online, `sync_engine` pushes pending records through `SyncTransport` (implemented in `mobile_app`).
6. Remote server stores canonical data; pull sync merges server changes when implemented.

## sync_engine design

### Record envelope (model-agnostic)

| Field | Meaning |
|-------|---------|
| `localId` | Client UUID, stable |
| `serverId` | Set after first successful push |
| `eventType` | Domain entity — `todoList`, `restaurantInspection`, `profileEdit`, etc. (from app) |
| `operation` | `create` \| `update` \| `delete` |
| `data` | JSON payload for API and UI |
| `createdAt` / `editedAt` / `lastSyncedAt` | Timestamps |
| `syncStatus` | `pending` \| `synced` \| `failed` \| `conflict` |

`eventType` is **not** an HTTP verb. The app maps `eventType` + `operation` → REST routes inside `SyncTransport`.

### Boundaries

```
mobile_app UI
    → SyncEngine.save / update / delete / watch
    → LocalStore (Drift / SQLite)

SyncWorker (sync_engine)
    → SyncTransport.push / pull   [interface]
    → AppSyncTransport (mobile_app) → Dio / REST
```

- Engine never holds base URLs, auth, or HTTP methods.
- App implements `SyncTransport` per `eventType`.
- UI may listen to `status` stream for sync indicators only — it does not drive API calls.

### Conflict policy (default)

- Unsynced records (`serverId == null`) always push as create.
- On conflict, compare `editedAt` (last-write-wins) unless transport resolves server-side.
- Network errors: keep local data, retry with backoff.

### Isolates

MVP runs sync on the main isolate with async I/O. Background isolate + message bridge can be added later without changing `SyncTransport`.

## dynamic_form (planned)

- JSON schemas per inspection category.
- Rendered with `foundation` widgets and `context.theme`.
- Output JSON stored in `sync_engine` record `data`.

## Local backend (next phase)

- REST API matching `SyncTransport` contracts per `eventType`.
- Run on developer machine for integration testing.
- Not part of `sync_engine`.
