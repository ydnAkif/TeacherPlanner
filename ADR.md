# ADR 001 — Widget Cache, DI Composition, Test Strategy Alignment

## Status
Proposed

## Context
The TeacherPlanner project currently has several foundational initiatives in progress:
1. Widget targets are partially implemented but rely on empty files and lack a consistent data strategy.
2. Services are often instantiated directly inside ViewModels, making mocking & testing harder.
3. Tests exist but are sparse; there’s no shared test strategy document.

We need a single source of truth that explains how the caches, DI containers, and testing approach should work going forward.

## Decision

### 1. Widget Cache
- Widget timelines will avoid hitting SwiftData on every refresh. A shared `WidgetAppGroupCache` writes a small JSON summary (`WidgetCachedSummary`) into the App Group container so both the main app and widget extensions can read it.
- The cache service is a thin wrapper around `FileManager`, exposing `readSummary()` and `writeSummary(_:)`.
- The widget uses `WidgetSampleData` helpers for placeholder previews and falls back to cached values if SwiftData fetch fails.

### 2. Dependency Injection Composition
- A new `AppEnvironment` (once implemented) acts as the DI container, wiring:
  - Protocols like `WidgetScheduleProviding`, `SchoolDayCalculating`, `NotificationScheduling`.
  - Shared `ModelContext` providers.
  - Widget cache and notification manager singletons.
- ViewModels receive their dependencies via initializer injection. Concrete services implement lightweight protocols so we can supply fakes during tests.
- Widget extensions use the same protocols (via shared module) to avoid duplicating logic.

### 3. Test Strategy
- Tests are grouped by layer:
  - **Unit**: SwiftData-backed services and ViewModel logic. Each ViewModel should have tests covering success, empty, and error states.
  - **Integration**: SwiftData fetch flows, cache reading/writing, notification scheduling.
  - **UI**: Critical user journeys (Today view, Planner item completion, adding sessions).
- Use `ModelContainerFactory.createPreview()` so each test gets an in-memory context. Inject mock implementations of protocols in place of real services.
- Maintain a living test checklist inside `TODO.md` and keep the README summary in sync.

## Consequences
- Widgets no longer rely on empty placeholder files; they read from a deterministic cache.
- Injecting dependencies makes ViewModels easier to test and enables future features (e.g., analytics).
- Having a documented test plan reduces regressions and clarifies coverage goals.
