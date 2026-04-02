import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:beauty_advisor/providers/user_provider.dart';
import 'package:beauty_advisor/services/baidu_ai_service.dart';

class FaceAnalysisScreen extends StatefulWidget {
  const FaceAnalysisScreen({super.key});

  @override
  State<FaceAnalysisScreen> createState() => _FaceAnalysisScreenState();
}

class _FaceAnalysisScreenState extends State<FaceAnalysisScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  Uint8List? _imageBytes;
  bool _isAnalyzing = false;
  FaceAnalysisResult? _result;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('脸型分析'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(),
            SizedBox(height: 24.h),
            _buildAnalyzeButton(),
            SizedBox(height: 24.h),
            if (_error != null) _buildErrorCard(),
            if (_result != null) _buildResultCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('上传照片', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 16.h),
        GestureDetector(
          onTap: _showImageSourceDialog,
          child: Container(
            width: double.infinity,
            height: 300.h,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: _imageBytes != null ? const Color(0xFFFF6B9D) : Colors.grey[300]!,
                width: 2,
              ),
            ),
            child: _imageBytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(14.r),
                    child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                  )
                : SingleChildScrollView(
                    child: Column(
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
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B9D).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 20.sp, color: const Color(0xFFFF6B9D)),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  '请上传正面清晰的五官照片，效果更准确',
                  style: TextStyle(fontSize: 12.sp, color: const Color(0xFFFF6B9D)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyzeButton() {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: ElevatedButton(
        onPressed: _imageBytes != null && !_isAnalyzing ? _analyzeFace : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF6B9D),
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[300],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        ),
        child: _isAnalyzing
            ? SizedBox(
                width: 24.w,
                height: 24.w,
                child: const CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
              )
            : const Text('开始分析'),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(12.r)),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[400]),
          SizedBox(width: 12.w),
          Expanded(child: Text(_error!, style: TextStyle(color: Colors.red[700]))),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFFF6B9D).withOpacity(0.1), const Color(0xFFFFB6C1).withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.face, color: const Color(0xFFFF6B9D), size: 24.sp),
              SizedBox(width: 8.w),
              Text('分析结果', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 24.h),
          _buildResultItem(icon: Icons.face_retouching_natural, label: '脸型', value: _result!.faceShapeChinese, highlight: true),
          SizedBox(height: 16.h),
          _buildResultItem(icon: Icons.cake, label: '预测年龄', value: '${_result!.age} 岁'),
          SizedBox(height: 16.h),
          _buildResultItem(icon: _result!.gender == 'male' ? Icons.male : Icons.female, label: '性别', value: _result!.gender == 'male' ? '男' : '女'),
          SizedBox(height: 16.h),
          _buildResultItem(icon: Icons.emoji_emotions, label: '表情', value: _getExpressionText(_result!.expression)),
          SizedBox(height: 16.h),
          _buildResultItem(icon: Icons.remove_red_eye, label: '眼镜', value: _result!.hasGlasses ? '佩戴眼镜' : '未佩戴眼镜'),
          SizedBox(height: 24.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _saveResult,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFF6B9D),
                side: const BorderSide(color: Color(0xFFFF6B9D)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
              ),
              child: const Text('保存到个人档案'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultItem({required IconData icon, required String label, required String value, bool highlight = false}) {
    return Row(
      children: [
        Icon(icon, size: 20.sp, color: highlight ? const Color(0xFFFF6B9D) : Colors.grey[600]),
        SizedBox(width: 12.w),
        Text(label, style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
            color: highlight ? const Color(0xFFFF6B9D) : Colors.black,
          ),
        ),
      ],
    );
  }

  String _getExpressionText(String expression) {
    const mapping = {'none': '无表情', 'smile': '微笑', 'laugh': '大笑', 'angry': '生气', 'sad': '悲伤', 'surprise': '惊讶'};
    return mapping[expression] ?? expression;
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('选择图片来源', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildSourceOption(
                        icon: Icons.camera_alt,
                        label: '拍照',
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.camera);
                        },
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: _buildSourceOption(
                        icon: Icons.photo_library,
                      label: '相册',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildSourceOption({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12.r)),
        child: Column(
          children: [
            Icon(icon, size: 40.sp, color: const Color(0xFFFF6B9D)),
            SizedBox(height: 8.h),
            Text(label, style: TextStyle(fontSize: 14.sp)),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source, maxWidth: 1024, maxHeight: 1024, imageQuality: 85);
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImage = image;
          _imageBytes = bytes;
          _result = null;
          _error = null;
        });
      }
    } catch (e) {
      setState(() => _error = '选择图片失败: $e');
    }
  }

  Future<void> _analyzeFace() async {
    if (_imageBytes == null) return;

    setState(() {
      _isAnalyzing = true;
      _error = null;
      _result = null;
    });

    try {
      final base64Image = base64Encode(_imageBytes!);
      final result = await BaiduAIService.analyzeFace(base64Image);
      setState(() {
        _result = result;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isAnalyzing = false;
      });
    }
  }

  void _saveResult() {
    if (_result == null) return;
    final userProvider = context.read<UserProvider>();
    userProvider.setFaceShape(_result!.faceShapeChinese);
    userProvider.setAge(_result!.age);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已保存脸型: ${_result!.faceShapeChinese}'), backgroundColor: const Color(0xFFFF6B9D)),
    );
    Navigator.pop(context);
  }
}
