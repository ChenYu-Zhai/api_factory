# Implementation Plan: Script to Video Pipeline

**Branch**: `002-script-to-video-pipeline` | **Date**: 2026-02-03 | **Spec**: [specs/002-script-to-video-pipeline/spec.md](specs/002-script-to-video-pipeline/spec.md)
**Input**: Feature specification from `/specs/002-script-to-video-pipeline/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

This feature implements a complete pipeline to transform a text script into a video. It involves:
1.  **Script Analysis**: Using AI (Gemini) to parse a raw script into structured Scenes and Shots.
2.  **Shot Visualization**: Generating "First Frame" images for each shot using AI image generators (Gemini/Midjourney).
3.  **Video Generation**: Using AI video generators (Veo) to animate the shots using the First Frame (and optional Last Frame).
4.  **Async Processing**: Managing these long-running operations via a background Task Queue to keep the UI responsive.

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.x
**Primary Dependencies**: `flutter_riverpod` (State Management), `dio` (Network), `sqflite` (Local DB), `uuid` (ID generation), `path_provider` (File storage).
**Storage**: SQLite for structured data (Scenes, Shots, Tasks), Local File System for media assets (Images, Videos).
**Testing**: `flutter_test` for Unit/Widget tests, `mockito` for mocking services.
**Target Platform**: Windows / macOS (Desktop).
**Project Type**: Flutter Desktop Application.
**Performance Goals**: Non-blocking UI during AI generation; efficient handling of large media files.
**Constraints**: Local-first architecture; API rate limits for AI services.
**Scale/Scope**: Handling scripts with 50+ shots; concurrent background generation tasks.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] **Layered Architecture**: The design strictly separates Presentation (Widgets/Providers), Domain (Entities/Interfaces), and Data (Repositories/DTOs).
- [x] **State Management**: Uses `flutter_riverpod` for predictable, unidirectional data flow.
- [x] **Repository Pattern**: Data access is abstracted behind `IScriptRepository`, `IShotRepository`, `ITaskRepository`.
- [x] **Component Design**: UI will be broken down into `ShotWorkspace`, `AssetCard`, `ScriptImportDialog`, etc.
- [x] **Testing Strategy**: Includes Unit tests for Repositories/Services and Widget tests for the Workspace.
- [x] **Local-First Authority**: All generated assets and script data are stored locally.
- [x] **Extensible API Adapters**: AI services (Gemini, Veo) are accessed via `IGenerativeImageService`, `IAIScriptAnalysisService`.
- [x] **Asynchronous Command Queue**: Video and Image generation are handled by `TaskQueueService`.

## Project Structure

### Documentation (this feature)

```text
specs/002-script-to-video-pipeline/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
└── tasks.md             # Phase 2 output
```

### Source Code (repository root)

```text
lib/features/animator_workbench/
├── data/
│   ├── datasources/
│   │   ├── local/       # DatabaseHelper extensions
│   │   └── remote/      # GeminiScriptAnalysisService
│   ├── models/          # ShotModel, SceneModel (DTOs)
│   └── repositories/    # ShotRepositoryImpl
├── domain/
│   ├── entities/        # Shot (updated), Scene
│   ├── repositories/    # IShotRepository
│   └── services/        # IAIScriptAnalysisService
└── presentation/
    ├── providers/       # ScriptAnalysisProvider, ShotProvider
    ├── pages/           # WorkbenchPage (updates)
    └── widgets/         # ShotList, AssetGenerationControls
```

**Structure Decision**: Flutter Clean Architecture (Feature-first) - Extending existing `animator_workbench` feature.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| N/A | | |
