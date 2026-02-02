---
description: "Task list for Enterprise AI Animator Workbench v2.0"
---

# Tasks: Enterprise AI Animator Workbench v2.0

**Input**: Design documents from `specs/001-animator-workbench-v2/`
**Prerequisites**: plan.md, spec.md

## Phase 1: Setup (Shared Infrastructure)

- [ ] T001 Create feature directory structure (`lib/features/animator_workbench/{data,domain,presentation}`)
- [ ] T002 Add dependencies to `pubspec.yaml` (`flutter_riverpod`, `dio`, `sqflite`, `path_provider`, `uuid`, `equatable`)
- [ ] T003 [P] Configure `analysis_options.yaml` for strict linting

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure for Clean Architecture and Local-First Data.

- [ ] T004 Define Domain Entities in `domain/entities/` (`asset.dart`, `task.dart`, `project.dart`)
- [ ] T005 Define Repository Interfaces in `domain/repositories/` (`i_asset_repository.dart`, `i_task_repository.dart`)
- [ ] T006 Define Service Interface in `domain/services/` (`i_generative_image_service.dart`)
- [ ] T007 Implement SQLite Database setup in `data/datasources/local/database_helper.dart`
- [ ] T008 [P] Setup Dependency Injection / Riverpod Providers in `presentation/providers/`

## Phase 3: User Story 1 - Asynchronous Background Refinement (Priority: P1)

**Goal**: Queue complex image refinement tasks asynchronously without blocking UI.

- [ ] T009 [US1] Implement `TaskModel` DTO in `data/models/task_model.dart`
- [ ] T010 [US1] Implement `TaskRepositoryImpl` in `data/repositories/task_repository_impl.dart`
- [ ] T011 [US1] Implement `TaskQueueService` logic in `data/services/task_queue_service.dart`
- [ ] T012 [US1] Create `TaskStatusIndicator` widget in `presentation/widgets/task_status_indicator.dart`
- [ ] T013 [US1] Create `PlaceholderCard` widget in `presentation/widgets/placeholder_card.dart`
- [ ] T014 [US1] Integrate Task Queue with Riverpod in `presentation/providers/task_queue_provider.dart`

## Phase 4: User Story 2 - Asset Lineage & Version Control (Priority: P2)

**Goal**: Track relationship between original and refined images.

- [ ] T015 [US2] Implement `AssetModel` DTO in `data/models/asset_model.dart` (with `parentId`, `pipelineInfo`)
- [ ] T016 [US2] Implement `AssetRepositoryImpl` in `data/repositories/asset_repository_impl.dart` (FileSystem + SQLite)
- [ ] T017 [US2] Create `AssetDetailsPage` in `presentation/pages/asset_details_page.dart`
- [ ] T018 [US2] Update `AssetList` widget to display lineage info

## Phase 5: User Story 3 - Character Consistency Workflow (Priority: P1)

**Goal**: Master Reference system for character consistency.

- [ ] T019 [US3] Update `Asset` entity/model to support "Master Reference" flag
- [ ] T020 [US3] Implement Mock/Real `GenerativeImageService` adapter in `data/datasources/remote/`
- [ ] T021 [US3] Create `RefinementPanel` widget in `presentation/widgets/refinement_panel.dart`
- [ ] T022 [US3] Connect Refinement UI to Task Queue (triggering the service)

## Phase 6: Polish & Validation

- [ ] T023 Implement Error Handling & Retry logic in `TaskQueueService`
- [ ] T024 Verify Task Persistence (Restart App Test)
- [ ] T025 Update Documentation
