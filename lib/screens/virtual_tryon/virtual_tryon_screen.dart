import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:beauty_advisor/models/virtual_tryon.dart';
import 'package:beauty_advisor/services/virtual_tryon_service.dart';
import 'package:beauty_advisor/providers/user_provider.dart';
import 'package:beauty_advisor/providers/membership_provider.dart';

/// AI虚拟试衣页面
class VirtualTryOnScreen extends StatefulWidget {
  const VirtualTryOnScreen({super.key});

  @override
  State<VirtualTryOnScreen> createState() => _VirtualTryOnScreenState();
}

class _VirtualTryOnScreenState extends State<VirtualTryOnScreen> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _selectedImage;
  OutfitStyle _selectedStyle = OutfitStyle.casual;
  String? _selectedOccasion;
  bool _isGenerating = false;
  String? _generatedImageUrl;
  String? _outfitDescription;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI虚拟试衣'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPhotoSection(),
            SizedBox(height: 24.h),
            _buildStyleSection(),
            SizedBox(height: 24.h),
            _buildOccasionSection(),
            SizedBox(height: 24.h),
            _buildGenerateButton(),
            SizedBox(height: 24.h),
            if (_isGenerating) _buildLoadingSection(),
            if (_generatedImageUrl != null) _buildResultSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('上传照片', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 8.h),
        Text('上传一张全身照或半身照，AI将为您生成穿搭效果', 
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[500])),
        SizedBox(height: 16.h),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: 200.h,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: _selectedImage != null ? const Color(0xFFFF6B9D) : Colors.grey[300]!,
                width: 2,
              ),
            ),
            child: _selectedImage != null
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14.r),
                        child: Image.memory(_selectedImage!, fit: BoxFit.cover, width: double.infinity),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedImage = null),
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.close, size: 16.sp, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo, size: 48.sp, color: Colors.grey[400]),
                      SizedBox(height: 12.h),
                      Text('点击上传照片', style: TextStyle(fontSize: 14.sp, color: Colors.grey[500])),
                      SizedBox(height: 4.h),
                      Text('支持拍照或从相册选择', style: TextStyle(fontSize: 12.sp, color: Colors.grey[400])),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildStyleSection() {
    final styles = VirtualTryOnService().getStyleOptions();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('选择风格', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: styles.map((item) {
            final isSelected = _selectedStyle == item['style'];
            return GestureDetector(
              onTap: () => setState(() => _selectedStyle = item['style']),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFF6B9D).withOpacity(0.1) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFFF6B9D) : Colors.transparent,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(item['icon'], style: TextStyle(fontSize: 16.sp)),
                    SizedBox(width: 6.w),
                    Text(
                      item['name'],
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isSelected ? const Color(0xFFFF6B9D) : Colors.grey[700],
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOccasionSection() {
    final occasions = VirtualTryOnService().getOccasionOptions();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('选择场合（可选）', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: occasions.map((occasion) {
            final isSelected = _selectedOccasion == occasion;
            return GestureDetector(
              onTap: () => setState(() => 
                _selectedOccasion = isSelected ? null : occasion
              ),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF6B9DFF).withOpacity(0.1) : Colors.grey[50],
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF6B9DFF) : Colors.grey[200]!,
                  ),
                ),
                child: Text(
                  occasion,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: isSelected ? const Color(0xFF6B9DFF) : Colors.grey[600],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    final membership = context.watch<MembershipProvider>();
    
    return Column(
      children: [
        if (!membership.isPro)
          Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 18.sp, color: Colors.orange),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    '开通会员可解锁无限次试衣',
                    style: TextStyle(fontSize: 12.sp, color: Colors.orange[800]),
                  ),
                ),
              ],
            ),
          ),
        SizedBox(
          width: double.infinity,
          height: 48.h,
          child: ElevatedButton(
            onPressed: _selectedImage != null && !_isGenerating ? _generateTryOn : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B9D),
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[300],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
            ),
            child: _isGenerating
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      ),
                      SizedBox(width: 12.w),
                      const Text('AI正在生成...'),
                    ],
                  )
                : const Text('生成试衣效果'),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingSection() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(color: Color(0xFFFF6B9D)),
          SizedBox(height: 16.h),
          Text('AI正在为您生成穿搭效果...', style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
          SizedBox(height: 8.h),
          Text('预计需要30-60秒', style: TextStyle(fontSize: 12.sp, color: Colors.grey[400])),
        ],
      ),
    );
  }

  Widget _buildResultSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          // 结果图片
          Container(
            height: 300.h,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.checkroom, size: 64.sp, color: const Color(0xFFFF6B9D)),
                  SizedBox(height: 12.h),
                  Text('试衣效果已生成', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          // 描述
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, size: 18.sp, color: const Color(0xFFFF6B9D)),
                    SizedBox(width: 8.w),
                    Text('穿搭推荐', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  _outfitDescription ?? '根据您的身形和选择的风格，AI为您生成了这套穿搭效果。',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600], height: 1.5),
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: 保存到收藏
                        },
                        icon: const Icon(Icons.bookmark_border),
                        label: const Text('收藏'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFFF6B9D),
                          side: const BorderSide(color: Color(0xFFFF6B9D)),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: 分享
                        },
                        icon: const Icon(Icons.share),
                        label: const Text('分享'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B9D),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImage = bytes;
          _generatedImageUrl = null;
          _outfitDescription = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('选择图片失败: $e')),
      );
    }
  }

  Future<void> _generateTryOn() async {
    if (_selectedImage == null) return;

    final membership = context.read<MembershipProvider>();
    
    // 检查会员权限
    if (!membership.isPro) {
      // 免费用户检查次数
      // TODO: 实现次数限制
    }

    setState(() => _isGenerating = true);

    try {
      final userProvider = context.read<UserProvider>();
      
      // 生成穿搭描述
      final description = await VirtualTryOnService().generateOutfitDescription(
        faceShape: userProvider.faceShape ?? '鹅蛋脸',
        weather: null,
        style: _selectedStyle,
        occasion: _selectedOccasion,
      );

      // 模拟生成过程
      await Future.delayed(const Duration(seconds: 3));

      setState(() {
        _outfitDescription = description;
        _generatedImageUrl = 'https://example.com/result.jpg';
        _isGenerating = false;
      });
    } catch (e) {
      setState(() => _isGenerating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('生成失败: $e')),
      );
    }
  }
}
