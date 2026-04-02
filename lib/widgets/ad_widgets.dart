import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:beauty_advisor/services/ad_service.dart';
import 'package:beauty_advisor/providers/membership_provider.dart';

/// 开屏广告组件
class SplashAdWidget extends StatefulWidget {
  final VoidCallback onComplete;
  final int maxDuration;

  const SplashAdWidget({
    super.key,
    required this.onComplete,
    this.maxDuration = 5,
  });

  @override
  State<SplashAdWidget> createState() => _SplashAdWidgetState();
}

class _SplashAdWidgetState extends State<SplashAdWidget> {
  int _countdown = 5;
  Timer? _timer;
  bool _adLoaded = false;

  @override
  void initState() {
    super.initState();
    _countdown = widget.maxDuration;
    _initAd();
  }

  Future<void> _initAd() async {
    final membership = context.read<MembershipProvider>();
    
    // 会员用户跳过广告
    if (membership.isPro) {
      widget.onComplete();
      return;
    }

    // 尝试加载广告
    final canShow = AdService().canShowAd(AdType.splash, isPremium: membership.isPremium);
    
    if (canShow) {
      setState(() => _adLoaded = true);
      _startCountdown();
      await AdService().showSplashAd();
    } else {
      widget.onComplete();
    }
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown <= 1) {
        _skipAd();
      } else {
        setState(() => _countdown--);
      }
    });
  }

  void _skipAd() {
    _timer?.cancel();
    widget.onComplete();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_adLoaded) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      body: Stack(
        children: [
          // 广告内容（模拟）
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.grey[200],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.ads_click, size: 80.sp, color: Colors.grey[400]),
                SizedBox(height: 24.h),
                Text(
                  '广告位',
                  style: TextStyle(fontSize: 24.sp, color: Colors.grey[500]),
                ),
                SizedBox(height: 8.h),
                Text(
                  '实际接入时替换为真实广告',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
          // 跳过按钮
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: GestureDetector(
              onTap: _countdown <= 0 ? _skipAd : null,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  _countdown > 0 ? '跳过 $_countdown' : '跳过',
                  style: TextStyle(fontSize: 14.sp, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Banner广告组件
class BannerAdWidget extends StatelessWidget {
  const BannerAdWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final membership = context.watch<MembershipProvider>();
    
    // 会员用户不显示广告
    if (membership.isPro) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      height: 60.h,
      color: Colors.grey[200],
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.ads_click, size: 20.sp, color: Colors.grey[400]),
            SizedBox(width: 8.w),
            Text(
              'Banner广告位',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}

/// 插屏广告混入
mixin InterstitialAdMixin<T extends StatefulWidget> on State<T> {
  bool _hasShownAd = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tryShowAd();
  }

  Future<void> _tryShowAd() async {
    if (_hasShownAd) return;
    
    final membership = context.read<MembershipProvider>();
    if (membership.isPro) return;

    final canShow = AdService().canShowAd(AdType.interstitial, isPremium: membership.isPremium);
    if (canShow) {
      _hasShownAd = true;
      await AdService().showInterstitialAd();
    }
  }
}

/// 激励广告按钮
class RewardedAdButton extends StatelessWidget {
  final String label;
  final Function() onRewarded;
  final IconData? icon;

  const RewardedAdButton({
    super.key,
    required this.label,
    required this.onRewarded,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _showRewardedAd(context),
      icon: Icon(icon ?? Icons.play_circle_outline, size: 18.sp),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFFF6B9D),
        side: const BorderSide(color: Color(0xFFFF6B9D)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      ),
    );
  }

  Future<void> _showRewardedAd(BuildContext context) async {
    await AdService().showRewardedAd(
      onRewarded: onRewarded,
      onFailed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('广告加载失败，请稍后重试')),
        );
      },
    );
  }
}

/// 推荐页顶部广告条
class RecommendationAdBanner extends StatelessWidget {
  const RecommendationAdBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final membership = context.watch<MembershipProvider>();
    
    if (membership.isPro) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFFFB74D).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB74D),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text('AD', style: TextStyle(fontSize: 10.sp, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              '开通会员，享受无广告清爽体验',
              style: TextStyle(fontSize: 12.sp, color: Colors.orange[800]),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/membership'),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              minimumSize: Size.zero,
            ),
            child: Text('去看看', style: TextStyle(fontSize: 12.sp, color: const Color(0xFFFF6B9D))),
          ),
        ],
      ),
    );
  }
}
