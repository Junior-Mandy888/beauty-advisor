import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:beauty_advisor/models/ecommerce.dart';
import 'package:beauty_advisor/services/ecommerce_service.dart';

/// 商品卡片组件
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => _openProduct(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 商品图片
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                  child: Container(
                    height: 140.h,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: product.imageUrl.startsWith('http')
                        ? CachedNetworkImage(
                            imageUrl: product.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            errorWidget: (_, __, ___) => Icon(Icons.shopping_bag, size: 40.sp, color: Colors.grey[400]),
                          )
                        : Center(
                            child: Icon(Icons.shopping_bag, size: 40.sp, color: Colors.grey[400]),
                          ),
                  ),
                ),
                // 折扣标签
                if (product.discount > 0)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.red[400],
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        '-${product.discount.toInt()}%',
                        style: TextStyle(fontSize: 10.sp, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                // 平台标签
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      product.platform,
                      style: TextStyle(fontSize: 10.sp, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            // 商品信息
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 商品名称
                  Text(
                    product.name,
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  // 描述
                  Text(
                    product.description,
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  // 价格
                  Row(
                    children: [
                      Text(
                        '¥${product.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[400],
                        ),
                      ),
                      if (product.originalPrice != null) ...[
                        SizedBox(width: 4.w),
                        Text(
                          '¥${product.originalPrice!.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey[400],
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 4.h),
                  // 优惠信息
                  if (product.coupon != null)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red[300]!),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                      child: Text(
                        product.coupon!,
                        style: TextStyle(fontSize: 10.sp, color: Colors.red[400]),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openProduct() async {
    final uri = Uri.parse(product.affiliateUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

/// 商品推荐区域
class ProductRecommendationSection extends StatelessWidget {
  final String faceShape;
  final String weather;
  final String recommendation;

  const ProductRecommendationSection({
    super.key,
    required this.faceShape,
    required this.weather,
    required this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: EcommerceService().getRelatedProducts(
        faceShape: faceShape,
        weather: weather,
        recommendation: recommendation,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: Color(0xFFFF6B9D)),
            ),
          );
        }

        final products = snapshot.data ?? [];
        if (products.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Row(
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 18.sp, color: const Color(0xFFFF6B9D)),
                  SizedBox(width: 8.w),
                  Text(
                    '相关推荐',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              height: 240.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 150.w,
                    margin: EdgeInsets.only(right: 12.w),
                    child: ProductCard(product: products[index]),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
