# inspire-flow-fronted

> Ambient AI production assistant for Bilibili creators — capture without a screen, create with context, get paid with certainty.

**inspireFlow** turns spontaneous ideas into publishable video projects through wearables. Trigger capture with a smart ring, speak through earphones, and let PAWN — your always-on AI producer — handle the rest.

---

## What It Does

### 🎙️ Screenless Idea Capture

Capture inspiration the moment it strikes — while walking, filming, or in the middle of a conversation — without ever pulling out your phone.

- **Ring gesture → capture intent**: double-tap to start, long-press for continuous expression, rotate to confirm or dismiss
- **Earphone capture**: speak your idea naturally; PAWN listens and asks follow-up questions through private audio feedback
- **At least three rounds of context-building**: PAWN determines whether the idea is clear enough, then prompts you for target audience, format, privacy level, and project association

### 🧠 Context-Aware AI Producer (PAWN)

PAWN doesn't just transcribe — it produces.

- Associates every idea with an existing project or creates a new one
- Generates **Bilibili-ready deliverables**: title candidates, three-second hooks, outlines, storyboards, shot lists, script copy, teleprompter drafts, cover copy, chapters, and comment prompts
- Maintains independent conversation context per project
- Surfaces revision suggestions on outlines, storyboards, and scripts
- Supports streaming output with lightweight animations that respect Reduce Motion

### 💬 iMessage Collaboration

All PAWN-generated results are delivered to real iMessage via Photon. Reply directly in Messages to refine content — PAWN keeps the same task context across sessions.

### 📹 Teleprompter & On-Set Control

When it's time to shoot, the ring becomes your teleprompter remote:

- **Next line / repeat / pause** — all controlled by ring gestures
- **Full-screen teleprompter** with pure black background, high-contrast white text, and adjustable speed, font size, and mirroring
- Scroll is smooth and respects Reduce Motion

### 📋 Production Pipeline

From idea to publishable output:

| Stage | What You Get |
|-------|-------------|
| Outline | Editable chapters, paragraph order, PAWN suggestions |
| Storyboard | Shot cards with scene description, dialogue, estimated duration, shooting tips |
| Script | Structured narration, dialogue, scene cues, sound effects |
| Shot List | Grouped by scene/day with equipment, props, crew, and completion tracking |
| Export | Title, description, cover copy, chapters, subtitles, platform checklist — preview, copy, share, or export |

### 🔒 Privacy & Ownership

- All content is **encrypted and stored locally**
- Content hashes and authorization status are written to **Injective testnet**
- Privacy levels adjustable per idea
- Permission requests trigger only when actually needed; no dark-pattern authorization prompts

### 🤝 Commercial Settlement (Injective)

For brand collaborations and multi-creator projects, PAWN uses Injective for:

- Budget escrow
- Authorization confirmation
- Automatic contributor revenue split

### 🎛️ Device Management

- **Smart ring**: pairing, connection status, battery, firmware, gesture configuration, find-my-ring
- **Earphones**: input/output device status, mic test, connection management
- **Offline states**: non-blocking disconnect banners with auto-reconnect, manual retry, and device switching

---

## Design Language

| Principle | Implementation |
|-----------|---------------|
| **Monochrome depth** | Near-black background, white text, translucent glass cards — all hierarchy expressed through opacity and brightness alone |
| **White-on-black primary actions** | Main buttons are white background / black text; destructive actions confirmed through text, icon, and dialog — never color alone |
| **System fonts & SF Symbols** | No custom typefaces; icons convey state alongside text |
| **Restrained motion** | All animations are lightweight and respect Reduce Motion; the teleprompter never animates during reading |
| **20pt horizontal margins** | Consistent spacing throughout |
| **Accessibility first** | VoiceOver announcements for device state changes, full Dynamic Type support, keyboard navigation, haptic feedback on frequent toggles |

---

## Screens (28 Modules)

| # | Module | Key Behavior |
|---|--------|-------------|
| 1 | Bluetooth Ring Pairing | Scan → identify → pair → connect → disconnect/retry |
| 2 | Project Detail & Progress | Glass cards, progress via brightness only, 20pt margins |
| 3 | PAWN Collaboration | Per-project chat context, AI white-card / user black-on-white |
| 4 | Voice Capture & Live Transcript | Monospace timer, restrained waveform, VoiceOver support |
| 5 | Inspiration Detail | Grouped cards, delete confirmed via dialog not color |
| 6 | Assign to Project | Native search, single-select, white-on-black selected state |
| 7 | Outline Editor | Drag-to-reorder, accept suggestions, undo destructive edits |
| 8 | Storyboard Editor | Shot cards with monospace numbering, list/compact views |
| 9 | Script & Teleprompter Editor | Structured editing, version switching, Dynamic Type |
| 10 | Version History | Timeline view, diff by weight/strikethrough/icon not color |
| 11 | Shot List | Compact cards, icon + text completion state, offline-ready |
| 12 | Teleprompter | Full-screen black, stable scroll, hidden chrome |
| 13 | Media Import & Attachments | PhotosUI / fileImporter, status via icon + text + progress |
| 14 | Publish Preview & Export | ShareLink, explicit content/format preview before export |
| 15 | Earphone Management | System audio routes, no fabricated device info |
| 16 | Ring Management | Connection, battery, firmware, unpair confirmation |
| 17 | Ring Gesture Settings | Single/double/triple-tap mapping, conflict warnings, restore defaults |
| 18 | Notification Settings | Native toggles, white accent, no coercive copy |
| 19 | Privacy & Permissions | All permission states, local encryption, data deletion with confirmation |
| 20 | Profile | Circular avatar, monospace stats, no vanity animations |
| 21 | General Settings | Appearance, language, haptics, storage; SwiftUI Form |
| 22 | Search & Filter | Cross-entity `.searchable`, match emphasis via font weight |
| 23 | Activity & Notification Center | Grouped cards, tap-to-navigate with consistent path |
| 24 | Empty States | SF Symbol + title + single white-on-black action per scenario |
| 25 | Loading & Generation | Skeleton screens, ProgressView, cancel/retry, Reduce Motion aware |
| 26 | Error & Offline | High-contrast cards, system icons, actionable copy, preserves unsent input |
| 27 | Permission Denied | Per-permission explanation, Settings deep-link, no pressure |
| 28 | Device Disconnect & Reconnect | Non-blocking banner, auto-reconnect, haptic + icon + text feedback |

Full specifications: [`TODO.md`](./TODO.md)

---

## Tech Stack

- **SwiftUI** — UI framework
- **CoreBluetooth** — ring connectivity
- **AVFoundation** — audio capture and playback
- **Injective** — on-chain content hashing and settlement
- **Bleak (Python)** — ring SDK utilities (`RingSDK/`)

---

## Project Structure

```
inspireFlow/
├── inspireFlowApp.swift         # App entry point with onboarding gating
├── ContentView.swift            # Main tab navigation
├── startPage.swift              # Onboarding flow
├── new.swift                    # New project creation
├── RingSDK/                     # Python-based ring communication SDK
│   ├── ring_sound.py
│   ├── pawn_demo.py
│   └── protocol.md
├── skills/                      # iOS design system skills (emilkowalski/skills)
├── Assets.xcassets/             # App icon and image assets
├── MVP.md                       # Product MVP definition
├── newIDEA.md                   # Full project vision document
├── Agent.md                     # Agent instructions
└── TODO.md                      # Interface implementation checklist
```

---

## Tag

`adventurex2026` — AdventureX 2026 hackathon submission.
