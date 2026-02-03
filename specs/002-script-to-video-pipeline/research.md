# Research: Script to Video Pipeline

**Feature**: Script to Video Pipeline
**Status**: Phase 0 Complete

## 1. Script Analysis & Parsing

**Problem**: We need to reliably convert raw script text (which varies in format) into a structured hierarchy of `Scenes` and `Shots`.

**Analysis**:
- **Input**: Raw text (User uploaded or pasted).
- **Output**: JSON structure `[ { "scene": "...", "shots": [ { "description": "...", "characters": [...] } ] } ]`.
- **Model**: Gemini 1.5 Pro is ideal due to its large context window and strong instruction following for JSON.

**Decision**:
- Implement `GeminiScriptAnalysisService` implementing `IAIScriptAnalysisService`.
- **Prompt Strategy**:
    - Use a "System Instruction" that defines the output JSON schema strictly.
    - Instruct the model to infer "Shots" based on action lines if they aren't explicitly numbered.
    - Extract "Characters" by analyzing the dialogue and action within the shot.

**Prompt Draft**:
```text
You are a professional storyboard artist and script supervisor.
Analyze the following script and break it down into Scenes and Shots.
Output strictly valid JSON.

Structure:
[
  {
    "name": "Scene 1: INT. COFFEE SHOP - DAY",
    "description": "The interior of a busy coffee shop...",
    "shots": [
      {
        "sequenceNumber": 1,
        "description": "Wide shot of the counter. A BARISTA is making coffee.",
        "characters": ["Barista"]
      }
    ]
  }
]

Rules:
1. Identify scenes by headers (INT./EXT.).
2. Break scenes into shots based on camera angles or distinct actions.
3. Extract character names present in the shot.
```

## 2. Video Generation with Keyframes (Image-to-Video)

**Problem**: The requirement specifies using a "First Frame" (and optional "Last Frame") to generate video. The current `VeoService` implementation only supports Text-to-Video (prompt-based).

**Analysis**:
- **Current State**: `VeoService.createVideo` accepts `prompt`, `model`, etc.
- **Requirement**: `FR-007` implies Image-to-Video (I2V) capability.
- **Gap**: The `yunwu.ai` API wrapper in `VeoService` needs to be checked/updated to support image inputs.
- **Assumption**: The underlying Veo model (or the API provider) supports `image_url` or `image_base64` parameters for I2V.

**Decision**:
- Update `VeoService` to accept an optional `image_url` (or base64) parameter.
- If the specific API endpoint `v1/video/create` supports it, pass it in the JSON body (e.g., `image_url` or `init_image`).
- **Fallback**: If the API strictly does not support images, we will use the *description* of the First Frame as the prompt for the video, but this is a degraded experience. We will proceed assuming API support is possible or will be added.

## 3. Data Model & Asset Association

**Problem**: How do we link the generated `Asset` (Image/Video) to a specific `Shot`?

**Analysis**:
- **Current `Asset` Table**: `id`, `project_id`, `parent_id` (FK to assets), `type`, `file_path`, `metadata`.
- **Current `Shot` Entity**: `id`, `sceneId`, `name`, `description`.
- **Need**: Efficient way to query "Get all assets for Shot X".

**Options**:
1.  **Add `shot_id` to `Asset` table**: Cleanest, allows direct query.
2.  **Store in `metadata`**: Flexible, no schema change, but harder to query/index.
3.  **Join Table `shot_assets`**: Most normalized, allows asset reuse (unlikely needed here).

**Decision**:
- **Add `shot_id` column to `assets` table**.
- This requires a database migration (or schema update since we are in early dev).
- `Shot` entity does *not* need to hold the list of assets directly in the DB, but the Domain Entity can have a `List<Asset> assets` field populated by the Repository.

## 4. Task Queue Handling for I2V

**Problem**: The `TaskQueueService` needs to handle the new `generateVideo` parameters (input images).

**Decision**:
- Update `Task` entity `parameters` map to include `firstFrameAssetId` and `lastFrameAssetId`.
- Update `TaskQueueService._processVeoTask`:
    1.  Retrieve the `Asset` for `firstFrameAssetId`.
    2.  Get its `file_path` or upload it to get a URL (depending on API requirement).
    3.  Pass to `VeoService`.

## 5. API Contracts

**Script Analysis**:
- Input: `String scriptContent`, `String projectId`
- Output: `List<Scene>` (where Scene contains `List<Shot>`)

**Image Generation**:
- Input: `String prompt`, `String projectId`, `String shotId`
- Output: `Asset`

**Video Generation**:
- Input: `String prompt`, `String projectId`, `String shotId`, `String? firstFrameAssetId`, `String? lastFrameAssetId`
- Output: `String taskId` (Async) -> eventually `Asset`
