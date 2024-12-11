import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:innovators/features/marketplace/screens/fetilizers_detail_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FertilizerProductsScreen extends StatefulWidget {
  final String currentLanguage;

  const FertilizerProductsScreen({
    super.key,
    this.currentLanguage = 'en',
  });

  @override
  _FertilizerProductsScreenState createState() =>
      _FertilizerProductsScreenState();
}

class _FertilizerProductsScreenState extends State<FertilizerProductsScreen> {
  List<dynamic> products = [];
  List<dynamic> filteredProducts = [];
  bool isLoading = false;
  bool isSearching = false;
  bool isCachedData = false;

  int currentPage = 1;
  int totalPages = 0;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // Cache key for storing products
  static const String _productsCacheKey = 'cached_fertilizer_products';
  static const String _productsPagesKey = 'cached_fertilizer_total_pages';

  @override
  void initState() {
    super.initState();

    // Try to load cached products first
    _loadCachedProducts();

    _fetchProducts();
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadCachedProducts() async {
    final prefs = await SharedPreferences.getInstance();

    final cachedProductsJson = prefs.getString(_productsCacheKey);
    final cachedTotalPages = prefs.getInt(_productsPagesKey);
    final cacheTimestamp = prefs.getInt('products_cache_timestamp');

    // Example: Invalidate cache after 1 hour
    if (cachedProductsJson != null &&
        cachedTotalPages != null &&
        cacheTimestamp != null &&
        DateTime.now().millisecondsSinceEpoch - cacheTimestamp < 3600000) {
      // Cache is valid
      setState(() {
        products = jsonDecode(cachedProductsJson);
        filteredProducts = List.from(products);
        totalPages = cachedTotalPages;
        isCachedData = true;
      });
      return;
    }

    // Fetch from server if no valid cache
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse(
          'https://fertilizer-api-pdtq.onrender.com/api/products?page=$currentPage&lang=${widget.currentLanguage}&per_page=10');

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Connection timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          // If it's the first page, replace products
          if (currentPage == 1) {
            products = data['products'];
            filteredProducts = List.from(products);
          } else {
            products.addAll(data['products']);
            filteredProducts.addAll(data['products']);
          }

          totalPages = data['total_pages'];
          isLoading = false;
        });

        // Cache the products when successfully fetched
        await _cacheProducts();
      } else {
        _handleFetchError('Failed to load products (${response.statusCode})');
      }
    } catch (e) {
      _handleFetchError(e.toString());
    }
  }

  Future<void> _cacheProducts() async {
    final prefs = await SharedPreferences.getInstance();
    print("Caching");

    await prefs.setString(_productsCacheKey, jsonEncode(products));
    await prefs.setInt(_productsPagesKey, totalPages);
    await prefs.setInt(
        'products_cache_timestamp', DateTime.now().millisecondsSinceEpoch);
  }

  void _handleFetchError(String errorMessage) {
    setState(() {
      isLoading = false;
      isSearching = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Server Timeout."),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _performServerSearch() async {
    if (_searchController.text.isEmpty) return;

    setState(() {
      isLoading = true;
      isSearching = true;
    });

    try {
      final url = Uri.parse(
        'https://fertilizer-api-pdtq.onrender.com/api/search?query=${Uri.encodeComponent(_searchController.text)}&lang=${widget.currentLanguage}',
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Connection timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          filteredProducts = data['results'] ?? [];
          isLoading = false;
          isSearching = false;
        });
      } else {
        _handleFetchError('Search failed (${response.statusCode})');
      }
    } catch (e) {
      _handleFetchError(e.toString());
    }
  }

  TextInputType _getKeyboardTypeForLanguage() {
    switch (widget.currentLanguage) {
      case 'hi':
        return TextInputType.multiline;
      case 'mr':
        return TextInputType.multiline;
      case 'ta':
        return TextInputType.multiline;
      case 'te':
        return TextInputType.multiline;
      default:
        return TextInputType.text;
    }
  }

  void _filterProducts() {
    if (!isSearching) {
      final query = _searchController.text.toLowerCase();
      setState(() {
        filteredProducts = products.where((product) {
          final productName = (product['product_name'] as String).toLowerCase();
          return productName.contains(query);
        }).toList();
      });
    }
  }

  void _loadMoreProducts() {
    if (currentPage < totalPages) {
      setState(() {
        currentPage++;
      });
      _fetchProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              keyboardType: _getKeyboardTypeForLanguage(),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _performServerSearch(),
              decoration: InputDecoration(
                hintText: 'Search Fertilizer Products',
                hintStyle: GoogleFonts.poppins(),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.green),
                          ),
                        ),
                      )
                    : null,
                fillColor: Colors.grey[100],
                filled: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
              ),
            ),
            const SizedBox(height: 20),

            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Fertilizer Products',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[800],
                  ),
                ),
                if (isCachedData)
                  Text(
                    'Offline Mode',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.orange[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // Product List
            Expanded(
              child: filteredProducts.isEmpty && !isLoading
                  ? _buildNoResultsWidget()
                  : ListView.builder(
                      itemCount: isLoading && filteredProducts.isEmpty
                          ? 5
                          : filteredProducts.length +
                              (currentPage < totalPages ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == filteredProducts.length &&
                            currentPage < totalPages) {
                          return _buildLoadMoreButton();
                        }

                        if (isLoading && filteredProducts.isEmpty) {
                          return _buildSkeletonProductWidget();
                        }

                        if (isLoading && index >= filteredProducts.length - 1) {
                          return Column(
                            children: [
                              _buildProductWidget(filteredProducts[index]),
                              _buildSkeletonProductWidget(),
                            ],
                          );
                        }

                        return _buildProductWidget(filteredProducts[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductWidget(dynamic product) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return FertilizerProductDetailsModal(product: product);
          },
          barrierDismissible: true,
          barrierColor: Colors.black.withOpacity(0.5),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.green.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image
                      Hero(
                        tag: 'product_image_${product['id']}',
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                )
                              ]),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              product['product_image'],
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey[200],
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    size: 40,
                                  ),
                                );
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey[200],
                                  child: const Center(
                                      child: CircularProgressIndicator()),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),

                      // Product Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['product_name'],
                              style: GoogleFonts.poppins(
                                color: Colors.green[900],
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '₹${product['product_price']}',
                                  style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[700]),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  child: Text(
                                    product['product_quantity'],
                                    style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.green[900],
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonProductWidget() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: ElevatedButton(
          onPressed: isLoading ? null : _loadMoreProducts,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[700],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  'Load More Products',
                  style: GoogleFonts.poppins(
                      color: Colors.white, fontWeight: FontWeight.w500),
                ),
        ),
      ),
    );
  }
}
