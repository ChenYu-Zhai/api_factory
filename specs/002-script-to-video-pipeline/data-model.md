# Data Model: Script to Video Pipeline

## Entities

### 1. Scene
Represents a scene in the script.

| Field | Type | Description |
|-------|------|-------------|
| `id` | `String` (UUID) | Unique identifier |
| `projectId` | `String` (UUID) | Foreign key to Project |
| `name` | `String` | Scene header (e.g., "INT. OFFICE - DAY") |
| `description` | `String` | Scene description/action |
| `sequenceNumber` | `int` | Order in the script |
| `shots` | `List<Shot>` | List of shots in this scene (Domain only) |

### 2. Shot
Represents a single camera shot within a scene.

| Field | Type | Description |
|-------|------|-------------|
| `id` | `String` (UUID) | Unique identifier |
| `sceneId` | `String` (UUID) | Foreign key to Scene |
| `sequenceNumber` | `int` | Order within the scene |
| `description` | `String` | Visual description of the shot |
| `characters` | `List<String>` | Names of characters in the shot |
| `duration` | `double` | Estimated duration in seconds (default: 3.0) |

### 3. Asset (Updated)
Represents a media file (Image, Video) generated or imported.

| Field | Type | Description |
|-------|------|-------------|
| `id` | `String` (UUID) | Unique identifier |
| `projectId` | `String` (UUID) | Foreign key to Project |
| `shotId` | `String?` (UUID) | **[NEW]** Foreign key to Shot (optional) |
| `type` | `AssetType` | `imageBase`, `imageRefined`, `video` |
| `filePath` | `String` | Local file system path |
| `metadata` | `Map<String, dynamic>` | Source info, prompt, model params |
| `createdAt` | `DateTime` | Creation timestamp |

### 4. Task (Updated)
Represents a background operation.

| Field | Type | Description |
|-------|------|-------------|
| `id` | `String` (UUID) | Unique identifier |
| `type` | `TaskType` | `generateImage`, `generateVideo`, `analyzeScript` |
| `status` | `TaskStatus` | `pending`, `processing`, `completed`, `failed` |
| `parameters` | `Map<String, dynamic>` | Input params (prompt, source asset IDs) |
| `resultAssetId` | `String?` | ID of the created asset (if successful) |
| `error` | `String?` | Error message if failed |

## Database Schema (SQLite)

```sql
CREATE TABLE scenes (
  id TEXT PRIMARY KEY,
  project_id TEXT NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  sequence_number INTEGER NOT NULL
);

CREATE TABLE shots (
  id TEXT PRIMARY KEY,
  scene_id TEXT NOT NULL,
  sequence_number INTEGER NOT NULL,
  description TEXT NOT NULL,
  characters TEXT, -- JSON encoded list
  duration REAL DEFAULT 3.0,
  FOREIGN KEY(scene_id) REFERENCES scenes(id) ON DELETE CASCADE
);

-- Update existing assets table
ALTER TABLE assets ADD COLUMN shot_id TEXT REFERENCES shots(id) ON DELETE SET NULL;
```

## JSON Structures

### Script Analysis Output (Gemini)
```json
[
  {
    "name": "Scene 1",
    "description": "...",
    "shots": [
      {
        "sequenceNumber": 1,
        "description": "...",
        "characters": ["Alice", "Bob"]
      }
    ]
  }
]
```
