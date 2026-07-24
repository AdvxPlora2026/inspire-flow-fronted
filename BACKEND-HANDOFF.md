# PAWN Backend Handoff (v2 — reconciled with the shipped backend)

## 0. Why this revision exists

Handoff v1 described a PAWN/Injective API that was never built. The backend
that actually ships today (`inspire-flow-backend`) is a different, already-
useful system: auth, creator profiles, a generic Agent conversation with
long-term memory, project CRUD with AI drafting, and asynchronous speech
transcription. See its own docs for ground truth:

- `docs/HANDOFF_USERSYS.MD` — registration, login, profile
- `docs/HANDOFF_PROJECTS.md` — project CRUD, AI draft, Agent project tools
- `docs/HANDOFF_AGENT_MEMORY.md` — Agent conversations and long-term memory
- `docs/HANDOFF_STT.md` — async SenseVoice transcription

The iOS frontend has already integrated against that real backend: register,
login, logout, and Keychain-backed session restore are live
(`BackendClient.swift`, `AuthAPI.swift`, `AppSession.swift`). This document
reconciles the two so both teams build against the same facts, and states
what each side still owes the other to hit the demo loop with the best
possible user experience:

```text
capture -> 3 PAWN questions -> production pack -> in-app revision -> commercial proof
```

Do not build a generic chat backend first. Optimize this exact path for
deterministic latency, retries, and observability. Sections 6–11 below are
the original target API design, kept because it is still the right shape —
just not implemented yet. Section 5 is new: it tells the backend exactly what
the frontend already assumes and will keep assuming.

## 1. Trust boundary (unchanged)

### May reach the backend

- Opaque user, project, capture, conversation, and artifact IDs.
- Transcript text when the user explicitly starts a PAWN request.
- Visibility enum: `private`, `project_members`, or `public`.
- Generated artifact JSON.
- Commercial task metadata and artifact version digest.

### Must not be written on-chain

- Raw audio or complete transcripts.
- Scripts, prompts, private conversation turns, names, or contact information.
- API keys, wallet private keys, or access tokens.

The chain stores only commercial execution facts: task ID digest, artifact
version digest, amount, parties, authorization state, split, and transaction
references.

## 2. What is already live — do not break this contract

The frontend already depends on these exact behaviors. Any backend change
here needs a coordinated frontend release, not a silent break.

| Endpoint | Behavior the frontend already relies on |
| --- | --- |
| `POST /api/v1/users` | Registers only; does **not** create a session. `nickname` 2–50 chars (NFKC-folded uniqueness), `password` 15–128 chars. `409 nickname_conflict`, `422 validation_error`. |
| `POST /api/v1/sessions` | Login by nickname+password. Same `401 invalid_credentials` for unknown nickname or wrong password (frontend must not infer account existence from this). Returns `access_token`, `expires_at`, `user`. |
| `DELETE /api/v1/sessions/current` | Revokes only the current token; other sessions for the same user stay valid. `204` empty body. |
| `GET /api/v1/users/me` | Used by `AppSession.restoreSession()` on every launch to validate a cached Keychain token. `401 invalid_session` triggers a local sign-out; any other error (including no network) keeps the cached session so the app stays usable offline. |
| `GET/PATCH /api/v1/users/me/profile` | Creator profile fields (`bio`, `timezone`, `preferred_language`, `creator_identity`, `content_focus`, `collaboration_preferences`). Not yet wired into `CreatorProfile` locally — planned next. |
| `POST /api/v1/projects/drafts`, `/api/v1/projects` CRUD | Project fields are `title/type/audience/summary/icon_url` only. **The backend project model has no `kind` (personal/commercial) or `stage` (brief/creating/review/approved/settled) field.** The frontend's `CreatorProject` currently keeps those two fields as a local-only overlay. Flagged in section 8 as a decision point. |
| Error envelope | `{"error": {"code": "...", "message": "..."}}` — no `retryable` or `request_id` today, unlike the richer envelope in section 9. See section 5 for why this matters. |

Base URL used in development: `http://127.0.0.1:8000/api/v1`. Bare IP
addresses are exempt from App Transport Security, so no Info.plist exception
is required; physical-device testing needs the Mac's LAN IP instead of
`127.0.0.1`.

## 3. Critical gap for the P0 demo

None of the PAWN-specific endpoints below (captures, conversation answers,
generation, commercial tasks) exist yet. Only a generic Agent conversation
(`/api/v1/conversations`, `/messages`) and generic project CRUD exist. This
blocks, in order of demo impact:

1. A deterministic, exactly-three-question interview with `ready_to_generate`.
2. A schema-validated Bilibili production pack the app can trust without
   re-validating arbitrary model text itself.
3. Capture/artifact persistence with an explicit visibility enum.
4. Idempotent answer submission (`SEQUENCE_CONFLICT` on out-of-order answers).
5. Any Injective commercial-task flow at all.

### Recommended path given remaining hackathon time

**Option A — reuse the existing Agent conversation infra (recommended).**
Add a constrained "PAWN mode" instead of a parallel system:

- `POST /api/v1/agent/pawn/captures` — wraps `create_conversation` +
  first `messages` call with a fixed system prompt that (a) asks at most
  three required questions (audience, format/duration, opening angle) and
  (b) on the turn after the third answer, emits the final assistant message
  as **validated JSON only**, matching the `bilibili_production_pack` schema
  in section 7. Reject and retry the model call server-side if the JSON
  fails validation — never forward unvalidated model text to the app.
- Answers continue to use the existing `POST /conversations/{id}/messages`.
- `GET /api/v1/agent/pawn/captures/{id}` returns the current turn/question,
  `ready_to_generate`, and the artifact once generated.

This reuses the already-working conversation, message persistence, context
compaction, and memory infrastructure, and only adds a thin, validated layer
on top. It is the smallest change that still satisfies "never pass arbitrary
model text directly to the app."

**Option B — build the full original spec** (sections 6–8 below) as
literally specified. More correct long-term, more work now. Do this only if
Option A's constrained-prompt approach proves unreliable in testing.

Either option must still satisfy: exactly one question returned per turn,
`SEQUENCE_CONFLICT` on an out-of-order answer, idempotency-key support, and a
`demo_fixture` path that works with no model/network at all (the frontend
already has this fallback locally — see `InspirationRecordView.swift`'s
`isDemoFallback` and keep it as the safety net, not the primary path).

## 4. Injective — currently 0% built

Nothing in section 8/9 exists yet. This is P0 item 5 in `TODO.md`. Minimum
viable slice for the stage demo: one fixed commercial brief, one real
Injective testnet transaction (escrow preferred, split settlement
acceptable), and a `GET .../proof` endpoint returning a provider-supplied
explorer URL. The frontend must never construct an explorer URL from a raw
transaction hash — always use the backend-returned URL.

## 5. Requirements handed to the frontend (already agreed, tracked here for the backend's benefit)

So the backend can rely on client behavior instead of guessing it:

- The bearer token lives in the Keychain only, never `UserDefaults` or logs
  (`KeychainTokenStore` in `BackendClient.swift`).
- Every mutating request the frontend makes once capture/answer/commercial
  endpoints exist will carry an `Idempotency-Key`; the backend should return
  the original resource on a repeat, not a duplicate or a conflict.
- Client-side request timeout is 10 seconds with a visible retry action per
  `TODO.md` P0; the backend should assume the client gives up and lets the
  user retry rather than waiting indefinitely.
- Network failures during `restoreSession()` never sign the user out; only a
  definitive `401`/`invalid_session` does. Backend session/token errors
  should be unambiguous so the client does not have to guess.
- Demo/offline fixtures are always visibly labeled in the UI
  (`isDemoFallback`) and never claim a backend or chain operation succeeded
  when it did not.
- The frontend will not invent `kind`/`stage` values on the wire until the
  backend has a first-class place for them (see section 8) — it keeps them
  as a local overlay keyed by the backend project ID today.
- The frontend will keep mapping specific `error.code` values to specific UI
  copy (see the table in section 2) rather than showing a generic failure
  message — new error codes should be added to this document, not silently
  introduced.

## 6. Required data model (target design)

Use UUIDv7 or another sortable opaque ID. All timestamps are RFC 3339 UTC.

### Project

```json
{
  "id": "prj_...",
  "owner_id": "usr_...",
  "name": "AdventureX in 60 Seconds",
  "kind": "personal",
  "stage": "creating",
  "target_platform": "bilibili",
  "created_at": "2026-07-23T14:00:00Z",
  "updated_at": "2026-07-23T14:00:00Z"
}
```

`kind`: `personal | commercial`

`stage`: `brief | creating | review | approved | settled`

Note: the live project endpoints do not have `kind`/`stage`/`target_platform`
today (they have `title/type/audience/summary/icon_url` instead). Reconcile
per section 8 before building capture/artifact persistence against this
shape.

### Capture

```json
{
  "id": "cap_...",
  "project_id": "prj_...",
  "source": "ring_voice",
  "transcript": "I want to open with a creator almost losing an idea.",
  "visibility": "private",
  "status": "interviewing",
  "created_at": "2026-07-23T14:01:00Z"
}
```

`source`: `ring_voice | headphone_voice | phone_voice | app_text | demo_fixture`

The ring is an optional accessory. The primary sources are `phone_voice`,
`headphone_voice`, and `app_text`; treat `ring_voice` as equivalent voice
input and never require a ring for any capture, interview, or generation
step.

`status`: `transcribing | interviewing | generating | completed | failed`

### Conversation turn

```json
{
  "id": "turn_...",
  "conversation_id": "cnv_...",
  "project_id": "prj_...",
  "capture_id": "cap_...",
  "role": "assistant",
  "text": "Who is this video for?",
  "sequence": 1,
  "channel": "app",
  "created_at": "2026-07-23T14:01:02Z"
}
```

### Artifact

```json
{
  "id": "art_...",
  "project_id": "prj_...",
  "version": 1,
  "type": "bilibili_production_pack",
  "content": {},
  "sha256": "lowercase-hex-sha256-of-canonical-content-json",
  "created_at": "2026-07-23T14:02:00Z"
}
```

Canonicalization must be documented and tested. Recommended: RFC 8785 JSON
Canonicalization Scheme, then SHA-256 over UTF-8 bytes.

### Frontend local model mapping

The iOS app persists a local `InspirationCapture` model. When the backend
replaces the local fixtures, map fields as follows so no client migration is
required beyond swapping the data source:

| Local field (`InspirationCapture`) | Backend field | Notes |
| --- | --- | --- |
| `id` (`UUID`) | `Capture.id` | Client currently generates a local UUID; replace with the server opaque ID on sync. |
| `transcription` (`String`) | `Capture.transcript` | Local plaintext; sent only when the user explicitly starts a PAWN request. |
| `pawnQAs` (`[PawnQA]`) | Conversation turns | Each `PawnQA` is one assistant question + one creator answer pair. |
| `bilibiliPack` (`BilibiliPack?`) | `Artifact.content` | Maps to `type: bilibili_production_pack` (title/hook/outline/shot list). |
| `projectID` (`UUID?`) | `Capture.project_id` | Optional until the capture is assigned to a project. |
| `privacy` (`privateOnly \| projectMembers \| publicContent`) | `Capture.visibility` (`private \| project_members \| public`) | Enum names differ; values correspond one-to-one. |
| `createdAt` (`Date`) | `Capture.created_at` | RFC 3339 UTC on the wire. |
| `isDemoFallback` (`Bool`) | `Capture.source = demo_fixture` | Demo captures must stay visibly identified and must not imply backend success. |

## 7. Target HTTP API for the PAWN loop

Base path: `/v1` (or `/api/v1/agent/pawn/...` under Option A). JSON only. Use
`Authorization: Bearer <token>` and `Idempotency-Key` on every mutating
request.

### Start capture

`POST /v1/projects/{project_id}/captures`

```json
{
  "source": "ring_voice",
  "transcript": "This ring turns hardware gestures into screenless creation.",
  "visibility": "private",
  "locale": "zh-CN"
}
```

Response `201`:

```json
{
  "capture": { "id": "cap_...", "status": "interviewing" },
  "conversation_id": "cnv_...",
  "turn": {
    "sequence": 1,
    "question": "Who is this video for?",
    "ready_to_generate": false
  }
}
```

### Answer one PAWN question

`POST /v1/conversations/{conversation_id}/answers`

```json
{
  "question_sequence": 1,
  "answer": "Bilibili creators who lose ideas while filming.",
  "input_mode": "voice"
}
```

Response `200` returns exactly one next question, or generation readiness:

```json
{
  "turn": {
    "sequence": 2,
    "question": "Should this be a 60-second vertical video or a longer story?",
    "ready_to_generate": false
  }
}
```

After at least three answered questions:

```json
{
  "turn": {
    "sequence": 4,
    "question": null,
    "ready_to_generate": true
  }
}
```

Enforce a maximum of three required questions. Ask fewer only when all
required slots are explicit: audience, format/duration, and opening angle.

### Generate Bilibili production pack

`POST /v1/conversations/{conversation_id}/generate`

Response `202`:

```json
{
  "job_id": "job_...",
  "status": "queued"
}
```

Poll `GET /v1/jobs/{job_id}` or stream server-sent events from
`GET /v1/jobs/{job_id}/events`.

Completed payload:

```json
{
  "status": "completed",
  "artifact": {
    "id": "art_...",
    "version": 1,
    "type": "bilibili_production_pack",
    "content": {
      "titles": ["I Used a Ring to Save an Idea I Almost Lost"],
      "three_second_hook": "The best creation tool may not have a screen.",
      "audience": "Bilibili creators",
      "format": "60-second vertical video",
      "outline": [
        { "order": 1, "title": "The lost-idea problem", "seconds": 10 },
        { "order": 2, "title": "Ring and earphone loop", "seconds": 30 },
        { "order": 3, "title": "PAWN output", "seconds": 20 }
      ],
      "shots": [
        {
          "order": 1,
          "visual": "Creator filming at the venue",
          "line": "I nearly lost this idea.",
          "seconds": 5,
          "note": "Handheld, preserve venue sound"
        }
      ],
      "teleprompter": ["The best ideas rarely wait for a screen."],
      "description": "...",
      "tags": ["AdventureX", "AI", "wearable"],
      "comment_prompt": "When do your best ideas appear?"
    },
    "sha256": "..."
  }
}
```

Validate model output against this schema before persistence. Never pass
arbitrary model text directly to the app.

## 8. Project field reconciliation — a decision the backend owns

| Frontend needs (`CreatorProject`) | Backend has today | Options |
| --- | --- | --- |
| `kind` (`personal \| commercial`) | Not present | (a) Add as a real column; (b) keep frontend-local, keyed by `project.id`, forever |
| `stage` (`brief \| creating \| review \| approved \| settled`) | Not present | Same as above |
| `name` | `title` | Rename mapping only, no behavior change |
| `initialIdea` (unstructured) | `summary`/`audience`/`type` (structured) | Frontend should migrate to the structured fields — this was already flagged as tech debt in `FRONTEND-HANDOFF.md` |

Recommendation: add `kind` and `stage` as real, optional columns on the
backend `Project` model (default `personal`/`brief`) rather than leaving them
frontend-only forever — the commercial workflow (`ClientBriefsView`,
`ProjectDetailView`'s stage-advance action) needs a server-durable stage that
survives reinstall and multi-device use, which a local-only overlay cannot
provide.

## 9. Injective integration (target design)

### Commercial task

`POST /v1/commercial-tasks`

```json
{
  "project_id": "prj_...",
  "title": "Introduce three AdventureX projects in 60 seconds",
  "budget": { "amount": "500.00", "denom": "USDT" },
  "deadline": "2026-07-23T18:00:00+08:00",
  "splits": [
    { "party_id": "creator", "bps": 7000 },
    { "party_id": "camera", "bps": 3000 }
  ]
}
```

Reject unless split basis points total exactly `10000`.

### Submit artifact version

`POST /v1/commercial-tasks/{task_id}/submissions`

```json
{
  "artifact_id": "art_...",
  "artifact_sha256": "...",
  "delivery_url": "https://www.bilibili.com/video/..."
}
```

### Chain transaction record

Persist this provider-reported record:

```json
{
  "network": "injective-testnet",
  "chain_id": "provider-reported-chain-id",
  "transaction_hash": "...",
  "explorer_url": "https://...",
  "status": "broadcast",
  "action": "escrow_funded",
  "task_id": "tsk_...",
  "artifact_sha256": null,
  "amount": "500.00",
  "denom": "USDT",
  "submitted_at": "2026-07-23T14:10:00Z",
  "confirmed_at": null
}
```

`status`: `prepared | broadcast | confirmed | failed`

`action`: `escrow_funded | submission_recorded | authorization_activated | settlement_released`

Do not report a transaction as confirmed until queried from the network.
Surface failure reason, retryability, and the original transaction hash if
broadcast occurred.

### Read task proof

`GET /v1/commercial-tasks/{task_id}/proof`

Return the task state and ordered transactions. The app uses the
provider-returned explorer URL and must not construct URLs from hashes.

## 10. Error contract

The live backend uses a minimal envelope today:

```json
{
  "error": {
    "code": "invalid_session",
    "message": "A valid bearer session is required"
  }
}
```

The target design below adds `retryable` and `request_id`. **Ask:** add at
least `retryable: boolean` to the live envelope across all routers before
building the PAWN endpoints — it is what lets the frontend decide "show a
retry button" vs. "this needs different input" without a hardcoded
per-`code` table, which is the single biggest low-effort UX win available on
the backend side right now.

```json
{
  "error": {
    "code": "PAWN_MODEL_TIMEOUT",
    "message": "PAWN did not respond within 10 seconds.",
    "retryable": true,
    "request_id": "req_...",
    "details": {}
  }
}
```

Required codes for the PAWN/Injective surface:

| HTTP | Code | Meaning |
| --- | --- | --- |
| 400 | `VALIDATION_FAILED` | Request or model output failed schema validation |
| 401 | `UNAUTHORIZED` | Missing or invalid app token |
| 404 | `PROJECT_NOT_FOUND` | Opaque ID does not exist for this user |
| 409 | `SEQUENCE_CONFLICT` | Duplicate/out-of-order answer or invalid task transition |
| 422 | `INTERVIEW_INCOMPLETE` | Generate called before required context exists |
| 429 | `RATE_LIMITED` | Client should honor `Retry-After` |
| 503 | `INJECTIVE_UNAVAILABLE` | Chain RPC temporarily unavailable |
| 504 | `PAWN_MODEL_TIMEOUT` | Model deadline exceeded |

Existing live codes the frontend already handles (keep these too):
`invalid_credentials`, `invalid_session`, `nickname_conflict`,
`validation_error`, `project_not_found`, `agent_run_failed`,
`agent_unavailable`.

## 11. Reliability and security

- Deadline: first question under 3 seconds; complete production pack under
  12 seconds.
- Retry only idempotent operations or requests carrying the same idempotency
  key.
- Use an outbox for chain broadcasts.
- Encrypt database/storage at rest; store secrets in environment or a secret
  manager (the live backend already does this for context/memory via
  `APP_CONTEXT_ENCRYPTION_KEY` — reuse the same key management for anything
  new).
- Never store wallet private keys in source, logs, mobile config, or the
  database as plaintext.
- Use structured logs with `request_id`, `project_id`, `conversation_id`, job
  latency, and provider status.
- Do not log transcript or conversation content in production mode.
- Keep a deterministic fixture provider for the venue demo, exposed
  explicitly as `demo_fixture`.

## 12. Definition of done

### Backend

- [ ] Decide and implement Option A or B from section 3.
- [ ] Add `retryable` (and ideally `request_id`) to the live error envelope.
- [ ] Resolve the `kind`/`stage` project field gap (section 8).
- [ ] Contract tests cover the three-question sequence and artifact schema.
- [ ] Repeating an idempotency key returns the original resource.
- [ ] An out-of-order answer returns `SEQUENCE_CONFLICT` without mutating
      state.
- [ ] An in-app revision creates artifact version 2 under the same project.
- [ ] One real Injective testnet transaction reaches `confirmed` and exposes
      an explorer URL.
- [ ] No private content appears in chain payloads or normal logs.
- [ ] `/api/v1/health` identifies degraded providers before the stage demo.
- [ ] Demo fixture can complete the entire app flow when model or venue
      network is unavailable.

### Frontend

- [ ] Keep the Keychain-only token storage and offline-tolerant
      `restoreSession()` behavior (done, do not regress).
- [ ] Add `Idempotency-Key` generation once capture/answer/commercial
      endpoints exist.
- [ ] Add a 10-second timeout + visible retry to every remote request
      (`TODO.md` P0 item 1).
- [ ] Wire `GET/PATCH /users/me/profile` into `CreatorProfile`.
- [ ] Replace the `initialIdea` free-text field with the structured
      `title/type/audience/summary/icon_url` fields once section 8 is
      resolved.
- [ ] Never construct an Injective explorer URL from a transaction hash.
- [ ] Keep every demo/offline fixture visibly labeled as such.
