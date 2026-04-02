import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:beauty_advisor/models/membership.dart';
import 'package:beauty_advisor/providers/membership_provider.dart';

/// 会员中心页面
class MembershipScreen extends StatefulWidget {
  const MembershipScreen({super.key});

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen> {
  int _selectedPlanIndex = 1; // 默认选中中间方案

  final List<MembershipPrice> _prices = const [
    MembershipPrice(
      id: 'pro_1month',
      level: MembershipLevel.pro,
      months: 1,
      originalPrice: 29.9,
      currentPrice: 19.9,
    ),
    MembershipPrice(
      id: 'pro_12months',
      level: MembershipLevel.pro,
      months: 12,
      originalPrice: 358.8,
      currentPrice: 168,
      discountLabel: '省190元',
    ),
    MembershipPrice(
      id: 'premium_12months',
      level: MembershipLevel.premium,
      months: 12,
      originalPrice: 598.8,
      currentPrice: 298,
      discountLabel: '最划算',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('会员中心'),
        backgroundColor: const Color(0xFFFF6B9D),
        foregroundColor: Colors.white,
      ),
      body: Consumer<MembershipProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(provider),
                SizedBox(height: 16.h),
                _buildCurrentStatus(provider),
                SizedBox(height: 16.h),
                _buildBenefits(provider),
                SizedBox(height: 16.h),
                _buildPriceCards(),
                SizedBox(height: 24.h),
                _buildPurchaseButton(provider),
                SizedBox(height: 16.h),
                _buildRestoreButton(provider),
                SizedBox(height: 32.h),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(MembershipProvider provider) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF6B9D), Color(0xFFFFB6C1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Center(
              child: Text(
                provider.isPremium ? '👑' : (provider.isPro ? '💎' : '⭐'),
                style: TextStyle(fontSize: 40.sp),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            provider.level.name,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (provider.expireDate != null) ...[
            SizedBox(height: 8.h),
            Text(
              '有效期至 ${_formatDate(provider.expireDate!)}',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white70,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCurrentStatus(MembershipProvider provider) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('今日使用情况', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 16.h),
          _buildUsageRow(
            '脸型分析',
            provider.faceAnalysisCount,
            provider.faceAnalysisLimit,
            Icons.face_retouching_natural,
          ),
          SizedBox(height: 12.h),
          _buildUsageRow(
            '文字推荐',
            provider.recommendationCount,
            provider.recommendationLimit,
            Icons.auto_awesome,
          ),
          if (provider.isPro) ...[
            SizedBox(height: 12.h),
            _buildUsageRow(
              '参考图生成',
              provider.imageRecommendationCount,
              provider.imageRecommendationLimit,
              Icons.image,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUsageRow(String label, int used, int limit, IconData icon) {
    final isUnlimited = limit >= 999;
    final progress = isUnlimited ? 0.0 : used / limit;
    
    return Row(
      children: [
        Icon(icon, size: 20.sp, color: const Color(0xFFFF6B9D)),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label, style: TextStyle(fontSize: 14.sp)),
                  Text(
                    isUnlimited ? '无限制' : '$used/$limit',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
              if (!isUnlimited) ...[
                SizedBox(height: 4.h),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation(Color(0xFFFF6B9D)),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBenefits(MembershipProvider provider) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('会员权益', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 16.h),
          ...MembershipBenefits.all.map((benefit) => _buildBenefitItem(benefit, provider)),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(MembershipBenefit benefit, MembershipProvider provider) {
    final isAvailable = benefit.isAvailableFor(provider.level);
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: isAvailable 
                  ? const Color(0xFFFF6B9D).withOpacity(0.1)
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              benefit.icon,
              size: 18.sp,
              color: isAvailable ? const Color(0xFFFF6B9D) : Colors.grey[400],
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  benefit.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: isAvailable ? Colors.black : Colors.grey[500],
                  ),
                ),
                Text(
                  benefit.description,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          if (benefit.isPremiumOnly)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text('Premium', style: TextStyle(fontSize: 10.sp, color: Colors.brown[700])),
            )
          else if (benefit.isProOnly)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: const Color(0xFF6B9DFF).withOpacity(0.2),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text('Pro', style: TextStyle(fontSize: 10.sp, color: const Color(0xFF6B9DFF))),
            ),
          SizedBox(width: 8.w),
          Icon(
            isAvailable ? Icons.check_circle : Icons.lock,
            size: 20.sp,
            color: isAvailable ? Colors.green : Colors.grey[400],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCards() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('选择套餐', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 12.h),
          Row(
            children: _prices.asMap().entries.map((entry) {
              return Expanded(
                child: _buildPriceCard(entry.value, entry.key == _selectedPlanIndex, entry.key),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard(MembershipPrice price, bool isSelected, int index) {
    return GestureDetector(
      onTap: () => setState(() => _selectedPlanIndex = index),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF6B9D).withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF6B9D) : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            if (price.discountLabel != null)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B9D),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  price.discountLabel!,
                  style: TextStyle(fontSize: 10.sp, color: Colors.white),
                ),
              )
            else
              SizedBox(height: 18.h),
            SizedBox(height: 8.h),
            Text(
              price.level == MembershipLevel.premium ? 'Premium' : 'Pro',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFFFF6B9D) : Colors.black,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              '${price.months}个月',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
            ),
            SizedBox(height: 8.h),
            Text(
              '¥${price.currentPrice.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFFFF6B9D) : Colors.black,
              ),
            ),
            Text(
              '¥${price.originalPrice.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[400],
                decoration: TextDecoration.lineThrough,
              ),
            ),
            Text(
              '¥${price.monthlyPrice.toStringAsFixed(1)}/月',
              style: TextStyle(fontSize: 10.sp, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseButton(MembershipProvider provider) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: SizedBox(
        width: double.infinity,
        height: 48.h,
        child: ElevatedButton(
          onPressed: provider.isLoading ? null : () => _purchase(provider),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B9D),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
          ),
          child: provider.isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('立即开通'),
        ),
      ),
    );
  }

  Widget _buildRestoreButton(MembershipProvider provider) {
    return TextButton(
      onPressed: provider.isLoading ? null : () => provider.restorePurchase(),
      child: Text('恢复购买', style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
    );
  }

  Future<void> _purchase(MembershipProvider provider) async {
    final price = _prices[_selectedPlanIndex];
    final success = await provider.purchaseMembership(price.level, price.months);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('购买成功！'),
          backgroundColor: Color(0xFFFF6B9D),
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
