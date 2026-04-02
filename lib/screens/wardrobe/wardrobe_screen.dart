import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:beauty_advisor/models/wardrobe_item.dart';
import 'package:beauty_advisor/providers/wardrobe_provider.dart';
import 'package:beauty_advisor/providers/user_provider.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: WardrobeCategory.values.length, vsync: this);
    // 初始化衣橱数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initWardrobe();
    });
  }

  Future<void> _initWardrobe() async {
    final userProvider = context.read<UserProvider>();
    final wardrobeProvider = context.read<WardrobeProvider>();
    
    if (userProvider.userId != null) {
      await wardrobeProvider.setUserId(userProvider.userId!);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的衣橱'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: const Color(0xFFFF6B9D),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFFF6B9D),
          tabs: WardrobeCategory.values.map((c) => Tab(text: c.label)).toList(),
        ),
        actions: [
          Consumer<WardrobeProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<WardrobeProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: WardrobeCategory.values.map((category) => 
              _buildCategoryGrid(context, provider, category)
            ).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(context),
        backgroundColor: const Color(0xFFFF6B9D),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context, WardrobeProvider provider, WardrobeCategory category) {
    final items = provider.getByCategory(category);
    if (items.isEmpty) return _buildEmptyState(category);
    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 0.75,
      ),
      itemCount: items.length + 1,
      itemBuilder: (context, index) {
        if (index == items.length) return _buildAddCard(context);
        return _buildItemCard(context, items[index], provider);
      },
    );
  }

  Widget _buildEmptyState(WardrobeCategory category) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(category.icon, size: 64.sp, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text('还没有添加${category.label}', style: TextStyle(fontSize: 16.sp, color: Colors.grey[500])),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () => _showAddItemDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('添加物品'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B9D),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAddItemDialog(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 48.sp, color: Colors.grey[400]),
            SizedBox(height: 8.h),
            Text('添加', style: TextStyle(fontSize: 14.sp, color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, WardrobeItem item, WardrobeProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                  ),
                  child: item.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                          child: Image.network(item.imageUrl!, fit: BoxFit.cover, width: double.infinity),
                        )
                      : Center(child: Icon(item.category.icon, size: 48.sp, color: Colors.grey[400])),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                    if (item.color != null)
                      Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: Text(item.color!, style: TextStyle(fontSize: 12.sp, color: Colors.grey[500])),
                      ),
                  ],
                ),
              ),
            ],
          ),
          // 删除按钮
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red[300], size: 20.sp),
              onPressed: () => _confirmDelete(context, item, provider),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WardrobeItem item, WardrobeProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除「${item.name}」吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () {
              provider.deleteItem(item.id);
              Navigator.pop(ctx);
            },
            child: Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    final userId = context.read<UserProvider>().userId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先登录')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (ctx) => AddWardrobeItemSheet(
        userId: userId,
        onSaved: (item, imageBytes) async {
          final provider = context.read<WardrobeProvider>();
          await provider.addItem(item, imageBytes: imageBytes);
        },
      ),
    );
  }
}

class AddWardrobeItemSheet extends StatefulWidget {
  final String userId;
  final Function(WardrobeItem item, Uint8List? imageBytes) onSaved;

  const AddWardrobeItemSheet({super.key, required this.userId, required this.onSaved});

  @override
  State<AddWardrobeItemSheet> createState() => _AddWardrobeItemSheetState();
}

class _AddWardrobeItemSheetState extends State<AddWardrobeItemSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  WardrobeCategory _selectedCategory = WardrobeCategory.top;
  String? _selectedColor;
  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();

  final List<String> _colors = ['白色', '黑色', '灰色', '蓝色', '红色', '粉色', '黄色', '绿色', '棕色', '米色', '其他'];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, MediaQuery.of(context).viewInsets.bottom + 20.h),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2.r)))),
              SizedBox(height: 20.h),
              Text('添加衣物', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 20.h),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 120.h,
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12.r)),
                  child: _imageBytes != null
                      ? ClipRRect(borderRadius: BorderRadius.circular(12.r), child: Image.memory(_imageBytes!, fit: BoxFit.cover, width: double.infinity))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, color: Colors.grey[400], size: 32.sp),
                            SizedBox(width: 12.w),
                            Text('添加照片（可选）', style: TextStyle(fontSize: 14.sp, color: Colors.grey[500])),
                          ],
                        ),
                ),
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '衣物名称',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                validator: (value) => value == null || value.isEmpty ? '请输入名称' : null,
              ),
              SizedBox(height: 16.h),
              Text('分类', style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                children: WardrobeCategory.values.map((c) {
                  final isSelected = c == _selectedCategory;
                  return ChoiceChip(
                    label: Text(c.label),
                    selected: isSelected,
                    selectedColor: const Color(0xFFFF6B9D).withOpacity(0.2),
                    labelStyle: TextStyle(color: isSelected ? const Color(0xFFFF6B9D) : Colors.grey[700]),
                    onSelected: (selected) => setState(() => _selectedCategory = c),
                  );
                }).toList(),
              ),
              SizedBox(height: 16.h),
              Text('颜色', style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                children: _colors.map((color) {
                  final isSelected = color == _selectedColor;
                  return ChoiceChip(
                    label: Text(color),
                    selected: isSelected,
                    selectedColor: const Color(0xFFFF6B9D).withOpacity(0.2),
                    labelStyle: TextStyle(color: isSelected ? const Color(0xFFFF6B9D) : Colors.grey[700]),
                    onSelected: (selected) => setState(() => _selectedColor = selected ? color : null),
                  );
                }).toList(),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: _saveItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B9D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
                  ),
                  child: const Text('保存'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1024, maxHeight: 1024, imageQuality: 85);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() => _imageBytes = bytes);
    }
  }

  void _saveItem() {
    if (!_formKey.currentState!.validate()) return;

    final newItem = WardrobeItem.fromTemp(
      userId: widget.userId,
      category: _selectedCategory,
      name: _nameController.text,
      imageBytes: _imageBytes,
      color: _selectedColor,
    );

    widget.onSaved(newItem, _imageBytes);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已添加: ${_nameController.text}'), backgroundColor: const Color(0xFFFF6B9D)),
    );
  }
}

// 添加缺失的 icon 属性到枚举
extension WardrobeCategoryExtension on WardrobeCategory {
  IconData get icon {
    switch (this) {
      case WardrobeCategory.top:
        return Icons.checkroom;
      case WardrobeCategory.bottom:
        return Icons.accessibility;
      case WardrobeCategory.dress:
        return Icons.local_mall;
      case WardrobeCategory.shoes:
        return Icons.directions_walk;
      case WardrobeCategory.accessory:
        return Icons.watch;
    }
  }
}