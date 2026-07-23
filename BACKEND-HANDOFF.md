# PAWN Backend Handoff

## 1. Objective

The backend owns project context, PAWN orchestration, and Injective transaction state. The iOS app owns wearable/audio interaction, local plaintext content, and presentation.

The required hackathon path is:

```text
capture -> 3 PAWN questions -> production pack -> in-app revision -> commercial proof
```

Do not build a generic chat backend first. Optimize this exact path for deterministic latency, retries, and observability.

## 2. Trust Boundary

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

The chain stores only commercial execution facts: task ID digest, artifact version digest, amount, parties, authorization state, split, and transaction references.

## 3. Required Data Model

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

Canonicalization must be documented and tested. Recommended: RFC 8785 JSON Canonicalization Scheme, then SHA-256 over UTF-8 bytes.

## 4. HTTP API

Base path: `/v1`. JSON only. Use `Authorization: Bearer <token>` and `Idempotency-Key` on every mutating request.

### Health

`GET /v1/health`

```json
{
  "status": "ok",
  "services": {
    "database": "ok",
    "model": "ok",
    "injective": "ok"
  },
  "version": "git-sha"
}
```

Return `200` when an optional dependency is degraded and use `status: degraded`. Return `503` only when the core capture/project API cannot serve requests.

### Create project

`POST /v1/projects`

```json
{
  "name": "AdventureX in 60 Seconds",
  "kind": "personal",
  "target_platform": "bilibili"
}
```

Response: `201` with `Project`.

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

For the hackathon, enforce a maximum of three required questions. Ask fewer only when all required slots are explicit: audience, format/duration, and opening angle.

### Generate Bilibili production pack

`POST /v1/conversations/{conversation_id}/generate`

Response `202`:

```json
{
  "job_id": "job_...",
  "status": "queued"
}
```

Poll `GET /v1/jobs/{job_id}` or stream server-sent events from `GET /v1/jobs/{job_id}/events`.

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

Validate model output against this schema before persistence. Never pass arbitrary model text directly to the app.

## 5. Injective Integration

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

Do not report a transaction as confirmed until queried from the network. Surface failure reason, retryability, and the original transaction hash if broadcast occurred.

### Read task proof

`GET /v1/commercial-tasks/{task_id}/proof`

Return the task state and ordered transactions. The app uses the provider-returned explorer URL and must not construct URLs from hashes.

## 6. Error Contract

All errors use:

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

Required codes:

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

## 7. Reliability And Security

- Deadline: first question under 3 seconds; complete production pack under 12 seconds.
- Retry only idempotent operations or requests carrying the same idempotency key.
- Use an outbox for chain broadcasts.
- Encrypt database/storage at rest; store secrets in environment or a secret manager.
- Never store wallet private keys in source, logs, mobile config, or the database as plaintext.
- Use structured logs with `request_id`, `project_id`, `conversation_id`, job latency, and provider status.
- Do not log transcript or conversation content in production mode.
- Keep a deterministic fixture provider for the venue demo, exposed explicitly as `demo_fixture`.

## 8. Backend Definition Of Done

- [ ] Contract tests cover the three-question sequence and artifact schema.
- [ ] Repeating an idempotency key returns the original resource.
- [ ] An out-of-order answer returns `SEQUENCE_CONFLICT` without mutating state.
- [ ] An in-app revision creates artifact version 2 under the same project.
- [ ] One real Injective testnet transaction reaches `confirmed` and exposes an explorer URL.
- [ ] No private content appears in chain payloads or normal logs.
- [ ] `/v1/health` identifies degraded providers before the stage demo.
- [ ] Demo fixture can complete the entire app flow when model or venue network is unavailable.
