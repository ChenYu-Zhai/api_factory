import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_colors.dart';
import '../providers/dependency_injection.dart';

class ScriptImportDialog extends ConsumerStatefulWidget {
  final String projectId;

  const ScriptImportDialog({super.key, required this.projectId});

  @override
  ConsumerState<ScriptImportDialog> createState() => _ScriptImportDialogState();
}

class _ScriptImportDialogState extends ConsumerState<ScriptImportDialog> {
  final TextEditingController _scriptController = TextEditingController();
  bool _isImporting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _scriptController.dispose();
    super.dispose();
  }

  Future<void> _importScript() async {
    final scriptContent = _scriptController.text;
    if (scriptContent.isEmpty) {
      setState(() {
        _errorMessage = '请输入脚本内容';
      });
      return;
    }

    setState(() {
      _isImporting = true;
      _errorMessage = null;
    });

    try {
      final parser = ref.read(scriptParserProvider);
      final repository = ref.read(scriptImportRepositoryProvider);

      final scenes = await parser.parseScript(scriptContent, widget.projectId);
      await repository.saveImportedScenes(scenes);

      if (mounted) {
        Navigator.of(context).pop(true); // Return true on success
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '导入失败: $e';
          _isImporting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '导入分镜头脚本',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              '''请粘贴您的分镜头脚本内容。支持格式：
SCENE 1: 场景名称
SHOT 1: 镜头名称 : 镜头描述''',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _scriptController,
              maxLines: 10,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: '在此粘贴脚本...',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                errorText: _errorMessage,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isImporting ? null : () => Navigator.of(context).pop(),
                  child: const Text('取消'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isImporting ? null : _importScript,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textPrimary,
                  ),
                  child: _isImporting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.textPrimary,
                          ),
                        )
                      : const Text('导入'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
