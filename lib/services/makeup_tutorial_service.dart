import 'package:flutter/foundation.dart';
import 'package:beauty_advisor/models/makeup_tutorial.dart';

/// 妆容教程服务
class MakeupTutorialService {
  static final MakeupTutorialService _instance = MakeupTutorialService._internal();
  factory MakeupTutorialService() => _instance;
  MakeupTutorialService._internal();

  /// 根据脸型获取推荐妆容
  Future<List<MakeupTutorial>> getRecommendedTutorials(String faceShape) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final allTutorials = _getMockTutorials();
    return allTutorials
        .where((t) => t.isSuitableFor(faceShape))
        .toList()
      ..sort((a, b) => b.popularity.compareTo(a.popularity));
  }

  /// 获取热门妆容
  Future<List<MakeupTutorial>> getPopularTutorials({int limit = 10}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return _getMockTutorials()..sort((a, b) => b.popularity.compareTo(a.popularity));
  }

  /// 按风格获取妆容
  Future<List<MakeupTutorial>> getTutorialsByStyle(MakeupStyle style) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return _getMockTutorials().where((t) => t.style == style).toList();
  }

  /// 模拟妆容教程数据
  List<MakeupTutorial> _getMockTutorials() {
    return [
      // 日常妆
      MakeupTutorial(
        id: 'm001',
        name: '5分钟快速日常妆',
        description: '简单易学的日常妆容，适合上班、上学，自然清新',
        coverImageUrl: 'https://example.com/makeup1.jpg',
        style: MakeupStyle.daily,
        suitableFaceShapes: ['圆脸', '方脸', '长脸', '鹅蛋脸', '瓜子脸', '心形脸'],
        steps: [
          const MakeupStep(order: 1, title: '妆前保湿', description: '涂抹保湿乳液，等待吸收', durationMinutes: 2),
          const MakeupStep(order: 2, title: '隔离防晒', description: '均匀涂抹隔离霜，注意鼻翼和眼角', productRecommendation: '隔离霜', durationMinutes: 1),
          const MakeupStep(order: 3, title: '粉底打底', description: '用美妆蛋轻拍粉底，打造自然底妆', productRecommendation: '粉底液', durationMinutes: 3),
          const MakeupStep(order: 4, title: '眉毛定型', description: '用眉笔填补空缺，眉头要淡', productRecommendation: '眉笔', durationMinutes: 2),
          const MakeupStep(order: 5, title: '眼影晕染', description: '浅色打底，深色加深眼尾', productRecommendation: '大地色眼影盘', durationMinutes: 3),
          const MakeupStep(order: 6, title: '口红点缀', description: '选择日常色号，薄涂即可', productRecommendation: '豆沙色口红', durationMinutes: 1),
        ],
        totalDuration: 12,
        difficulty: 1,
        products: ['隔离霜', '粉底液', '眉笔', '眼影盘', '口红'],
        popularity: 1560,
        rating: 4.8,
      ),
      
      // 裸妆
      MakeupTutorial(
        id: 'm002',
        name: '伪素颜裸妆',
        description: '看不出化妆的精致感，打造天生好皮肤',
        coverImageUrl: 'https://example.com/makeup2.jpg',
        style: MakeupStyle.natural,
        suitableFaceShapes: ['圆脸', '方脸', '长脸', '鹅蛋脸', '瓜子脸', '心形脸'],
        steps: [
          const MakeupStep(order: 1, title: '护肤打底', description: '充分保湿，让皮肤状态最佳'),
          const MakeupStep(order: 2, title: '遮瑕处理', description: '只遮黑眼圈和痘印，保留皮肤质感', productRecommendation: '遮瑕膏'),
          const MakeupStep(order: 3, title: '散粉定妆', description: '轻扫散粉，保持哑光质感', productRecommendation: '透明散粉'),
          const MakeupStep(order: 4, title: '自然眉形', description: '顺着眉毛生长方向，画出自然眉形'),
          const MakeupStep(order: 5, title: '润唇打底', description: '选择接近唇色的润唇膏', productRecommendation: '润唇膏'),
        ],
        totalDuration: 8,
        difficulty: 1,
        products: ['遮瑕膏', '透明散粉', '眉笔', '润唇膏'],
        popularity: 1230,
        rating: 4.7,
      ),
      
      // 约会妆
      MakeupTutorial(
        id: 'm003',
        name: '甜美约会妆',
        description: '温柔甜美的约会妆容，让你成为焦点',
        coverImageUrl: 'https://example.com/makeup3.jpg',
        style: MakeupStyle.date,
        suitableFaceShapes: ['圆脸', '鹅蛋脸', '瓜子脸', '心形脸'],
        steps: [
          const MakeupStep(order: 1, title: '底妆打造', description: '打造水光感底妆，轻薄透亮'),
          const MakeupStep(order: 2, title: '腮红位置', description: '腮红打在苹果肌，增添少女感', productRecommendation: '粉色腮红'),
          const MakeupStep(order: 3, title: '眼妆重点', description: '眼头提亮，眼尾拉长，放大双眼', productRecommendation: '眼影盘+眼线笔'),
          const MakeupStep(order: 4, title: '睫毛卷翘', description: '夹翘睫毛，刷上睫毛膏', productRecommendation: '睫毛夹+睫毛膏'),
          const MakeupStep(order: 5, title: '唇妆选择', description: '选择显白粉色系口红', productRecommendation: '蜜桃色口红'),
        ],
        totalDuration: 15,
        difficulty: 2,
        products: ['粉底液', '腮红', '眼影盘', '眼线笔', '睫毛膏', '口红'],
        popularity: 1890,
        rating: 4.9,
      ),
      
      // 韩妆
      MakeupTutorial(
        id: 'm004',
        name: '韩系清透妆容',
        description: '韩剧女主同款妆容，水光肌+一字眉',
        coverImageUrl: 'https://example.com/makeup4.jpg',
        style: MakeupStyle.korean,
        suitableFaceShapes: ['圆脸', '方脸', '鹅蛋脸'],
        steps: [
          const MakeupStep(order: 1, title: '水光底妆', description: '使用水光粉底，打造光泽肌', productRecommendation: '水光粉底液'),
          const MakeupStep(order: 2, title: '一字眉形', description: '韩系一字眉，眉尾自然下垂', productRecommendation: '眉笔'),
          const MakeupStep(order: 3, title: '卧蚕眼妆', description: '画卧蚕，增添无辜感', productRecommendation: '卧蚕笔'),
          const MakeupStep(order: 4, title: '渐变唇妆', description: '咬唇妆效果，唇部中央深', productRecommendation: '染唇液'),
        ],
        totalDuration: 12,
        difficulty: 2,
        products: ['水光粉底液', '眉笔', '卧蚕笔', '染唇液'],
        popularity: 1450,
        rating: 4.6,
      ),
      
      // 职场妆
      MakeupTutorial(
        id: 'm005',
        name: '干练职场妆',
        description: '专业不失女人味的职场妆容',
        coverImageUrl: 'https://example.com/makeup5.jpg',
        style: MakeupStyle.office,
        suitableFaceShapes: ['圆脸', '方脸', '长脸', '鹅蛋脸'],
        steps: [
          const MakeupStep(order: 1, title: '干净底妆', description: '哑光底妆，显得专业干练'),
          const MakeupStep(order: 2, title: '自然眉形', description: '眉形清晰但不过于锋利'),
          const MakeupStep(order: 3, title: '大地色眼妆', description: '大地色系，低调有神'),
          const MakeupStep(order: 4, title: '职场唇色', description: '选择低调的豆沙色或正红色'),
        ],
        totalDuration: 10,
        difficulty: 2,
        products: ['哑光粉底', '眉笔', '大地色眼影', '口红'],
        popularity: 980,
        rating: 4.5,
      ),
      
      // 派对妆
      MakeupTutorial(
        id: 'm006',
        name: '闪亮派对妆',
        description: '适合夜店、派对的闪亮妆容',
        coverImageUrl: 'https://example.com/makeup6.jpg',
        style: MakeupStyle.party,
        suitableFaceShapes: ['鹅蛋脸', '瓜子脸', '心形脸'],
        steps: [
          const MakeupStep(order: 1, title: '持久底妆', description: '选择持久型粉底，防止脱妆'),
          const MakeupStep(order: 2, title: '闪片眼妆', description: '加入闪片，灯光下闪闪发光', productRecommendation: '闪片眼影'),
          const MakeupStep(order: 3, title: '猫眼眼线', description: '上扬眼线，增添魅惑感', productRecommendation: '眼线液笔'),
          const MakeupStep(order: 4, title: '浓密睫毛', description: '贴假睫毛或刷浓密型睫毛膏'),
          const MakeupStep(order: 5, title: '个性唇妆', description: '选择亮眼的唇色'),
        ],
        totalDuration: 20,
        difficulty: 3,
        products: ['持久粉底', '闪片眼影', '眼线液笔', '假睫毛', '口红'],
        popularity: 756,
        rating: 4.4,
      ),
    ];
  }
}
