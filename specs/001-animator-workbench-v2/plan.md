# Implementation Plan: Enterprise AI Animator Workbench v2.0

**Branch**: `001-animator-workbench-v2` | **Date**: 2026-01-29 | **Spec**: [specs/001-animator-workbench-v2/spec.md](specs/001-animator-workbench-v2/spec.md)
**Input**: Feature specification from `specs/001-animator-workbench-v2/spec.md`

## Summary

The Enterprise AI Animator Workbench v2.0 aims to implement a "Hybrid Model Pipeline" that allows professional animators to queue complex image refinement tasks (Face Swap, Inpainting) asynchronously without blocking the UI. Key features include a persistent background task queue, asset lineage tracking (parent-child relationships), and a "Master Reference" system for character consistency. The system will prioritize local-first storage and use an adapter pattern for external AI services.

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.x
**Primary Dependencies**: 
- `flutter_riverpod` (State Management)
- `dio` (Network)
- `sqflite` (Local Metadata & Task Queue Persistence)
- `path_provider` (File System Access)
- `uuid` (Unique IDs)
- `equatable` (Value equality)
**Storage**: 
- **Binary Assets**: Local File System (organized by Project/AssetID)
- **Metadata/Lineage**: SQLite Database
**Testing**: `flutter_test`, `mockito`, `integration_test`
**Target Platform**: Windows / macOS (Desktop)
**Project Type**: Flutter Desktop Application
**Performance Goals**: 
- Zero UI freeze during heavy I/O or network requests.
- Support for large image files (4k+).
**Constraints**: 
- Offline-first capability (queue tasks if offline, though execution requires net).
- Strict separation of concerns (Clean Architecture).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] **Layered Architecture**: Design strictly separates Presentation, Domain, and Data layers.
- [x] **State Management**: Uses Riverpod for decoupled state management.
- [x] **Repository Pattern**: Data access (SQLite, FileSystem, API) abstracted behind repositories.
- [x] **Component Design**: UI broken down into `AssetCard`, `TaskStatusIndicator`, `RefinementPanel`.
- [x] **Testing Strategy**: Includes Unit (Domain/Data), Widget (Components), and Integration (Flows).
- [x] **Local-First Authority**: File system is SSOT for assets; SQLite for relationships.
- [x] **Extensible API Adapters**: AI services (Face Swap) accessed via `IGenerativeImageService` interface.
- [x] **Asynchronous Command Queue**: Dedicated `TaskQueueService` handles background operations.

## Project Structure

### Documentation (this feature)

```text
specs/001-animator-workbench-v2/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
│   └── ai_service_api.yaml
└── tasks.md             # Phase 2 output
```

### Source Code (repository root)

```text
lib/features/animator_workbench/
├── data/
│   ├── datasources/
│   │   ├── local/       # SQLite DB, FileSystem helpers
│   │   └── remote/      # AI Service implementations (OpenAI, Replicate, etc.)
│   ├── models/          # DTOs (AssetModel, TaskModel)
│   └── repositories/    # AssetRepositoryImpl, TaskRepositoryImpl
├── domain/
│   ├── entities/        # Asset, Task, Project
│   ├── repositories/    # IAssetRepository, ITaskRepository
│   └── services/        # IGenerativeImageService (Adapter Interface)
└── presentation/
    ├── providers/       # Riverpod Providers (AssetListProvider, TaskQueueProvider)
    ├── pages/           # WorkbenchPage, AssetDetailsPage
    └── widgets/         # AssetGrid, TaskToast, RefinementControls
```

**Structure Decision**: Flutter Clean Architecture (Feature-first)

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| None | | |
