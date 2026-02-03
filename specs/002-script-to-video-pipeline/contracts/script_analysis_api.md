# API Contract: Script Analysis Service

**Interface**: `IAIScriptAnalysisService`
**Implementation**: `GeminiScriptAnalysisService`

## Methods

### `analyzeScript`

Parses raw script text into structured Scenes and Shots.

- **Signature**:
  ```dart
  Future<List<Scene>> analyzeScript(String scriptContent, String projectId);
  ```

- **Parameters**:
  - `scriptContent` (String): The raw text of the script.
  - `projectId` (String): The ID of the current project (for creating entity IDs).

- **Returns**:
  - `Future<List<Scene>>`: A list of Scene entities, each containing a list of Shot entities.

- **Throws**:
  - `ScriptAnalysisException`: If the AI fails to return valid JSON or the API call fails.

## Data Types

### `Scene` (Domain Entity)
See `data-model.md` for full definition.
- `id`: UUID
- `shots`: List<Shot>

### `Shot` (Domain Entity)
See `data-model.md` for full definition.
- `id`: UUID
- `description`: String
- `characters`: List<String>

## JSON Schema (AI Output)

The AI service is expected to return JSON matching this schema:

```json
[
  {
    "name": "string",
    "description": "string",
    "shots": [
      {
        "sequenceNumber": integer,
        "description": "string",
        "characters": ["string"]
      }
    ]
  }
]
```
