import '../../domain/entities/asset.dart';

final List<Map<String, dynamic>> mockScenes = [
  {
    'id': 'scene_1',
    'name': '场景 1',
    'shots': [
      {'id': 'shot_1', 'name': '镜头 01: 开场介绍', 'description': '角色登场'},
      {'id': 'shot_2', 'name': '镜头 02: 特写反应', 'description': '惊讶表情'},
      {'id': 'shot_3', 'name': '镜头 03: 广角全景', 'description': '环境展示'},
    ]
  },
  {
    'id': 'scene_2',
    'name': '场景 2',
    'shots': [
      {'id': 'shot_4', 'name': '镜头 01: 追逐开始', 'description': '快速奔跑'},
      {'id': 'shot_5', 'name': '镜头 02: 障碍物', 'description': '跳过障碍'},
    ]
  },
];

final List<Asset> mockAssets = [
  Asset(
    id: 'asset_1',
    projectId: 'project_1',
    type: AssetType.imageBase,
    filePath: '/mock/path/image1.png',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    isMasterReference: true,
  ),
  Asset(
    id: 'asset_2',
    projectId: 'project_1',
    type: AssetType.imageRefined,
    filePath: '/mock/path/image2.png',
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    parentId: 'asset_1',
  ),
  Asset(
    id: 'asset_3',
    projectId: 'project_1',
    type: AssetType.video,
    filePath: '/mock/path/video1.mp4',
    createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
  ),
];
