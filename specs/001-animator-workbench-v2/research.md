# Research & Technical Decisions: Enterprise AI Animator Workbench v2.0

**Feature**: `001-animator-workbench-v2`
**Date**: 2026-01-29
**Status**: Completed

## 1. Persistence Layer (Metadata & Lineage)

### Context
The feature requires tracking complex relationships between assets (Lineage: Parent -> Child) and persistent task states (Queue) that survive application restarts.

### Decision
**Use `sqflite` (via `sqflite_common_ffi` for Desktop).**

### Rationale
- **Relational Integrity**: Asset lineage is inherently relational (Tree/Graph structure). SQL makes querying "all descendants of X" or "history of Y" efficient.
- **Desktop Support**: `sqflite_common_ffi` provides reliable SQLite support for Windows and macOS.
- **ACID Compliance**: Critical for ensuring task states (Pending -> Processing -> Completed) are not corrupted if the app crashes.

### Alternatives Considered
- **Hive/Isar**: NoSQL solutions. Faster, but enforcing referential integrity for lineage trees is manual and error-prone compared to SQL foreign keys.
- **JSON Files**: Too slow for querying large collections; risk of corruption on crash.

## 2. Background Task Management

### Context
Users need to queue heavy operations (AI refinement, Image encoding) that run asynchronously. The queue must persist across restarts (FR-003).

### Decision
**Custom `TaskQueueService` backed by SQLite + Dart Isolates.**

### Rationale
- **Lifecycle Control**: Mobile "Background Fetch" plugins are ill-suited for Desktop apps. We need explicit control to Pause/Resume queues when the app is open.
- **Persistence**: The queue state is stored in SQLite. On app launch, the service reads "Pending" tasks and resumes execution.
- **UI Responsiveness**: Actual processing logic (e.g., image encoding) runs in `Isolate.run()` (Dart 3.x) to ensure the main thread never drops frames (SC-001).

### Alternatives Considered
- **WorkManager**: Designed for mobile background execution constraints (iOS/Android), not Desktop app lifecycles.
- **Future.wait**: In-memory only; loses tasks on crash/close.

## 3. Image Processing Strategy

### Context
The app performs local format conversion and compression (FR-001).

### Decision
**`image` package (Pure Dart) running in Isolates.**

### Rationale
- **Portability**: Pure Dart avoids complex native build configurations for Windows/macOS.
- **Performance**: While slower than C++, running in a separate Isolate ensures the UI remains fluid. Modern Dart performance is sufficient for batch processing typical asset sizes.
- **Simplicity**: Easier to maintain and test than FFI bindings to ImageMagick or similar.

### Alternatives Considered
- **flutter_image_compress**: Relies on native platform implementations. Good for mobile, but desktop support can be inconsistent or require extra setup.
- **FFmpeg**: Overkill for simple image resizing/conversion; adds significant binary size.

## 4. AI Service Integration (Adapter Pattern)

### Context
The app integrates with external AI services for Face Swap and Inpainting (FR-006).

### Decision
**Strict Adapter Pattern (`IGenerativeImageService`).**

### Rationale
- **Decoupling**: The domain layer defines *what* we need (e.g., `refineImage(source, params)`), not *who* provides it.
- **Switchability**: Allows swapping providers (e.g., switching from Replicate to a local Stable Diffusion server) by changing one line of dependency injection config.
- **Testing**: Easy to inject `MockGenerativeService` for offline testing.

## 5. Asset Storage Structure

### Context
"Local-First Authority" requires a predictable file structure.

### Decision
**Hierarchical Directory Structure:**
`{ProjectRoot}/assets/{Year}/{Month}/{UUID}.{ext}`

### Rationale
- **Scalability**: Prevents a single folder from containing thousands of files (OS performance issue).
- **Organization**: Time-based partitioning helps with backup and manual file management if needed.
- **Uniqueness**: UUID ensures no filename collisions.

## Summary of Dependencies

| Category | Package | Purpose |
|----------|---------|---------|
| **Database** | `sqflite_common_ffi`, `sqlite3_flutter_libs` | Desktop SQLite support |
| **State** | `flutter_riverpod` | App-wide state management |
| **Network** | `dio` | Robust HTTP client for AI APIs |
| **Image** | `image` | Pixel-level manipulation |
| **Utils** | `uuid`, `path_provider`, `equatable` | Common utilities |
