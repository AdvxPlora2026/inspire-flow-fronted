# inspireFlow Frontend Handoff

## 1. Purpose and ownership

This document is the living integration reference for the inspireFlow iOS frontend. Update it whenever frontend navigation, persisted state, permissions, API protocols, fixtures, device behavior, or chain-facing presentation changes.

Current ownership boundary:

| Area | Frontend ownership | Teammate or external ownership |
| --- | --- | --- |
| iOS UI and navigation | SwiftUI screens, role routing, local interaction state, accessibility | None |
| Authentication | Custom login and registration UI, session states, validation and error presentation | Account API, credentials, tokens, refresh and revocation |
| PAWN | Conversation UI, recording/transcript presentation, streaming/loading/error controls | Context storage, orchestration, generation jobs and artifact validation |
| Ring | Pairing and device-state UI, CoreBluetooth lifecycle on iOS | Ring protocol and SDK behavior not exposed through the agreed iOS contract |
| Audio | Permission UI, recording controls and available iOS audio-route presentation | External hardware capability claims not exposed by Apple APIs |
| Injective | Commercial state, authorization preview, transaction progress, failure and explorer link presentation | Wallet custody, transaction creation, broadcast, confirmation and canonical chain record |

The frontend must never imply that a backend, device, or chain operation succeeded when it is running from a local fixture.

## 2. Current application flow

```text
Clean install
  -> StartView swipeable welcome
  -> custom LoginView
  -> CreatorMainView or ClientMainView

Returning authenticated launch
  -> CreatorMainView or ClientMainView
```

`hasCompletedOnboarding` is stored with `@AppStorage`. Completing onboarding is independent from authentication. Replaying the welcome guide in a future Settings screen must not modify onboarding completion, authentication, or project data.

`AppSession` currently persists a demo authentication flag, role, and display name in `UserDefaults`. Login derives the display name from the email prefix. This is frontend-only demo behavior and is not a security boundary.

Creator registration now sets `needsCreatorProfileSetup` and routes to `CreatorProfileSetupView` before the creator tabs. The creator may save or choose "稍后完善"; both actions preserve authentication. Existing sign-in does not force this registration-only step. The Account screen can reopen the same editor without changing onboarding state.

## 3. Current navigation

Creator tabs:

| Tab | Root view | Current purpose |
| --- | --- | --- |
| Home | `CreatorHomeView` | Capture entry, current work and quick actions |
| Projects | `CreatorProjectsView` | Persisted personal and commercial projects |
| PAWN | `PawnWorkspaceView` | Existing PAWN demonstration workspace |
| Account | `AccountView` | Local account, role switch and logout |

Creator project navigation now uses the persisted `CreatorProject.id`. Both the Home current-work card and rows in `CreatorProjectsView` open `ProjectDetailView(projectID:)`, which resolves the latest project value from `AppStore`. The detail screen exposes the existing lifecycle action, creative goal, current-stage activity, PAWN workspace, and artifact entry points. Artifact destinations are actionable local empty states only; they do not represent generated or persisted artifact records.

Brand/client tabs:

| Tab | Root view | Current purpose |
| --- | --- | --- |
| Workspace | `ClientHomeView` | Commercial overview and attention states |
| Briefs | `ClientBriefsView` | Commercial projects and brief creation |
| Messages | `ClientMessagesView` | Static MVP message content |
| Account | `AccountView` | Local account, role switch and logout |

The creator's future brand-interest inbox must be opened from a visible toolbar information or notification button. It must not become another primary tab.

## 4. Current local data

`AppStore` stores `[CreatorProject]` as JSON under `creatorProjects.v1` in `UserDefaults`.

`AppStore` also stores `[PawnConversation]` as JSON under `pawnConversations.v1`. Each conversation has its own opaque ID and persisted `projectID`, structured creator/PAWN messages, completion state, update time, and imported attachment metadata. `ProjectPawnWorkspaceView` resolves the matching conversation by project ID, so messages remain isolated between projects and survive relaunch.

The current PAWN response is a deterministic local demonstration streamed in short text segments. Stop and regenerate mutate the same local conversation; they do not call or imply success from a PAWN backend. Reduce Motion bypasses segmented presentation and writes the complete response immediately. File import uses `fileImporter`, but the current model stores only the selected file's display name and import time. It does not copy, upload, bookmark, or retain access to the selected file contents.

Current `CreatorProject` fields:

| Field | Type | Notes |
| --- | --- | --- |
| `id` | `UUID` | Local identifier |
| `name` | `String` | Project name |
| `initialIdea` | `String` | Currently also carries some unstructured commercial details; this must be migrated to structured fields |
| `kind` | `personal` or `commercial` | Shared by both roles |
| `stage` | `brief`, `creating`, `review`, `approved`, `settled` | Linear local demo progression |
| `createdAt` | `Date` | Local creation time |

Missing first-class frontend models include:

- Public workshop entry and published artifact reference.
- Brand profile summary, one-way follow or interest event, and creator contact authorization.
- Inspiration, recording, transcript, privacy level and project assignment.
- Generation job, artifact and artifact version. Project conversations, messages, and attachment metadata now have local first-class models, but backend IDs and attachment file persistence are not implemented.
- Activity, attachment, commercial brief, submission, authorization and transaction record.

Persisted model migrations must be explicit and must preserve existing `creatorProjects.v1` data.

`AppSession` stores `CreatorProfile` JSON under `session.creatorProfile.v1` and the pending setup route under `session.needsCreatorProfileSetup`. The profile contains structured `ProfileValue`, social-account and contact-method records. Each record carries one of `privateOnly`, `workshopPublic`, `brandsOnly`, or `authorizedBrands`; defaults are private. These values currently express local user intent only and do not publish or authorize any backend disclosure.

## 5. Creator profile and workshop privacy contract

Profile completion and publication are separate actions. Completing a profile must not make it public.

Recommended visibility values:

```text
private
workshop_public
brands_only
authorized_brands
```

Each social account and contact method needs its own visibility or disclosure rule. Contact data must not be placed in public workshop responses by default.

The public workshop may expose only creator-approved data such as:

- Display name, biography, creative categories and collaboration availability.
- Selected social account names or public profile URLs.
- Selected project summaries, capabilities and published artifacts.

The public workshop must not expose by default:

- Private inspirations, recordings, full transcripts or PAWN conversation turns.
- Draft scripts, private artifacts or unpublished commercial work.
- Phone numbers, email addresses, messaging IDs or other contact methods.
- Authentication, wallet, device or permission state.

One-way brand interest behavior:

1. A brand views a creator's public workshop profile.
2. A brand follows or expresses interest with an optional intent or project reference.
3. The creator sees the brand identity, time, intent and related project through the toolbar inbox.
4. If the creator has authorized brand contact disclosure, the brand may receive the approved creator contact fields.
5. The creator does not receive the brand's contact fields through this feature.
6. Revocation stops future disclosure. Backend requirements must define whether already disclosed data can be recalled; the UI must not promise recall unless the backend can enforce it.

## 6. Backend contract required by the frontend

The existing PAWN and Injective proposal is documented in `BACKEND-HANDOFF.md`. The frontend additionally needs these contract groups before replacing local fixtures:

### Account and session

- Register, sign in, refresh session, sign out and delete account.
- Return stable opaque user ID, role, profile-completion state and token expiry.
- Return structured validation and retryable error information.

### Creator profile

- Read and update private creator profile.
- Read and update social accounts and contact methods independently.
- Read and update per-field visibility and brand-contact authorization.
- Return profile-completion requirements without forcing publication.

### Public workshop and discovery

- Publish, preview, update and revoke a creator workshop profile.
- List discoverable creators for brands with pagination and filters.
- Read a public creator profile with only fields authorized for the requesting audience.
- Publish or revoke individual project summaries and artifact references.

### Brand follow and interest

- Create and revoke a one-way follow or interest event idempotently.
- List creator-facing interest events with brand identity, intent, project reference, timestamp and read state.
- Mark events read without deleting them.
- Resolve creator contact fields server-side from current authorization. Never trust a client-provided visibility claim.

All mutating requests should support idempotency. Paginated lists need stable cursors. Errors should retain the existing `{ error: { code, message, retryable, request_id, details } }` envelope.

## 7. PAWN and commercial integration

Use opaque backend IDs for user, project, capture, conversation, artifact, commercial task and transaction records. Keep local plaintext and chain data separated according to `BACKEND-HANDOFF.md`.

Commercial UI must distinguish at least:

```text
brief -> creating -> review -> approved -> settled
```

Future backend states such as funded, accepted, submitted, failed and authorization changes must be represented explicitly rather than inferred from button taps.

The frontend must use the explorer URL returned by the backend and must not construct one from a transaction hash. A transaction is not confirmed until the backend reports network confirmation.

## 8. Fixtures and offline behavior

Until APIs are available, frontend fixtures must be visibly identified in developer/demo builds and must use the same protocols and data shapes expected from production services.

Required presentation states for each remote workflow:

- Initial, loading and paginated loading.
- Empty with one useful next action.
- Success and updated content.
- Retryable and non-retryable failure.
- Offline with preservation of unsubmitted input.
- Unauthorized or expired session.
- Permission denied where a system capability is involved.

Fixture actions must not claim that a brand was contacted, private data was disclosed, or a chain transaction was broadcast.

## 9. Permissions and platform capabilities

Request microphone, Bluetooth, Photos, Files, notifications and local-network access only when the related action is initiated. Each denial state must offer a clear consequence, System Settings when useful, and a Not Now path.

Do not expose unsupported battery, firmware, headphone, ring or audio-route values. Unknown and unavailable are valid explicit states.

## 10. Frontend validation checklist

For every integration-facing feature:

- Build the `inspireFlow` scheme.
- Exercise creator and brand routing separately.
- Test a clean install and returning launch when entry flow changes.
- Verify persistence and migration behavior when models change.
- Exercise empty, loading, error, offline and expired-session states.
- Inspect Dynamic Type, VoiceOver labels and Reduce Motion behavior.
- Confirm no private or contact data appears in logs, public fixtures, chain payloads or screenshots unintentionally.
- Record validation and limitations in a dated file under `log/`.

## 11. Known current limitations

- Authentication and role switching are local demo behavior.
- Projects use a small `UserDefaults` model without migration support.
- PAWN capture and messages are demonstration flows rather than backend-owned project conversations.
- Client messages are static.
- Creator profile setup is local-only; account-scoped sync, public workshop publication, brand discovery, follow/interest and server-enforced contact authorization are not implemented.
- Ring, audio, permission and Injective production integrations are not complete.
