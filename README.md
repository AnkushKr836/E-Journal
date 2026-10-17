<div align="center">

# E-Journal

**A unified, modular personal operating system for daily logging and lifestyle management.**

[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Windows%20%7C%20Web-1e293b?style=flat-square)](https://github.com/AnkushKr836/E-Journal)
[![License](https://img.shields.io/badge/License-MIT-1e293b?style=flat-square)](LICENSE)
[![Status](https://img.shields.io/badge/Status-Architecture%20%26%20Design-1e293b?style=flat-square)]()
[![Documentation](https://img.shields.io/badge/Docs-PRD%20v1.0-1e293b?style=flat-square)](PRD.md)

<br />

> *"Your entire day, unscattered. One unified journal for everything you do, spend, eat, and plan."*

<br />

[Overview](#overview) &nbsp;&bull;&nbsp;
[Design Philosophy](#design-philosophy) &nbsp;&bull;&nbsp;
[Functional Dimensions](#functional-dimensions) &nbsp;&bull;&nbsp;
[Notification Architecture](#notification-architecture) &nbsp;&bull;&nbsp;
[Technical Specification](#technical-specification) &nbsp;&bull;&nbsp;
[Roadmap](#roadmap)

</div>

---

## Overview

Personal life management is currently fragmented across half a dozen single-purpose applications: task lists in one, grocery checklists in another, caloric intake in a third, and financial ledgers elsewhere. This fragmentation induces cognitive friction and subscription fatigue, and prevents meaningful cross-domain insights.

**E-Journal** consolidates day-to-day logging into a cohesive, high-performance platform. By combining a low-latency capture interface with a modular data architecture, it delivers a single source of truth across **Android** and **PC**, ensuring you spend less time administering your tools and more time executing your day.

---

## Design Philosophy

- **Sub-3-Second Capture** &mdash; Logging overhead must approach zero. Persistent widgets, global desktop keybindings, and rapid-entry modal dialogs guarantee frictionless logging.
- **Modular Isolation** &mdash; Every domain functions as an independent module. Activate only what you actively monitor; keep the interface austere and uncluttered.
- **Cross-Domain Context** &mdash; Data streams inform one another. Grocery lists integrate with meal plans; travel itineraries link to localized expense ledgers; chore schedules adapt around time-blocked tasks.
- **Local-First & Resilient** &mdash; Instantaneous read/write performance backed by local embedded storage. Full offline capabilities with conflict-free background synchronization.
- **Noise-Filtered Notification Protocol** &mdash; Replaces disjointed notification spam with structured morning and evening briefings, reserving audible alerts strictly for time-critical alarms.

---

## Functional Dimensions

E-Journal models daily life through eight interconnected functional modules:

| Dimension | Scope | Key Capabilities |
| :--- | :--- | :--- |
| **Agenda & Habits** | Execution & Consistency | Priority categorization (P1–P4), 24h timeline visualization, subtasks, recurring cadence, streak preservation. |
| **Domestic Maintenance** | Living Space Upkeep | Interval-driven maintenance (*"Wash linens every 10 days"*), audible cycle timers (laundry, cooking), room categorization. |
| **Provisioning & Pantry** | Inventory & Supplies | Categorized checklist (Produce, Dairy, Essentials), frequently purchased staples, real-time basket cost estimation. |
| **Capital & Finance** | Cashflow & Budgeting | Categorical income and expenditure logging, monthly expenditure limits, recurring billing reminders, visual breakdown. |
| **Nutrition & Fuel** | Dietary Monitoring | Daily caloric and macronutrient targets (P/C/F), water logging, rapid custom-entry presets, meal distribution. |
| **Expeditions & Travel** | Itinerary Coordination | Chronological day-by-day travel plans, linked trip expenditure sub-ledger, packing and logistics checklists. |
| **Academic & Focus** | Skill & Study Planning | Modular curriculum tracking, spaced revision scheduling, integrated Pomodoro sessions with automated time allocation. |
| **Milestones & Events** | Calendar Synchronization | Critical dates, appointment tracking, countdown timelines for upcoming milestones. |

---

## Notification Architecture

To respect attention and reduce notification burnout, alerts follow a tiered dispatch strategy:

```
[ Scheduled Briefings ] ──────────────────────────────────────────────┐
  08:00 AM  Morning Agenda    Top 3 Priorities · Macro Budget · Chores │ (Silent / Low Priority)
  09:30 PM  Evening Reflection  Daily Spend Audit · Uncompleted Tasks │
                                                                      │
[ Time-Critical Interrupts ] ─────────────────────────────────────────┤
  Dynamic   Foreground Alarms  Laundry Cycle (45m) · Timed Tasks      │ (Audible / High Priority)
```

- **Digest Notifications:** Consolidated summary cards delivered at defined anchors (Morning Briefing & Evening Wrap-up).
- **Exact Alarms:** Scheduled via native system alarms (`AlarmManager` on Android) to guarantee real-time delivery even when the device is under battery-saving or Doze constraints.

---

## Technical Specification

```
                                 ┌──────────────────────────────┐
                                 │       E-Journal Client       │
                                 ├──────────────┬───────────────┤
                                 │ Android App  │ PC (Web/Win)  │
                                 └──────┬───────┴───────┬───────┘
                                        │               │
                                ┌───────▼───────────────▼───────┐
                                │   Local-First Storage Engine  │
                                │   (SQLite / Embedded Cache)   │
                                └───────────────┬───────────────┘
                                                │ Delta Sync
                                ┌───────────────▼───────────────┐
                                │   Cloud Sync & Auth Engine    │
                                │   (PostgreSQL / Realtime DB)  │
                                └───────────────────────────────┘
```

| Layer | Selected Architecture | Considerations |
| :--- | :--- | :--- |
| **Mobile & Desktop** | **Flutter 3.x (Dart)** | Single codebase compiling natively to Android (`.apk`) and Windows Desktop (`.exe`). |
| **State Management** | **Riverpod** | Reactive, compile-safe dependency injection and state management. |
| **Local Data Engine** | **Drift (SQLite) / Isar DB** | Zero-latency local reads/writes, reactive UI updates, offline-first reliability. |
| **Cloud Sync & Auth** | **Supabase (`supabase_flutter`)** | Managed PostgreSQL, Row Level Security, Realtime sync, and OAuth/Magic Link Auth. |
| **Notification Pipeline** | `flutter_local_notifications` + FCM | Native `AlarmManager` on Android for exact timers; Windows system tray notifications. |

> Detailed technical requirements, user personas, and data schemas are documented in the [Product Requirements Document (PRD.md)](PRD.md).

---

## Roadmap

### Phase 1 &mdash; Core Platform & MVP *(In Progress)*
- [x] Architecture design, domain modeling, and technical PRD specification.
- [ ] Cross-platform client scaffold (Android mobile + PC responsive web).
- [ ] Core Module: Daily Tasks, Time-blocking & Habit Engine.
- [ ] Core Module: Household Chores & Exact-Time Cycle Alarms.
- [ ] Core Module: Provisioning & Smart Grocery Checklists.
- [ ] Basic Local Storage persistence and notification dispatch pipeline.

### Phase 2 &mdash; Financial Ledger & Dietary Tracking
- [ ] Core Module: Personal Budgeting, Subscriptions, and Monthly Caps.
- [ ] Core Module: Caloric Goals, Macro Allocation & Hydration Counter.
- [ ] Automated Morning Agenda & Evening Reflection engine.
- [ ] Encrypted cloud synchronization and multi-device identity.

### Phase 3 &mdash; Extended Life Modules & Platform Maturity
- [ ] Core Module: Travel & Expedition Itinerary Planner.
- [ ] Core Module: Academic Syllabus & Pomodoro Work Sessions.
- [ ] Native Android Home Screen Quick-Capture Widgets.
- [ ] Biometric app security (Fingerprint / Face Unlock).
- [ ] Data portability engine (Full JSON / CSV export and local backup).

---

## Development & Contribution

1. **Review Specification:** Consult [PRD.md](PRD.md) for architectural guidelines and domain constraints.
2. **Branching Model:** Follow trunk-based or feature-branch workflow:
   ```bash
   git checkout -b feature/module-name
   ```
3. **Commit Standards:** Keep commit messages imperative, concise, and scoped (e.g., `feat(chores): add interval timer calculation`).

---

## License

E-Journal is distributed under the terms of the [MIT License](LICENSE).