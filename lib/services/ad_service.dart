import 'package:flutter/foundation.dart';

/// 广告类型
enum AdType {
  splash,     // 开屏广告
  banner,     // Banner广告
  interstitial, // 插屏广告
  rewarded,   // 激励视频广告
}

/// 广告配置
class AdConfig {
  final String adUnitId;
  final bool enabled;
  final int showInterval; // 展示间隔（秒）
  final int maxShowsPerDay; // 每日最大展示次数

  const AdConfig({
    required this.adUnitId,
    this.enabled = true,
    this.showInterval = 30,
    this.maxShowsPerDay = 10,
  });
}

/// 广告服务
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // 广告配置（实际接入时替换为真实广告单元ID）
  static const Map<AdType, AdConfig> _configs = {
    AdType.splash: AdConfig(
      adUnitId: 'splash_ad_unit_id',
      enabled: true,
      maxShowsPerDay: 5,
    ),
    AdType.banner: AdConfig(
      adUnitId: 'banner_ad_unit_id',
      enabled: true,
      showInterval: 60,
      maxShowsPerDay: 20,
    ),
    AdType.interstitial: AdConfig(
      adUnitId: 'interstitial_ad_unit_id',
      enabled: true,
      showInterval: 120,
      maxShowsPerDay: 10,
    ),
    AdType.rewarded: AdConfig(
      adUnitId: 'rewarded_ad_unit_id',
      enabled: true,
      maxShowsPerDay: 999, // 激励广告不限制
    ),
  };

  // 展示次数记录
  final Map<AdType, int> _showCounts = {};
  final Map<AdType, DateTime> _lastShowTimes = {};

  /// 初始化广告SDK
  Future<void> initialize() async {
    // TODO: 初始化真实广告SDK
    // 例如：穿山甲、优量汇、AdMob等
    debugPrint('广告SDK初始化');
  }

  /// 检查是否可以展示广告
  bool canShowAd(AdType type, {bool isPremium = false}) {
    // 会员用户免广告
    if (isPremium) return false;
    
    final config = _configs[type];
    if (config == null || !config.enabled) return false;

    // 检查每日次数限制
    final count = _showCounts[type] ?? 0;
    if (count >= config.maxShowsPerDay) return false;

    // 检查展示间隔
    final lastTime = _lastShowTimes[type];
    if (lastTime != null) {
      final elapsed = DateTime.now().difference(lastTime).inSeconds;
      if (elapsed < config.showInterval) return false;
    }

    return true;
  }

  /// 展示开屏广告
  Future<bool> showSplashAd() async {
    if (!canShowAd(AdType.splash)) return false;
    
    // TODO: 调用真实广告SDK
    debugPrint('展示开屏广告');
    
    _recordShow(AdType.splash);
    return true;
  }

  /// 展示Banner广告
  Future<bool> showBannerAd() async {
    if (!canShowAd(AdType.banner)) return false;
    
    debugPrint('展示Banner广告');
    
    _recordShow(AdType.banner);
    return true;
  }

  /// 展示插屏广告
  Future<bool> showInterstitialAd() async {
    if (!canShowAd(AdType.interstitial)) return false;
    
    debugPrint('展示插屏广告');
    
    _recordShow(AdType.interstitial);
    return true;
  }

  /// 展示激励视频广告
  Future<bool> showRewardedAd({
    required Function() onRewarded,
    Function()? onFailed,
  }) async {
    // 激励广告不限制次数
    debugPrint('展示激励视频广告');
    
    // TODO: 调用真实广告SDK，观看完成后回调 onRewarded
    // 模拟观看成功
    await Future.delayed(const Duration(seconds: 2));
    onRewarded();
    
    return true;
  }

  /// 记录展示
  void _recordShow(AdType type) {
    _showCounts[type] = (_showCounts[type] ?? 0) + 1;
    _lastShowTimes[type] = DateTime.now();
  }

  /// 重置每日计数（通常在凌晨调用）
  void resetDailyCounts() {
    _showCounts.clear();
    debugPrint('广告展示计数已重置');
  }

  /// 获取今日展示次数
  int getShowCount(AdType type) => _showCounts[type] ?? 0;

  /// 获取广告配置
  AdConfig? getConfig(AdType type) => _configs[type];
}
