# AI Service API Contract

**File**: `ai_service_api.yaml`
**Format**: OpenAPI 3.0.0

```yaml
openapi: 3.0.0
info:
  title: Generative Image Service Adapter API
  version: 1.0.0
  description: >
    Abstract interface for external AI image generation services.
    Implementations (OpenAI, Replicate, Local SD) must conform to this contract.

paths:
  /generate/refine:
    post:
      summary: Refine an existing image (Face Swap, Inpainting, Upscale)
      operationId: refineImage
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/RefinementRequest'
      responses:
        '200':
          description: Task successfully queued or completed
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/GenerationResponse'
        '400':
          description: Invalid parameters
        '500':
          description: Provider error

  /generate/video:
    post:
      summary: Generate video from text or image (Image-to-Video)
      operationId: generateVideo
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/VideoGenerationRequest'
      responses:
        '200':
          description: Video generation task queued
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/GenerationResponse'
        '400':
          description: Invalid parameters
        '500':
          description: Provider error

components:
  schemas:
    RefinementRequest:
      type: object
      required:
        - sourceImage
        - operationType
      properties:
        sourceImage:
          type: string
          format: binary
          description: Base64 encoded image or URL (depending on provider impl)
        maskImage:
          type: string
          format: binary
          description: Optional mask for inpainting
        operationType:
          type: string
          enum: [face_swap, inpainting, upscale, style_transfer]
        prompt:
          type: string
          description: Text guidance for the generation
        strength:
          type: number
          format: float
          minimum: 0.0
          maximum: 1.0
          description: Denoising strength (0.0 = no change, 1.0 = full hallucination)
        referenceImage:
          type: string
          format: binary
          description: Optional reference image (e.g., for Face Swap identity)
        seed:
          type: integer
          description: Random seed for reproducibility

    VideoGenerationRequest:
      type: object
      required:
        - model
        - prompt
      properties:
        model:
          type: string
          description: Model ID (e.g., veo3-fast-frames, veo3-pro)
          enum: [veo2-fast-frames, veo3-pro-frames, veo2-fast-components, veo3-fast-frames, veo3, veo2]
        prompt:
          type: string
          description: Text description of the video content
        images:
          type: array
          items:
            type: string
            format: uri
          description: List of image URLs (Start frame, End frame, or Components). Must be public URLs.
          maxItems: 3
        aspect_ratio:
          type: string
          enum: ["16:9", "9:16"]
          description: Video aspect ratio (only for veo3 series)
        enhance_prompt:
          type: boolean
          default: true
          description: Whether to enable AI prompt enhancement
        enable_upsample:
          type: string
          enum: ["true", "false"]
          default: "true"
          description: Whether to enable resolution upsampling

    GenerationResponse:
      type: object
      required:
        - id
        - status
      properties:
        id:
          type: string
          description: Provider-specific task ID
        status:
          type: string
          enum: [pending, processing, succeeded, failed]
        outputUrl:
          type: string
          description: URL to the generated image or video (if succeeded)
        error:
          type: string
          description: Error message (if failed)
        enhanced_prompt:
          type: string
          description: The actual prompt used after AI enhancement (for video generation)
```
