# Feature Specification: Script to Video Pipeline

**Feature Branch**: `002-script-to-video-pipeline`
**Created**: 2026-02-03
**Status**: Draft
**Input**: User description: "现在尝试跑通从剧本到分镜到首帧到视频的整个链路,给出剧本ai自动划分镜头,文档可以参考项目工程文档文件夹中的文件,ui部分的需求查看图像.用户的操作流程上传分镜头->获取分镜头脚本信息->根据首帧镜头描述生成首帧->可选择是否生成尾帧->将首帧或者首帧以及尾帧信息发送给视频模型接口后台异步生成视频不影响其他视频的创作"

## User Scenarios & Testing

### User Story 1 - Script Import & AI Analysis (Priority: P1)

As a creator, I want to import a script and have AI automatically split it into shots so that I can quickly start the visualization process without manual data entry.

**Why this priority**: This is the entry point of the pipeline. Without shots, there is nothing to generate.

**Independent Test**: Can be tested by importing a text file and verifying that a list of shots with descriptions and characters appears.

**Acceptance Scenarios**:

1. **Given** a raw text script, **When** the user imports it, **Then** the system sends it to the AI service.
2. **Given** the AI service returns analyzed data, **When** processing is complete, **Then** the system displays a sequence of shots, each with a description and list of characters.
3. **Given** the analysis fails, **When** the error occurs, **Then** the user is notified and can retry.

---

### User Story 2 - Shot Visualization & First Frame Generation (Priority: P1)

As a creator, I want to view shot details and generate a first frame (keyframe) based on the shot description so that I can visualize the visual style and composition.

**Why this priority**: Visualizing the shot is the core value proposition before moving to video.

**Independent Test**: Can be tested by selecting a shot and clicking "Generate Image", then verifying an image appears in the "ImageBase" slot.

**Acceptance Scenarios**:

1. **Given** a selected shot, **When** the user views the workspace, **Then** the shot's description and appearing characters are clearly displayed (as per UI design).
2. **Given** a shot with a description, **When** the user triggers "Generate First Frame", **Then** the system requests an image from the AI image service.
3. **Given** a generation request, **When** it is processing, **Then** a loading state is shown on the "ImageBase" card.
4. **Given** a successful generation, **When** completed, **Then** the generated image is displayed in the "ImageBase" card.

---

### User Story 3 - Async Video Generation (Priority: P1)

As a creator, I want to generate a video using the first frame (and optionally a last frame) in the background so that I can continue working on other shots while the video renders.

**Why this priority**: Video generation is time-consuming; blocking the UI would destroy productivity.

**Independent Test**: Can be tested by starting a video generation, immediately switching to another shot, and verifying the first shot's video eventually completes.

**Acceptance Scenarios**:

1. **Given** a generated first frame, **When** the user chooses to generate video, **Then** they can optionally choose to generate/upload a last frame first.
2. **Given** the necessary frames (First only, or First + Last), **When** the user clicks "Generate Video", **Then** a task is sent to the background video service.
3. **Given** a running video task, **When** the user navigates to other shots, **Then** the task continues uninterrupted.
4. **Given** a completed video task, **When** the user returns to the shot, **Then** the result is displayed in the "Video" card.

### Edge Cases

- **Network Failure**: What happens if the internet connection drops during script analysis or video generation? (System should retry or fail gracefully with a clear message).
- **API Limits**: What happens if the AI service quota is exceeded? (User should be notified of the limit).
- **Invalid Script Format**: What happens if the uploaded script is empty or unreadable? (Error message prompting check of file).
- **Generation Failure**: What happens if the AI model fails to generate an image or video? (Task marked as failed, retry option available).

### Assumptions

- Users have a stable internet connection.
- The AI services (Script Analysis, Image Gen, Video Gen) are available and have valid API keys configured.
- The script is in a supported language and format (text).

## Requirements

### Functional Requirements

- **FR-001**: System MUST allow users to input/import a script (text).
- **FR-002**: System MUST use an AI service to parse the script and divide it into individual shots (Storyboard).
- **FR-003**: System MUST extract and store "Shot Description" and "Characters" for each shot.
- **FR-004**: System MUST display shot metadata (Description, Characters) in the Shot Workspace.
- **FR-005**: System MUST allow generating a "First Frame" image based on the shot description.
- **FR-006**: System MUST allow optional generation or selection of a "Last Frame".
- **FR-007**: System MUST allow submitting a video generation request using the First Frame (and Last Frame if available).
- **FR-008**: Video generation MUST be performed asynchronously (background task).
- **FR-009**: System MUST track the status of generation tasks (Pending, Processing, Completed, Failed) and update the UI accordingly.
- **FR-010**: Users MUST be able to navigate and work on other shots while a video is generating.

### Key Entities

- **Script**: The source text.
- **Shot**: A unit of the storyboard, containing `id`, `description`, `characters`, `duration`.
- **Asset**: Media files associated with a shot (ImageBase, ImageRefined, Video).
- **Task**: A background operation (e.g., `GenerateImage`, `GenerateVideo`) with a status.

### UI/UX Requirements

- **Shot Workspace**:
  - Display Shot Number and Title (e.g., "镜头 01: 开场介绍").
  - Display Text Area/Panel for "Shot Description" and "Characters" (as indicated in red box on UI).
  - **Asset Cards**:
    - **ImageBase**: Shows First Frame or "Processing..." or Placeholder.
    - **ImageRefined**: Shows Refined Image (optional step, but present in UI).
    - **Video**: Shows Result Video or "Waiting for resources".
  - **Actions**: Buttons/Icons to trigger generation for each asset type.

## Success Criteria

### Measurable Outcomes

- **SC-001**: Script analysis successfully identifies and creates shots for at least 90% of standard script scenes.
- **SC-002**: Image generation requests return a result within the timeout period (e.g., 30 seconds) for 95% of requests.
- **SC-003**: Users can trigger video generation and immediately (within 1 second) regain control of the UI to perform other actions.
- **SC-004**: The system successfully handles multiple concurrent video generation tasks (e.g., 3) without crashing.
