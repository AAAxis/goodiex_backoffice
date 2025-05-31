import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({Key? key}) : super(key: key);

  @override
  _ShopScreenState createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final loadingColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text('navbar.shop'.tr(), style: TextStyle(color: textColor)),
        iconTheme: IconThemeData(color: textColor),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart, color: textColor),
            onPressed: () {
              // TODO: Implement cart navigation
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('categories').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading categories',
                style: TextStyle(color: textColor),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: loadingColor),
            );
          }

          final categories = snapshot.data?.docs ?? [];

          if (categories.isEmpty) {
            return Center(
              child: Text(
                'No categories available',
                style: TextStyle(color: secondaryTextColor, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final categoryData = category.data() as Map<String, dynamic>;
              return Card(
                color: isDark ? Color(0xFF1E1E1E) : Colors.white,
                child: ListTile(
                  title: Text(
                    categoryData['name'] ?? 'Category',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: secondaryTextColor,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => CategoryProductsScreen(
                              categoryId: category.id,
                              categoryName: categoryData['name'] ?? 'Category',
                            ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class CategoryProductsScreen extends StatelessWidget {
  final String categoryId;
  final String categoryName;
  const CategoryProductsScreen({
    required this.categoryId,
    required this.categoryName,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final loadingColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(categoryName, style: TextStyle(color: textColor)),
        iconTheme: IconThemeData(color: textColor),
        centerTitle: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('categories')
                .doc(categoryId)
                .collection('products')
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading products',
                style: TextStyle(color: textColor),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: loadingColor),
            );
          }

          final products = snapshot.data?.docs ?? [];

          if (products.isEmpty) {
            return Center(
              child: Text(
                'No products in this category',
                style: TextStyle(color: secondaryTextColor),
              ),
            );
          }

          return GridView.builder(
            padding: EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final productData = product.data() as Map<String, dynamic>;
              return _buildProductCard(
                productData,
                isDark,
                textColor,
                secondaryTextColor,
                loadingColor,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProductCard(
    Map<String, dynamic> productData,
    bool isDark,
    Color textColor,
    Color secondaryTextColor,
    Color loadingColor,
  ) {
    final cardColor = isDark ? Color(0xFF1E1E1E) : Colors.white;
    final Color borderColor = isDark ? Color(0xFF616161) : Color(0xFFe0e0e0);
    final placeholderColor = isDark ? Colors.grey[800]! : Colors.grey[50]!;
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                color: placeholderColor,
              ),
              child:
                  productData['image_url'] != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: productData['image_url'],
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => Container(
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: loadingColor,
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                          errorWidget:
                              (context, url, error) => Container(
                                child: Center(
                                  child: Text(
                                    'No Image',
                                    style: TextStyle(
                                      color: secondaryTextColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                        ),
                      )
                      : Container(
                        child: Center(
                          child: Text(
                            'No Image',
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
            ),
          ),
          // Product Info
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productData['name'] ?? 'Product',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  if (productData['price'] != null)
                    Text(
                      '\$${productData['price']}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  Spacer(),
                  if (productData['description'] != null)
                    Text(
                      productData['description'],
                      style: TextStyle(fontSize: 12, color: secondaryTextColor),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
