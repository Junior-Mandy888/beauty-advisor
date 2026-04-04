import 'package:beauty_advisor/models/hairstyle.dart';

/// 发型推荐服务
class HairstyleService {
  static final HairstyleService _instance = HairstyleService._internal();
  factory HairstyleService() => _instance;
  HairstyleService._internal();

  /// 根据脸型获取推荐发型
  Future<List<Hairstyle>> getRecommendedHairstyles(String faceShape) async {
    // 模拟API请求
    await Future.delayed(const Duration(milliseconds: 500));
    
    final allHairstyles = _getMockHairstyles();
    return allHairstyles
        .where((h) => h.isSuitableFor(faceShape))
        .toList()
      ..sort((a, b) => b.popularity.compareTo(a.popularity));
  }

  /// 获取热门发型
  Future<List<Hairstyle>> getPopularHairstyles({int limit = 10}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final allHairstyles = _getMockHairstyles();
    return allHairstyles
      ..sort((a, b) => b.popularity.compareTo(a.popularity));
  }

  /// 按类型获取发型
  Future<List<Hairstyle>> getHairstylesByType(HairstyleType type) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return _getMockHairstyles().where((h) => h.type == type).toList();
  }

  /// 模拟发型数据
  List<Hairstyle> _getMockHairstyles() {
    return [
      // 圆脸适合的发型
      Hairstyle(
        id: 'h001',
        name: '侧分长卷发',
        description: '侧分设计拉长脸型，大波浪卷发增加蓬松感，显脸小又显气质',
        imageUrl: 'https://example.com/hairstyle1.jpg',
        type: HairstyleType.long,
        suitableFaceShapes: ['圆脸', '方脸', '鹅蛋脸'],
        suitableOccasions: ['日常', '约会', '职场'],
        difficulty: 3,
        popularity: 980,
      ),
      Hairstyle(
        id: 'h002',
        name: '高层次短发',
        description: '层次感短发增加头顶蓬松度，修饰圆脸轮廓，清爽利落',
        imageUrl: 'https://example.com/hairstyle2.jpg',
        type: HairstyleType.short,
        suitableFaceShapes: ['圆脸', '鹅蛋脸'],
        suitableOccasions: ['日常', '职场'],
        difficulty: 2,
        popularity: 856,
      ),
      Hairstyle(
        id: 'h003',
        name: '中分微卷发',
        description: '中分修饰脸型，微卷发尾增加灵动感，自然不做作',
        imageUrl: 'https://example.com/hairstyle3.jpg',
        type: HairstyleType.medium,
        suitableFaceShapes: ['圆脸', '方脸', '长脸', '鹅蛋脸', '瓜子脸', '心形脸'],
        suitableOccasions: ['日常', '约会', '职场'],
        difficulty: 2,
        popularity: 1200,
      ),
      
      // 方脸适合的发型
      Hairstyle(
        id: 'h004',
        name: '温柔波浪卷',
        description: '波浪卷发柔化方脸轮廓，增加女性魅力',
        imageUrl: 'https://example.com/hairstyle4.jpg',
        type: HairstyleType.curly,
        suitableFaceShapes: ['方脸', '圆脸'],
        suitableOccasions: ['约会', '派对'],
        difficulty: 4,
        popularity: 723,
      ),
      Hairstyle(
        id: 'h005',
        name: '法式刘海长发',
        description: '法式刘海修饰额头，长发遮盖下颌角，优雅浪漫',
        imageUrl: 'https://example.com/hairstyle5.jpg',
        type: HairstyleType.bangs,
        suitableFaceShapes: ['方脸', '长脸', '鹅蛋脸'],
        suitableOccasions: ['日常', '约会'],
        difficulty: 2,
        popularity: 945,
      ),
      
      // 长脸适合的发型
      Hairstyle(
        id: 'h006',
        name: '空气刘海长发',
        description: '空气刘海缩短脸型长度，长发增加横向视觉',
        imageUrl: 'https://example.com/hairstyle6.jpg',
        type: HairstyleType.bangs,
        suitableFaceShapes: ['长脸', '鹅蛋脸', '瓜子脸'],
        suitableOccasions: ['日常', '约会', '职场'],
        difficulty: 2,
        popularity: 1100,
      ),
      Hairstyle(
        id: 'h007',
        name: '波波头',
        description: '短发波波头增加横向线条，平衡长脸比例',
        imageUrl: 'https://example.com/hairstyle7.jpg',
        type: HairstyleType.bob,
        suitableFaceShapes: ['长脸', '鹅蛋脸', '瓜子脸'],
        suitableOccasions: ['日常', '职场'],
        difficulty: 1,
        popularity: 678,
      ),
      
      // 瓜子脸/心形脸适合的发型
      Hairstyle(
        id: 'h008',
        name: '中分直发',
        description: '中分直发展现精致五官，简约大气',
        imageUrl: 'https://example.com/hairstyle8.jpg',
        type: HairstyleType.straight,
        suitableFaceShapes: ['瓜子脸', '心形脸', '鹅蛋脸'],
        suitableOccasions: ['日常', '职场', '正式场合'],
        difficulty: 1,
        popularity: 890,
      ),
      Hairstyle(
        id: 'h009',
        name: '优雅低马尾',
        description: '低马尾展现颈部线条，干练优雅',
        imageUrl: 'https://example.com/hairstyle9.jpg',
        type: HairstyleType.ponytail,
        suitableFaceShapes: ['瓜子脸', '心形脸', '鹅蛋脸', '方脸'],
        suitableOccasions: ['职场', '正式场合'],
        difficulty: 1,
        popularity: 567,
      ),
      Hairstyle(
        id: 'h010',
        name: '浪漫编发',
        description: '精致编发增加甜美感，适合各种场合',
        imageUrl: 'https://example.com/hairstyle10.jpg',
        type: HairstyleType.braid,
        suitableFaceShapes: ['鹅蛋脸', '瓜子脸', '心形脸'],
        suitableOccasions: ['约会', '派对', '婚礼'],
        difficulty: 4,
        popularity: 432,
      ),
      
      // 通用发型
      Hairstyle(
        id: 'h011',
        name: '丸子头',
        description: '经典丸子头，清爽减龄，百搭发型',
        imageUrl: 'https://example.com/hairstyle11.jpg',
        type: HairstyleType.updo,
        suitableFaceShapes: ['圆脸', '方脸', '长脸', '鹅蛋脸', '瓜子脸', '心形脸'],
        suitableOccasions: ['日常', '约会', '运动'],
        difficulty: 2,
        popularity: 1350,
      ),
      Hairstyle(
        id: 'h012',
        name: '慵懒卷发',
        description: '自然慵懒卷发，随性又有型，适合各种脸型',
        imageUrl: 'https://example.com/hairstyle12.jpg',
        type: HairstyleType.curly,
        suitableFaceShapes: ['圆脸', '方脸', '长脸', '鹅蛋脸', '瓜子脸', '心形脸'],
        suitableOccasions: ['日常', '约会'],
        difficulty: 3,
        popularity: 1450,
      ),
    ];
  }
}
