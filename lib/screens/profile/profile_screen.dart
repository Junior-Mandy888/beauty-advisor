import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:beauty_advisor/providers/user_provider.dart';
import 'package:beauty_advisor/services/weather_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('个人中心'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditDialog(context),
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, user, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                // 头像和昵称
                _buildProfileHeader(context, user),
                SizedBox(height: 24.h),
                
                // 个人信息卡片
                _buildInfoCard(context, user),
                SizedBox(height: 24.h),
                
                // 功能列表
                _buildMenuList(context, user),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildProfileHeader(BuildContext context, UserProvider user) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _showEditDialog(context),
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50.r,
                  backgroundColor: const Color(0xFFFF6B9D).withOpacity(0.2),
                  backgroundImage: user.avatarUrl != null
                      ? NetworkImage(user.avatarUrl!)
                      : null,
                  child: user.avatarUrl == null
                      ? Icon(Icons.person, size: 48.sp, color: const Color(0xFFFF6B9D))
                      : null,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF6B9D),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.edit, size: 16.sp, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            user.nickname ?? '点击编辑',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (user.faceShape != null)
                Container(
                  margin: EdgeInsets.only(right: 8.w),
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B9D).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text('脸型: ${user.faceShape}', style: TextStyle(fontSize: 12.sp, color: const Color(0xFFFF6B9D))),
                ),
              if (user.city != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on, size: 14.sp, color: Colors.blue),
                      SizedBox(width: 4.w),
                      Text(user.city!, style: TextStyle(fontSize: 12.sp, color: Colors.blue)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoCard(BuildContext context, UserProvider user) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(
            context,
            icon: Icons.cake,
            label: '年龄',
            value: user.age?.toString() ?? '未设置',
            onTap: () => _showAgePicker(context, user),
          ),
          Divider(height: 24.h),
          _buildInfoRow(
            context,
            icon: Icons.face,
            label: '脸型',
            value: user.faceShape ?? '未分析',
            onTap: user.faceShape == null ? () => context.push('/face-analysis') : null,
          ),
          Divider(height: 24.h),
          _buildInfoRow(
            context,
            icon: Icons.wc,
            label: '性别',
            value: _getGenderText(user.gender),
            onTap: () => _showGenderPicker(context, user),
          ),
          Divider(height: 24.h),
          _buildInfoRow(
            context,
            icon: Icons.location_city,
            label: '城市',
            value: user.city ?? '未设置',
            onTap: () => _showCityPicker(context, user),
          ),
          Divider(height: 24.h),
          _buildInfoRow(
            context,
            icon: Icons.phone,
            label: '手机号码',
            value: user.phone ?? '未绑定',
            onTap: () => _showPhoneDialog(context, user),
          ),
        ],
      ),
    );
  }
  
  String _getGenderText(String? gender) {
    if (gender == null) return '未设置';
    switch (gender) {
      case 'male':
        return '男';
      case 'female':
        return '女';
      default:
        return '未设置';
    }
  }
  
  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B9D).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, size: 20.sp, color: const Color(0xFFFF6B9D)),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.grey[500])),
                  SizedBox(height: 2.h),
                  Text(value, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right, size: 20.sp, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMenuList(BuildContext context, UserProvider user) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.checkroom,
            title: '我的衣橱',
            subtitle: '管理您的衣物',
            onTap: () => context.push('/wardrobe'),
          ),
          Divider(height: 1.h, indent: 56.w),
          _buildMenuItem(
            icon: Icons.history,
            title: '推荐历史',
            subtitle: '查看过往推荐记录',
            onTap: () => context.push('/recommendation'),
          ),
          Divider(height: 1.h, indent: 56.w),
          _buildMenuItem(
            icon: Icons.info_outline,
            title: '关于',
            subtitle: '版本 1.0.0',
            onTap: () => _showAboutDialog(context),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, color: Colors.grey[700]),
      ),
      title: Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12.sp, color: Colors.grey[500])),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
      onTap: onTap,
    );
  }
  
  // 编辑昵称对话框
  void _showEditDialog(BuildContext context) {
    final user = context.read<UserProvider>();
    final controller = TextEditingController(text: user.nickname ?? '');
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('编辑昵称'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: '请输入昵称',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
          ),
          maxLength: 20,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              user.setNickname(controller.text.trim());
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B9D),
              foregroundColor: Colors.white,
            ),
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
  
  // 年龄选择
  void _showAgePicker(BuildContext context, UserProvider user) {
    final ages = List.generate(60, (i) => i + 18);
    final currentAge = user.age ?? 25;
    
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (ctx) => Container(
        height: 300.h,
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Text('选择年龄', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 16.h),
            Expanded(
              child: ListView.builder(
                itemCount: ages.length,
                itemBuilder: (ctx, index) {
                  final age = ages[index];
                  final isSelected = age == currentAge;
                  return ListTile(
                    title: Text('$age 岁', textAlign: TextAlign.center),
                    selected: isSelected,
                    selectedTileColor: const Color(0xFFFF6B9D).withOpacity(0.1),
                    onTap: () {
                      user.setAge(age);
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 性别选择
  void _showGenderPicker(BuildContext context, UserProvider user) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (ctx) => Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('选择性别', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 16.h),
            ListTile(
              leading: const Icon(Icons.male, color: Colors.blue),
              title: const Text('男'),
              onTap: () {
                user.setGender('male');
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.female, color: Colors.pink),
              title: const Text('女'),
              onTap: () {
                user.setGender('female');
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  // 城市选择
  void _showCityPicker(BuildContext context, UserProvider user) {
    final cities = WeatherService.getSupportedCities();
    final currentCity = user.city ?? '广州';
    
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (ctx) => Container(
        height: 400.h,
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Text('选择城市', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 16.h),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8.w,
                  mainAxisSpacing: 8.h,
                  childAspectRatio: 2.5,
                ),
                itemCount: cities.length,
                itemBuilder: (ctx, index) {
                  final city = cities[index];
                  final isSelected = city == currentCity;
                  return InkWell(
                    onTap: () {
                      user.setCity(city);
                      Navigator.pop(ctx);
                      // 刷新天气
                      context.read<UserProvider>().reload();
                    },
                    borderRadius: BorderRadius.circular(8.r),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFFF6B9D) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Center(
                        child: Text(
                          city,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 手机号码绑定
  void _showPhoneDialog(BuildContext context, UserProvider user) {
    final controller = TextEditingController(text: user.phone ?? '');
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('绑定手机号码'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: '请输入手机号码',
                prefixText: '+86 ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
              ),
              keyboardType: TextInputType.phone,
              maxLength: 11,
            ),
            SizedBox(height: 8.h),
            Text(
              '绑定手机号码后可同步数据到其他设备',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              final phone = controller.text.trim();
              // 简单验证
              if (phone.isNotEmpty && !RegExp(r'^1[3-9]\d{9}$').hasMatch(phone)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('请输入正确的手机号码')),
                );
                return;
              }
              user.setPhone(phone);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(phone.isEmpty ? '已解绑手机号码' : '手机号码绑定成功'),
                  backgroundColor: const Color(0xFFFF6B9D),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B9D),
              foregroundColor: Colors.white,
            ),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
  
  // 关于对话框
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B9D),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Icons.auto_awesome, color: Colors.white, size: 24.sp),
            ),
            SizedBox(width: 12.w),
            const Text('美妆穿搭顾问'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('版本: 1.0.0', style: TextStyle(color: Colors.grey[600])),
            SizedBox(height: 12.h),
            const Text('基于 AI 的智能美妆穿搭推荐应用'),
            SizedBox(height: 8.h),
            const Text('功能：'),
            Text('• 脸型分析', style: TextStyle(color: Colors.grey[600])),
            Text('• 智能推荐', style: TextStyle(color: Colors.grey[600])),
            Text('• 穿搭参考图', style: TextStyle(color: Colors.grey[600])),
            Text('• 衣橱管理', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
