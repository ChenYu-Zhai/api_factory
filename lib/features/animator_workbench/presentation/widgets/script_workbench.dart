import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_colors.dart';
import '../providers/dependency_injection.dart';

class ScriptWorkbench extends ConsumerStatefulWidget {
  final String projectId;

  const ScriptWorkbench({super.key, required this.projectId});

  @override
  ConsumerState<ScriptWorkbench> createState() => _ScriptWorkbenchState();
}

class _ScriptWorkbenchState extends ConsumerState<ScriptWorkbench> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _rawTextController = TextEditingController();
  final TextEditingController _aiInputController = TextEditingController();
  
  bool _isProcessing = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _rawTextController.dispose();
    _aiInputController.dispose();
    super.dispose();
  }

  Future<void> _handleRawImport() async {
    final content = _rawTextController.text;
    if (content.isEmpty) {
      _showError('请输入脚本内容');
      return;
    }

    setState(() {
      _isProcessing = true;
      _statusMessage = '正在解析脚本...';
    });

    try {
      final parser = ref.read(scriptParserProvider);
      final repository = ref.read(scriptImportRepositoryProvider);

      final scenes = await parser.parseScript(content, widget.projectId);
      await repository.saveImportedScenes(scenes);

      if (mounted) {
        _showSuccess('导入成功');
      }
    } catch (e) {
      if (mounted) {
        _showError('导入失败: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _statusMessage = null;
        });
      }
    }
  }

  Future<void> _handleAIAnalysis() async {
    final content = _aiInputController.text;
    if (content.isEmpty) {
      _showError('请输入需要分析的文本');
      return;
    }

    setState(() {
      _isProcessing = true;
      _statusMessage = 'AI 正在分析剧本结构...';
    });

    try {
      final aiService = ref.read(aiScriptAnalysisServiceProvider);
      final repository = ref.read(scriptImportRepositoryProvider);

      final scenes = await aiService.analyzeScript(content, widget.projectId);
      await repository.saveImportedScenes(scenes);

      if (mounted) {
        _showSuccess('AI 分析并导入成功');
      }
    } catch (e) {
      if (mounted) {
        _showError('AI 分析失败: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _statusMessage = null;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: AppColors.surface,
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'AI 智能分析'),
              Tab(text: '原始文本导入'),
            ],
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildAIAnalysisTab(),
              _buildRawTextTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAIAnalysisTab() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI 智能剧本分析',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            '粘贴您的小说、剧本或故事大纲，AI 将自动识别场景、角色和动作，并生成分镜头列表。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: TextField(
              controller: _aiInputController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: '在此粘贴故事内容...',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _handleAIAnalysis,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textPrimary,
              ),
              child: _isProcessing
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textPrimary),
                        ),
                        const SizedBox(width: 12),
                        Text(_statusMessage ?? '处理中...'),
                      ],
                    )
                  : const Text('开始 AI 分析'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRawTextTab() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '原始文本导入',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            '''请严格按照以下格式粘贴内容：
SCENE 1: 场景名称
SHOT 1: 镜头名称 : 镜头描述''',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: TextField(
              controller: _rawTextController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: '在此粘贴格式化脚本...',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _handleRawImport,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surfaceVariant,
                foregroundColor: AppColors.textPrimary,
              ),
              child: _isProcessing
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textPrimary),
                        ),
                        const SizedBox(width: 12),
                        Text(_statusMessage ?? '处理中...'),
                      ],
                    )
                  : const Text('导入文本'),
            ),
          ),
        ],
      ),
    );
  }
}
