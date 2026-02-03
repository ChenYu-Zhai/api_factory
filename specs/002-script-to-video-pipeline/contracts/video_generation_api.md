# API Contract: Video Generation Service

**Interface**: `IVideoGenerationService` (New Interface to be created, or extension of `VeoService`)
**Implementation**: `VeoService`

## Methods

### `createVideo`

Initiates an asynchronous video generation task.

- **Signature**:
  ```dart
  Future<String> createVideo({
    required String prompt,
    required String projectId,
    String? firstFrameAssetId,
    String? lastFrameAssetId,
    String model = 'veo_3_1-fast',
  });
  ```

- **Parameters**:
  - `prompt` (String): Text description of the video motion/content.
  - `projectId` (String): ID of the project.
  - `firstFrameAssetId` (String?): ID of the Asset to use as the starting frame (Image-to-Video).
  - `lastFrameAssetId` (String?): ID of the Asset to use as the ending frame (optional).
  - `model` (String): The model identifier (default: `veo_3_1-fast`).

- **Returns**:
  - `Future<String>`: The Task ID (from the external provider) to poll for status.

- **Throws**:
  - `VideoGenerationException`: If the API request fails.

### `queryTask`

Checks the status of a running generation task.

- **Signature**:
  ```dart
  Future<VeoResponse?> queryTask(String taskId);
  ```

- **Parameters**:
  - `taskId` (String): The ID returned by `createVideo`.

- **Returns**:
  - `Future<VeoResponse?>`: Status object containing `status` ('pending', 'success', 'failed') and `videoUrl` (if success).

### `downloadAndSaveVideo`

Downloads the completed video and creates a local Asset.

- **Signature**:
  ```dart
  Future<Asset> downloadAndSaveVideo(String videoUrl, String projectId, String prompt, {String? shotId});
  ```

- **Parameters**:
  - `videoUrl` (String): Remote URL of the generated video.
  - `projectId` (String): Project ID.
  - `prompt` (String): Original prompt (for metadata).
  - `shotId` (String?): ID of the shot this video belongs to.

- **Returns**:
  - `Future<Asset>`: The created local Asset entity.
