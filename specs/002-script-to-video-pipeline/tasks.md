---
description: "Task list for Script to Video Pipeline (Feature 002)"
---

# Tasks: Script to Video Pipeline

**Input**: Design documents from `specs/002-script-to-video-pipeline/`
**Prerequisites**: plan.md, spec.md, data-model.md

## Phase 1: Data Layer & Core Entities (Blocking)

**Purpose**: Establish the database schema and domain objects required to store scripts and shots.

- [ ] T001 Define `Scene` and `Shot` entities in `domain/entities/`
- [ ] T002 Define `SceneModel` and `ShotModel` DTOs in `data/models/`
- [ ] T003 Update `DatabaseHelper` to include `scenes` and `shots` tables
- [ ] T004 Create `IScriptRepository` and `ScriptRepositoryImpl` (CRUD for scripts/shots)

## Phase 2: User Story 1 - Script Import & Analysis (Priority: P1)

**Goal**: Allow users to import text and get structured shots back.

- [ ] T005 Implement `IAIScriptAnalysisService` and `GeminiScriptAnalysisService`
- [ ] T006 Create `ScriptImportDialog` widget
- [ ] T007 Create `ShotList` widget for the workspace sidebar/panel
- [ ] T008 Implement `ScriptAnalysisProvider` (Riverpod) to manage analysis state

## Phase 3: User Story 2 - Shot Visualization (Priority: P1)

**Goal**: Generate "First Frame" images from shot descriptions.

- [ ] T009 Update `ShotWorkspace` layout (Description, Characters, Asset Slots)
- [ ] T010 Implement `GenerateFirstFrame` logic in `ShotProvider`
- [ ] T011 Ensure `IGenerativeImageService` supports shot-based context
- [ ] T012 Update `AssetRepository` to link assets to `shotId`

## Phase 4: User Story 3 - Async Video Generation (Priority: P1)

**Goal**: Generate videos in the background using Veo.

- [ ] T013 Define `IVideoGenerationService` and `VeoService` implementation
- [ ] T014 Update `TaskQueueService` to support `VideoGenerationTask`
- [ ] T015 Implement `GenerateVideo` logic (triggering the task)
- [ ] T016 Add Video playback/preview component to `ShotWorkspace`

## Phase 5: Polish & Validation

- [ ] T017 Unit tests for `SimpleScriptParser` (fallback/mock analysis)
- [ ] T018 Integration test for `TaskQueue` with Video tasks
- [ ] T019 Error handling for API failures (Analysis/Generation)
