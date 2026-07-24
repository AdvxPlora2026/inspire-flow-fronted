# inspireFlow

> Capture ideas without breaking the moment, develop them with PAWN, and carry creative work from inspiration to delivery.

inspireFlow is a SwiftUI workspace for creators and brands. It combines voice-first inspiration capture, persistent AI conversations, project organization, teleprompting, and commercial collaboration in one iOS experience. A Zilo smart ring can trigger capture without requiring the creator to reach for the screen.

The app uses the production inspireFlow backend at [platform.advx.uk](https://platform.advx.uk) and keeps a local demo mode for hackathon presentations.

## Product Flow

```text
Idea in the moment
    -> ring or on-screen capture
    -> voice transcription and inspiration record
    -> PAWN follow-up conversation
    -> project and production materials
    -> teleprompter, export, or brand delivery
    -> Injective-backed commercial proof and settlement
```

## Current Features

### Creator Workspace

- Capture and retain inspirations from anywhere in the app.
- Organize inspirations into persistent projects.
- Continue a project-specific PAWN conversation backed by the remote Agent API.
- View project structure as an interactive mind map with collision handling and pinch zoom.
- Generate and use Bilibili-oriented production packs containing a hook, outline, and shot list.
- Run a full-screen teleprompter with adjustable type and automatic section progression.
- Export generated production material through the iOS share sheet.
- Scan, connect, inspect, and disconnect a Zilo ring from the device screen.

### Brand Workspace

- Create commercial briefs with requirements, budget context, and a deadline.
- Persist briefs as remote projects before reporting success.
- Review commercial projects from the brand dashboard.
- Open a project-scoped PAWN conversation from the messages workspace.
- See where Injective escrow, artifact proof, authorization, and settlement belong in the commercial lifecycle.

### Account Modes

- Real accounts authenticate against the production API and store bearer tokens in Keychain.
- Cached sessions survive temporary backend outages and are invalidated only after a confirmed unauthorized response.
- Demo credentials `123` / `123` open a local-only sandbox.
- Demo users can switch between creator and brand roles and reset sample data.
- Demo-only controls are never shown to real users.

## Registration and Profiles

Role selection currently happens in the iOS registration interface because the backend user schema does not contain a creator/brand role field.

The current onboarding behavior is:

| Selected role | After registration | Persistence |
| --- | --- | --- |
| Creator | Opens a creator profile form for display name, biography, content focus, collaboration availability, social accounts, contact methods, and visibility preferences | Core profile fields are sent to `PATCH /api/v1/users/me/profile`; richer workshop fields remain local until the Workshop API is wired |
| Brand | Enters the brand workspace directly | The backend exposes Brand create/update/member APIs, but brand profile creation is not yet part of iOS registration |

Creator profile completion can be skipped and resumed from Account. Demo users skip profile onboarding entirely.

The intended next onboarding step for brands is to create or join a backend Brand after account registration, then collect the brand name, description, website, and logo. This is supported by the backend contract but is not yet implemented in the app.

## Injective Commercial Flow

The production API includes a real commercial-task lifecycle backed by the Injective service. This capability is specific to commercial tasks; ordinary inspirations and projects are not automatically written on-chain.

### Available Backend Operations

| Stage | Endpoint | Chain-visible result |
| --- | --- | --- |
| Create and fund task | `POST /api/v1/commercial-tasks` | Creates a task with a project, budget, deadline, and participant splits; records escrow funding |
| Submit work | `POST /api/v1/commercial-tasks/{task_id}/submissions` | Records an artifact ID, SHA-256 digest, and delivery URL |
| Authorize | `POST /api/v1/commercial-tasks/{task_id}/authorize` | Activates delivery authorization |
| Settle | `POST /api/v1/commercial-tasks/{task_id}/settle` | Releases settlement according to the configured splits |
| Read proof | `GET /api/v1/commercial-tasks/{task_id}/proof` | Returns the task, submissions, and chain transactions |

Chain transaction records may expose:

- action and status (`prepared`, `broadcast`, `confirmed`, or `failed`)
- network and chain ID
- transaction hash and explorer URL
- artifact SHA-256 digest
- amount and denomination
- submission and confirmation timestamps
- retryability and failure reason

### iOS Integration Status

The app currently exposes the Injective lifecycle in commercial brief and project UI, but does not yet call the commercial-task endpoints. Creating a brand brief creates a cloud project only; it does not claim that escrow has been funded or that a transaction has been confirmed.

A commercial task cannot be created safely until the app has collected a creator or participant identifier and valid split values totaling the intended allocation. Once a task ID is attached to a project, the project detail screen can replace its informational state with live transaction status, hashes, proof records, and explorer links.

## Production API Integration

The app currently integrates these backend surfaces:

- registration, login, logout, and current-session validation
- current-user profile read and update
- project create, list, read, update, and delete wrappers
- inspiration create, list, read, update, delete, and project-link wrappers
- persistent Agent conversations and messages
- transcription upload and polling wrappers

The production API also provides these surfaces, which are not fully represented in the current iOS UI:

- commercial task submission, authorization, settlement, and proof
- brand creation, membership, and invitations
- creator discovery, follows, interests, and creator inbox
- creator Workshop editing, preview, publishing, contacts, social accounts, project selection, and brand authorization
- user memory management
- streamed Agent responses over server-sent events

## Data and Trust Model

- Real bearer tokens are stored in Keychain.
- Projects, inspirations, PAWN history, role selection, and UI overlays retain a local `UserDefaults` cache for resilience and demo support.
- The app does not currently claim that all cached content is encrypted at rest.
- Remote mutations report success only after the backend confirms them.
- Failed inspiration uploads preserve a clearly marked local fallback.
- Original creative content is not automatically placed on-chain. Commercial proof uses artifact digests, authorization state, and settlement transactions.

## Smart Ring

The repository includes a native Swift RingSound client and a Python SDK reference under `RingSDK/`.

Current iOS behavior supports scanning, connection state, battery display, reconnecting to a saved device, and global capture triggers from double-tap or double-press events. The broader gesture vocabulary for recording, confirmation, cancellation, and privacy selection remains planned rather than presented as complete.

## Technology

| Layer | Technology |
| --- | --- |
| App UI | SwiftUI |
| Networking | URLSession, async/await, multipart upload |
| Authentication | Bearer sessions with Keychain token storage |
| Bluetooth | CoreBluetooth and the local RingSound client |
| Audio contract | Backend transcription jobs; full AVFoundation recorder wiring remains in progress |
| Graph visualization | Grape |
| AI collaboration | Persistent PAWN/Agent conversations |
| Commercial infrastructure | Injective-backed backend commercial-task API |

## Repository Guide

| Path | Purpose |
| --- | --- |
| `inspireFlow（升变）/` | SwiftUI application and API clients |
| `inspireFlow（升变）/RingSound/` | Native smart-ring transport and protocol implementation |
| `inspireFlow（升变）/RingSDK/` | Python ring SDK reference and protocol documentation |
| `BACKEND-HANDOFF.md` | Detailed frontend/backend product contract |
| `FRONTEND-HANDOFF.md` | Frontend implementation handoff |
| `TODO.md` | Product and interface backlog |
| `TODO-RING-SDK.md` | Ring integration backlog |

## Hackathon Scope

inspireFlow is an AdventureX 2026 hackathon project. The implementation favors a complete, demonstrable path through capture, PAWN collaboration, project creation, brand briefs, and production tools while keeping unfinished remote or on-chain operations visibly honest.

Tag: `adventurex2026`
