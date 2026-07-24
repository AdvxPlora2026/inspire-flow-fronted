
# inspireFlow Hackathon Execution TODO

> Goal: deliver one stable, repeatable story instead of 28 disconnected screens.
>
> Demo loop: ring intent -> voice capture -> three PAWN questions -> Bilibili production pack -> Injective commercial proof.

## Product UI Iteration TODO

> This is the regular product backlog after the first frontend MVP. Keep each primary view in its own Swift file and share only models, services, theme tokens, and small reusable components.
>
> Global design baseline: near-black background, white text, translucent glass cards, white primary buttons with black labels, system fonts, SF Symbols, 20pt horizontal content margins, and hierarchy built with monochrome contrast and opacity. Never rely on color alone for status. Respect Reduce Motion, Dynamic Type, VoiceOver, and keyboard operation throughout.

### Phase 0 - Welcome and app entry

- [X] **First-launch welcome (`StartView`)** - Keep the existing horizontally swipeable card experience as the welcome screen. It appears only before `hasCompletedOnboarding` is set, then routes to the custom login screen; normal launches must not interrupt the user with onboarding again.
- [ ] Refresh the three welcome cards to explain the current product loop: capture an inspiration, develop it with PAWN, and complete a creator or brand project.
- [ ] Restyle the welcome cards to the current monochrome visual system while retaining swipe gestures, page progress, Continue/Enter actions, VoiceOver page position, and Reduce Motion behavior.
- [ ] Add a reusable way to reopen the welcome guide from Help or Settings without changing first-launch completion state.

Acceptance: a clean install shows the swipeable welcome once, completion opens login, relaunch skips welcome, and replaying the guide from Settings does not sign the user out or reset their data.

### Phase 1 - Core project and inspiration loop

- [X] **Project detail and progress** - Show project name, current stage, overall progress, recent activity, creative goal, and entry points for outline, storyboard, script, and teleprompter artifacts. Use 20pt horizontal margins, continuous-corner glass cards, system fonts, and SF Symbols; distinguish progress through white brightness, line style, icons, and text rather than colored badges.
- [X] **PAWN project collaboration** - Give each project an independent conversation context with a project summary card, message list, composer, attachment entry, stop-generation action, and regenerate action. PAWN messages use translucent white cards, user messages use white cards with black text, and the native-material composer supports lightweight streaming output that respects Reduce Motion.
- [ ] **Inspiration recording and live transcription** - Show recording state, monospaced duration, live transcript, pause, resume, finish, and cancel actions, with clear microphone permission and local-save status. Use a prominent white recording control and restrained waveform that does not depend on color to communicate state; provide complete VoiceOver labels and announcements.
- [ ] **Inspiration detail** - Show original text, recording, transcript, creation time, privacy state, AI summary, tags, and associated project. Support edit, delete, and move-to-project; use grouped glass cards and a white primary action, with deletion communicated by text, icon, and confirmation rather than red alone.
- [ ] **Assign inspiration to project** - Let users search and select an existing project, create a project, or leave the inspiration unassigned, with recent and recommended projects. Use native search, a single-choice list, and fixed bottom confirmation; selection uses a white surface, black text, and checkmark while unselected rows remain translucent.
- [ ] Define first-class persisted models for projects, inspirations, recordings, conversations, messages, artifacts, activities, attachments, and commercial brief fields instead of encoding structured values in free text.
- [ ] Connect creator and brand views to the same project lifecycle and persisted IDs.
- [X] **Post-registration creator profile setup** - After a creator's first successful registration, collect display name, biography, social-platform account names, contact methods, creative categories, and collaboration availability. Let the creator explicitly control public workshop visibility and brand-only contact disclosure per field; support skip-and-complete-later without blocking personal creation.
- [ ] **Public creator workshop** - Let creators intentionally publish selected profile fields, project summaries, capabilities, availability, and chosen artifacts for brand discovery. Private inspirations, recordings, PAWN conversations, drafts, and contact details remain private by default, with preview and confirmation before publishing or revoking public data.
- [ ] **Brand interest and one-way follow** - Let brands follow or express project interest from public creator profiles. Add a visible toolbar information/notification button on creator surfaces, not a primary tab, showing which brands followed and their stated intent. Authorized brands may view creator-provided contact methods; creators can see brand identity and intent but cannot obtain brand contact details through this feature.

Acceptance: a user can capture or type an inspiration, assign it to one project, continue the matching PAWN conversation, and reopen the same project and content after relaunch.

### Phase 2 - Creation and production tools

- [ ] **Outline editor** - Edit chapters, paragraph order, chapter goals, and PAWN suggestions; support add, delete, collapse, drag-to-reorder, accept suggestion, and undo. Use monochrome glass cards and native editing controls, keep drag feedback direct and interruptible, and provide undo for destructive frequent edits.
- [ ] **Storyboard editor** - Present shot cards with number, visual description, dialogue or sound, suggested duration, and filming notes. Support add, duplicate, reorder, and list/compact view switching; use SF Symbols and monospaced shot numbers and durations, with shape, icon, and brightness jointly communicating state.
- [ ] **Script and teleprompter editor** - Provide structured narration, dialogue, visual cue, and sound-effect editing, plus font size, paragraph spacing, version switching, and teleprompter entry. Keep the editing surface visually quiet, place tools near affected content, and fully support Dynamic Type and keyboard operation.
- [ ] **Version history** - List outline, storyboard, and script versions with generation source, modification time, and summary. Support difference preview, restore, and duplicate; express differences through weight, strikethrough, icons, and brightness, confirm restoration, and preserve undo.
- [ ] **Shooting checklist** - Group shots, equipment, props, people, and completion by scene or shooting day. Support check-off, filtering, sorting, and offline access; show completed state with both icon and text, and use only quick press feedback and lightweight haptics for frequent changes.
- [ ] **Teleprompter** - Provide full-screen prompting, play/pause, scroll speed, font size, line spacing, mirror mode, and quick location. Use pure black with high-contrast white text and a low-distraction material control bar; scrolling must remain smooth and readable with Reduce Motion enabled.
- [ ] **Media import and attachments** - Import from Photos, Files, Camera, and recording, then show progress, type, size, linked location, rename, and delete. Prefer `PhotosUI`, `fileImporter`, and other Apple APIs; communicate loading, failure, and completion through icon, text, and progress.
- [ ] **Publishing preview and export** - Preview title, description, cover copy, tags, chapters, subtitles, and platform checklist in one place. Support copy, share, export, and return-to-edit with large content previews and a fixed primary action area; use `ShareLink` where suitable and state included content and format before export.

Acceptance: generated artifacts can be edited, versioned, used during filming, exported, and restored after app relaunch without losing project context.

### Phase 3 - Devices, permissions, and account

- [ ] **Bluetooth ring pairing** - Implement device search, ring identification, pairing confirmation, connection progress, success, not-found, and disconnected retry states with SwiftUI and CoreBluetooth. Keep animation restrained and Reduce Motion aware; persist the CoreBluetooth peripheral UUID rather than a MAC address.
- [ ] **Headphone management** - Show the current audio input/output route, connection state, available capabilities, microphone test, and switching or Settings entry, including no-device and failure states. Use native audio APIs and never fabricate battery or capabilities the system does not expose.
- [ ] **Ring device management** - Show paired ring, connection, battery when available, firmware, gesture settings, find-device, reconnect, and unpair. Confirm unpairing, keep live transitions lightweight, and announce material state changes through VoiceOver.
- [ ] **Ring gesture settings** - Map single, double, and triple press to capture, confirm, pause, or custom actions, with an interaction demo and conflict warning. Use native lists and menus, provide immediate feedback, and support restore defaults.
- [ ] **Notification settings** - Manage creation reminders, PAWN replies, device disconnects, shooting plans, and project progress. Show system permission state and a Settings deep link; use native grouped toggles with a white tint and neutral, non-coercive permission copy.
- [ ] **Privacy and permissions** - Show microphone, Bluetooth, Photos, Files, notifications, and local-network permission states plus local encryption, project context, content authorization, and data deletion. Request permissions only at the point of need and use confirmations for dangerous operations.
- [ ] **Profile** - Show avatar, name, creator biography, project and inspiration statistics, account state, and edit entry, with a reserved location for future account sync. Use a circular avatar, translucent cards, and monospaced statistics without decorative achievement animation.
- [ ] **General settings** - Add appearance, language, text size, haptics, default content type, default creation goal, storage/cache, Help, and About using native `Form` or `List` behavior and concrete labels.

Acceptance: device and permission states come from real system APIs, recover from denial or disconnect, remain usable with accessibility settings, and never claim unavailable hardware information.

### Phase 4 - Global navigation and reusable states

- [ ] **Search and filters** - Search across inspirations, projects, conversations, and artifacts, filtered by type, time, status, and privacy. Use `searchable`, native filter menus, and grouped results; emphasize matches through weight and brightness and avoid entry animations that slow repeated search.
- [ ] **Activity and notification center** - Group PAWN completion, project updates, device states, collaborator actions, and confirmations by time. Support read state, filters, and direct navigation into the corresponding context while preserving a consistent navigation path.
- [ ] **Empty-state specification** - Create distinct states for no inspirations, projects, messages, media, and search results. Each uses an SF Symbol, short title, supporting copy, and one white primary action without large illustrations or looping animation.
- [ ] **Loading and generation specification** - Cover initial and paginated loading, PAWN generation, file import, and device connection with low-contrast skeletons, `ProgressView`, explicit status text, and cancel or retry. No indefinite unexplained waiting.
- [ ] **Error and offline specification** - Cover offline, unavailable service, generation failure, storage failure, and corrupt content with a specific cause, impact, retry, and back action. Preserve unsubmitted input and do not rely on red to communicate severity.
- [ ] **Permission-denied specification** - Provide separate microphone, Bluetooth, Photos, Files, and notification denial states that explain the affected feature and offer System Settings or Not Now without repeatedly pressuring the user.
- [ ] **Device disconnect and reconnect specification** - Show a non-blocking banner or compact card with last connection, automatic reconnect progress, manual retry, cancel, and switch-device entry. Use icon, text, and optional haptics with restrained animation.
- [ ] Build shared state components only after at least two concrete screens need the same behavior; keep feature views in separate files.

Acceptance: every primary workflow has actionable empty, loading, error, permission-denied, offline, and reconnect behavior, and deep links return users to the correct role and project context.

### Recommended iteration order

1. Project detail and persisted domain models.
2. Inspiration recording, transcription, detail, and assignment.
3. Per-project PAWN collaboration.
4. Outline, storyboard, script, and version history.
5. Teleprompter, shooting checklist, attachments, and export.
6. Ring pairing, ring management, gestures, and audio routing.
7. Permissions, settings, profile, search, and activity center.
8. Reusable empty/loading/error/offline/disconnect states and full accessibility pass.

## P0 - Must Work On Stage

### 1. Capture and PAWN loop

- [X] Start and stop capture from the iOS demo.
- [X] Complete a deterministic three-question PAWN interview.
- [X] Show a structured Bilibili result: title, hook, outline, and shot list.
- [X] Keep the demo usable without network access.
- [ ] Replace simulated answers with speech transcription from the selected audio input.
- [ ] Save one capture session and its answers under a persistent project ID.
- [ ] Add a 10-second timeout and a visible retry path for every remote request.

Acceptance: a judge can complete the flow twice in a row without restarting the app.

### 2. Zilo ring

- [X] Repair the local Python event demo import and connection lifecycle.
- [X] Confirm the compatible Swift package and public API from `AdvxPlora2026/zilo-whisper-ring-sdk` v2.0.0.
- [X] Add the iOS Bluetooth usage description.
- [X] Add the `RingSound` Swift package to Xcode after package resolution is available.
- [X] Scan by NUS service and persist the CoreBluetooth peripheral UUID, not a MAC address.
- [~] Map key double press to capture, rotate front to confirm, rotate back to cancel, and wave to privacy. (key double press + double tap wired to capture; rotate/wave gestures not yet mapped)
- [X] Show disconnect state and one-tap reconnect without blocking the current draft.

Acceptance: at least one physical ring event visibly advances the same business flow shown in the app.

### 3. Voice-first interaction

- [ ] Record one real utterance through the current system input or viaim route.
- [ ] Return each PAWN question through private audio output.
- [ ] Keep each spoken response under 12 seconds and allow repeat/cancel.
- [ ] Log the selected audio route for debugging without claiming unavailable battery/capability data.

Acceptance: the main task can be completed without touching the phone after the initial screen is open.

### 4. Backend and PAWN generation

- [ ] Implement the API contract in `BACKEND-HANDOFF.md`.
- [ ] Persist project, capture, conversation, and generated artifact IDs.
- [ ] Return exactly one question per turn until `ready_to_generate=true`.
- [ ] Produce schema-valid Bilibili artifacts; reject unstructured model output.
- [ ] Support idempotency keys so retries never create duplicate captures or answers.

Acceptance: the same project remains coherent across voice capture, PAWN questions, and in-app revisions.

### 5. Injective commercial proof

- [ ] Create one fixed commercial brief with budget, deadline, deliverable, and split.
- [ ] Complete one real Injective testnet transaction: escrow preferred, split settlement acceptable.
- [ ] Store network, transaction hash, explorer URL, status, amount, and participant addresses.
- [ ] Bind submission to a specific artifact version hash.
- [ ] Open the real explorer URL from the app.
- [ ] Never put raw audio, scripts, private conversation turns, personal data, or access tokens on-chain.

Acceptance: the judge can independently open and verify the transaction.

## P1 - Makes The Demo Convincing

- [ ] Project detail page with stage, progress, latest capture, and artifact shortcuts.
- [ ] Commercial task states: funded, accepted, submitted, approved, settled, failed.
- [ ] Teleprompter with play/pause, next/repeat, speed, font size, and mirror mode.
- [ ] Ring gesture controls for next, repeat, and pause in teleprompter mode.
- [ ] Local encrypted file storage with Keychain-held key and protected-file attributes.
- [ ] Export/share the Bilibili title, description, chapters, and shot list.
- [ ] Demo reset action that clears local sample state but never sends destructive chain operations.
- [ ] A visible "Demo fallback" label when simulated hardware or backend responses are used.

## P2 - After The Hackathon

- [ ] Full outline, storyboard, script, version history, and shooting-list editors.
- [ ] Cross-project search, attachment management, notifications, and activity center.
- [ ] Creator profile inference and preference controls.
- [ ] Multi-collaborator project management and milestone escrow.
- [ ] Bilibili publishing connector and analytics.
- [ ] Apple Health and other connector experiments.

## Explicitly Out Of Scope

- Every idea or edit on-chain.
- NFT or token economy.
- Automatic legal copyright claims from a content hash.
- A complete creator marketplace.
- 28 polished screens before the core loop works.
- Custom IMU gesture training during the hackathon.

## Final Demo Checklist

- [ ] Physical ring charged above 30%; backup ring available if possible.
- [ ] viaim/system audio route tested in the venue.
- [ ] Backend health check is green and fallback fixture is bundled.
- [ ] Injective wallet funded on testnet; explorer URL opens on venue network.
- [ ] Screen recording prepared as backup.
- [ ] Demo data reset and all secrets excluded from Git.
- [ ] Run `xcodebuild` and the backend contract tests before submission.

### 额外想法

- [ ] 小组件适配，随时随地唤起？（可能无法实现
- [ ] 上链相关准备
- [ ]
