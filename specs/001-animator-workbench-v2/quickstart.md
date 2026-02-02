# Quickstart: Enterprise AI Animator Workbench v2.0

**Feature**: `001-animator-workbench-v2`
**Date**: 2026-01-29

## 1. Prerequisites

- **Flutter SDK**: 3.19.0 or higher
- **Dart SDK**: 3.3.0 or higher
- **Platform**: Windows 10/11 or macOS 12+ (Apple Silicon recommended)
- **API Keys**:
  - OpenAI (for DALL-E 3 / GPT-4 Vision)
  - Replicate (for Stable Diffusion / Face Swap models)

## 2. Installation

1. **Clone the repository**:
   ```bash
   git clone <repo_url>
   cd api_factory
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Setup SQLite (Desktop)**:
   Ensure `sqlite3.dll` (Windows) is available in the system path or bundled. On macOS, it's built-in.

## 3. Configuration

Create a `.env` file in the root directory:

```env
OPENAI_API_KEY=sk-...
REPLICATE_API_TOKEN=r8_...
AI_SERVICE_PROVIDER=replicate # or 'openai', 'mock'
```

## 4. Running the Application

### Development Mode
Run with the `dev` flavor to use test databases and mock services by default.

```bash
flutter run -d windows --flavor dev
# or
flutter run -d macos --flavor dev
```

### Production Mode
```bash
flutter run -d windows --flavor prod
```

## 5. Key Workflows

### A. Queue a Face Swap Task
1. Open the **Workbench** tab.
2. Select a **Source Image** from the asset grid.
3. Click **"Refine"** in the right sidebar.
4. Choose **"Face Swap"** mode.
5. Select a **Reference Image** (Target Identity).
6. Click **"Generate"**.
   - *Observation*: A placeholder card appears immediately. The task runs in the background.

### B. View Asset Lineage
1. Double-click any **Refined Asset**.
2. In the detail view, look for the **"Lineage"** section.
3. Click the **"Parent Asset"** thumbnail to navigate to the source image.

## 6. Troubleshooting

- **"Database Locked" Error**: Ensure only one instance of the app is running.
- **Task Stuck in "Pending"**: Check the logs for `TaskQueueService`. If the app crashed, restart it to resume processing.
- **Image Load Failures**: Verify the `assets/` directory has read/write permissions.
