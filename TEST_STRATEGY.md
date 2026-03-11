# Test Strategy

## Objective
Provide a living plan that complements `ROADMAP.md` and the ADR. This document explains the phases, scopes, and coverage targets for unit, integration, and UI tests across TeacherPlanner.

---

## Phases

### Phase 0 — Stabilization (Current Sprint)
- **Goal:** Ensure foundational services and widgets have deterministic behavior.
- **Scope:**
  - Unit tests for `SchoolDayEngine`, `NextClassCalculator`, `WeeklyScheduleBuilder`.
  - Widget cache + `WidgetDataProvider` happy paths.
  - Validation that stubs/default data paths don’t crash.
- **Coverage target:** 15% overall.
- **Checklist:**
  - [ ] All existing unit tests run in CI (macOS + iOS).
  - [ ] `ModelContainerFactory.createPreview()` used in each test for isolation.
  - [ ] No forced unwraps in test utilities.

### Phase 1 — Core Feature Guardrails (1-2 weeks)
- **Goal:** Protect critical user flows via unit + integration tests.
- **Scope:**
  - TodayViewModel happy/failure/empty states.
  - Planner item CRUD logic + completion toggle.
  - Courses module: creation/editing validations.
  - Notification scheduling handshake (using protocol-driven mocks).
- **Coverage target:** 35% (unit).
- **Checklist:**
  - [ ] Protocol-based mocks for `WidgetScheduleProviding`, `SchoolDayCalculating`.
  - [ ] Integration test: SwiftData query + fetch descriptor patterns.
  - [ ] Edge cases covering empty semester, no classes, skipped days.

### Phase 2 — Platform & UI Confidence
- **Goal:** Prove user flows (Today, Planner, Weekly schedule) via UI tests.
- **Scope:**
  - Launch + onboarding workflow.
  - Add course → schedule → notification flow.
  - Planner item completion + filter.
  - Widget placeholder + timeline update (using WidgetKit test target).
- **Coverage target:** 45% total (unit + integration + UI).
- **Checklist:**
  - [ ] UI tests run on macOS, iOS simulators.
  - [ ] Widget extension provides predictable snapshot data.
  - [ ] Accessibility assertions (voiceover labels, Dynamic Type close).

### Phase 3 — Cloud & Advanced Scenarios
- **Goal:** Prepare for sync/backup features.
- **Scope:**
  - Offline/online data merge simulation.
  - Export/import JSON/ICS paths.
  - Notification permission denial + reset flows.
- **Coverage target:** 55%+.
- **Checklist:**
  - [ ] Mock CloudKit/backup provider.
  - [ ] Test suite verifies migration helpers.
  - [ ] Snapshot tests for advanced widgets.

---

## Testing Principles

1. **Use Protocols for DI** – tests depend on protocols, not concrete actors.
2. **Seed Data via Factories** – `SampleDataSeeder` only used for UI tests; units use small, focused data.
3. **Fail Fast** – every `try?` replaced with explicit `XCTFail` in tests to expose regressions.
4. **Parallelizable Suites** – categorize tests into `Fast`, `Integration`, `Widget`, `UI` to reduce CI time.
5. **Living Checklist** – keep `TODO.md` aligned with test coverage goals; update after each sprint.

---

## Coverage Goals

| Layer | Target | Key Metrics |
|-------|--------|-------------|
| Unit | 40% | Services + ViewModels + helpers |
| Integration | 15% | SwiftData fetch + cache + notification |
| UI | 15% | Critical flows (Today, Planner, Weekly) |
| Snapshot | 5% | Widgets + visual components |

> Overall target: **55% total coverage** before V1.0 release.

---