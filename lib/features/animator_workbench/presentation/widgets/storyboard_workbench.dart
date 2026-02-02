import 'package:flutter/material.dart';
import 'project_sidebar.dart';
import 'shot_workspace.dart';

class StoryboardWorkbench extends StatelessWidget {
  final String projectId;

  const StoryboardWorkbench({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left Sidebar: Project Tree & Library
        const ProjectSidebar(),
        
        // Main Workspace: Shot Timeline & Assets
        Expanded(
          child: ShotWorkspace(projectId: projectId),
        ),
      ],
    );
  }
}
