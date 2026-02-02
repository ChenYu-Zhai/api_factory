import 'package:api_factory/features/animator_workbench/data/services/simple_script_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SimpleScriptParser', () {
    late SimpleScriptParser parser;

    setUp(() {
      parser = SimpleScriptParser();
    });

    test('parses simple script correctly', () async {
      const script = '''
SCENE 1: Opening
SHOT 1: Wide shot : A beautiful landscape
SHOT 2: Close up : Hero face

SCENE 2: Action
SHOT 1: Punch : Hero punches villain
''';

      final scenes = await parser.parseScript(script, 'project_1');

      expect(scenes.length, 2);
      
      expect(scenes[0].name, 'Opening');
      expect(scenes[0].shots.length, 2);
      expect(scenes[0].shots[0].name, 'Wide shot');
      expect(scenes[0].shots[0].description, 'A beautiful landscape');

      expect(scenes[1].name, 'Action');
      expect(scenes[1].shots.length, 1);
      expect(scenes[1].shots[0].name, 'Punch');
    });

    test('parses script with Chinese keywords', () async {
      const script = '''
场景 1: 开场
镜头 1: 全景 : 美丽的风景

场景 2: 动作
镜头 1: 出拳 : 主角打反派
''';

      final scenes = await parser.parseScript(script, 'project_1');

      expect(scenes.length, 2);
      
      expect(scenes[0].name, '开场');
      expect(scenes[0].shots.length, 1);
      expect(scenes[0].shots[0].name, '全景');

      expect(scenes[1].name, '动作');
      expect(scenes[1].shots.length, 1);
    });
  });
}
