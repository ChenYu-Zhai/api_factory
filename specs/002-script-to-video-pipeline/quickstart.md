# Quickstart: Script to Video Pipeline

## Overview
This guide explains how to use the Script to Video Pipeline to transform a text script into a video sequence.

## Prerequisites
- Valid API Keys for **Gemini** (Script Analysis, Image Gen) and **Veo** (Video Gen) in `.env`.
- A project created in the Animator Workbench.

## Workflow

### 1. Import Script
1.  Navigate to the **Script Workbench** tab.
2.  Click the **"Import Script"** button.
3.  Paste your script text or upload a `.txt` file.
4.  Click **"Analyze"**.
    - *What happens*: The system sends the text to Gemini, which breaks it down into Scenes and Shots.
5.  Review the generated shots in the sidebar.

### 2. Generate First Frame (Image)
1.  Select a **Shot** from the list.
2.  In the **Shot Workspace**, locate the **"ImageBase"** card.
3.  Review the "Shot Description" (editable).
4.  Click **"Generate Image"**.
    - *What happens*: A task is queued. The card shows a loading spinner.
    - *Result*: The generated image appears in the card.

### 3. Generate Video
1.  Ensure the **"ImageBase"** (First Frame) is generated.
2.  (Optional) Generate or upload a **"Last Frame"** in the "ImageRefined" card (or a dedicated Last Frame slot if available).
3.  Locate the **"Video"** card.
4.  Click **"Generate Video"**.
    - *What happens*: A background task is queued using the First Frame as a reference.
    - *Note*: You can navigate away and work on other shots while this processes.
5.  Once complete, the video will auto-play (loop) in the Video card.

## Troubleshooting

- **Analysis Fails**: Ensure the script has clear scene headers (e.g., "INT.", "EXT.") or distinct action lines.
- **Image Generation Stuck**: Check your internet connection and API quota.
- **Video Generation Error**: Verify that the First Frame is a valid image file.

## Developer Notes

- **Database**: Check `animator_workbench.db` in your documents folder for raw data.
- **Logs**: Console logs will show Task Queue activity (`Processing task...`).
