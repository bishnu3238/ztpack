import 'package:flutter/material.dart';

import 'responsive_utils_advance.dart';

// Main entry point
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Responsive Shop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ScreenUtils.builder(builder: (context) => HomePage()),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<String> _categories = [
    'All',
    'Electronics',
    'Clothing',
    'Home',
    'Beauty',
    'Sports',
  ];

  final List<Product> _products = [
    Product(
      id: 1,
      name: 'Wireless Headphones',
      category: 'Electronics',
      price: 129.99,
      imageUrl: 'headphones',
      rating: 4.5,
    ),
    Product(
      id: 2,
      name: 'Smart Watch',
      category: 'Electronics',
      price: 199.99,
      imageUrl: 'watch',
      rating: 4.2,
    ),
    Product(
      id: 3,
      name: 'Running Shoes',
      category: 'Sports',
      price: 89.99,
      imageUrl: 'shoes',
      rating: 4.7,
    ),
    Product(
      id: 4,
      name: 'Cotton T-Shirt',
      category: 'Clothing',
      price: 24.99,
      imageUrl: 'tshirt',
      rating: 4.0,
    ),
    Product(
      id: 5,
      name: 'Coffee Maker',
      category: 'Home',
      price: 79.99,
      imageUrl: 'coffee',
      rating: 4.8,
    ),
    Product(
      id: 6,
      name: 'Face Serum',
      category: 'Beauty',
      price: 34.99,
      imageUrl: 'serum',
      rating: 4.6,
    ),
    Product(
      id: 7,
      name: 'Bluetooth Speaker',
      category: 'Electronics',
      price: 59.99,
      imageUrl: 'speaker',
      rating: 4.3,
    ),
    Product(
      id: 8,
      name: 'Yoga Mat',
      category: 'Sports',
      price: 29.99,
      imageUrl: 'yoga',
      rating: 4.4,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final responsive = ScreenUtils();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Responsive Shop',
          style: TextStyle(
            fontSize: responsive.getFontSize(20),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, size: responsive.getSize(24)),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart, size: responsive.getSize(24)),
            onPressed: () {},
          ),
          if (responsive.isTablet || responsive.isDesktop)
            IconButton(
              icon: Icon(Icons.favorite, size: responsive.getSize(24)),
              onPressed: () {},
            ),
        ],
      ),
      drawer: responsive.isPhone ? _buildDrawer(responsive) : null,
      body: responsive.valueByDeviceType(
        phone: _buildPhoneLayout(responsive),
        tablet: _buildTabletLayout(responsive),
        desktop: _buildDesktopLayout(responsive),
      ),
      bottomNavigationBar:
          responsive.isPhone
              ? BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                selectedFontSize: responsive.getFontSize(14),
                unselectedFontSize: responsive.getFontSize(12),
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.category),
                    label: 'Categories',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                ],
              )
              : null,
    );
  }

  Widget _buildDrawer(ScreenUtils responsive) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: responsive.getSize(30),
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: responsive.getSize(30),
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: responsive.getVerticalSize(10)),
                Text(
                  'John Doe',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: responsive.getFontSize(18),
                  ),
                ),
                Text(
                  'john.doe@example.com',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: responsive.getFontSize(14),
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(responsive, 'Home', Icons.home),
          _buildDrawerItem(responsive, 'Categories', Icons.category),
          _buildDrawerItem(responsive, 'Orders', Icons.shopping_bag),
          _buildDrawerItem(responsive, 'Wishlist', Icons.favorite),
          _buildDrawerItem(responsive, 'Profile', Icons.person),
          Divider(),
          _buildDrawerItem(responsive, 'Settings', Icons.settings),
          _buildDrawerItem(responsive, 'Help & Support', Icons.help),
          _buildDrawerItem(responsive, 'Logout', Icons.logout),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    ScreenUtils responsive,
    String title,
    IconData icon,
  ) {
    return ListTile(
      leading: Icon(icon, size: responsive.getSize(24)),
      title: Text(
        title,
        style: TextStyle(fontSize: responsive.getFontSize(16)),
      ),
      onTap: () {},
    );
  }

  Widget _buildPhoneLayout(ScreenUtils responsive) {
    return Column(
      children: [
        // Categories
        _buildCategoryBar(responsive),

        // Featured banner
        _buildFeaturedBanner(responsive),

        // Products grid
        Expanded(child: _buildProductsGrid(responsive)),
      ],
    );
  }

  Widget _buildTabletLayout(ScreenUtils responsive) {
    return Row(
      children: [
        // Side navigation
        Container(
          width: responsive.widthPercent(20),
          child: _buildDrawer(responsive),
        ),

        // Main content
        Expanded(
          child: Column(
            children: [
              // Categories
              _buildCategoryBar(responsive),

              // Featured banner
              _buildFeaturedBanner(responsive),

              // Products grid
              Expanded(child: _buildProductsGrid(responsive)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(ScreenUtils responsive) {
    return Row(
      children: [
        // Side navigation
        Container(
          width: responsive.widthPercent(15),
          child: _buildDrawer(responsive),
        ),

        // Main content
        Expanded(
          child: Padding(
            padding: responsive.getPadding(horizontal: 16),
            child: Column(
              children: [
                // Header with search
                _buildDesktopHeader(responsive),

                // Categories bar
                _buildCategoryBar(responsive),

                // Featured banners - horizontal on desktop
                Container(
                  height: responsive.getVerticalSize(200),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildFeaturedCard(
                        responsive,
                        'New Arrivals',
                        Colors.blue,
                      ),
                      SizedBox(width: responsive.getHorizontalSize(16)),
                      _buildFeaturedCard(
                        responsive,
                        'Summer Sale',
                        Colors.orange,
                      ),
                      SizedBox(width: responsive.getHorizontalSize(16)),
                      _buildFeaturedCard(
                        responsive,
                        'Clearance',
                        Colors.purple,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: responsive.getVerticalSize(16)),

                // Section title
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Popular Products',
                    style: TextStyle(
                      fontSize: responsive.getFontSize(20),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                SizedBox(height: responsive.getVerticalSize(8)),

                // Products grid
                Expanded(
                  child: _buildProductsGrid(responsive, crossAxisCount: 4),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopHeader(ScreenUtils responsive) {
    return Container(
      height: responsive.getVerticalSize(60),
      margin: responsive.getMargin(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for products...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: responsive.getBorderRadius(all: 8),
                ),
                contentPadding: responsive.getPadding(
                  vertical: 8,
                  horizontal: 16,
                ),
              ),
              style: TextStyle(fontSize: responsive.getFontSize(16)),
            ),
          ),
          SizedBox(width: responsive.getHorizontalSize(16)),
          _buildIconButton(responsive, Icons.notifications),
          SizedBox(width: responsive.getHorizontalSize(8)),
          _buildIconButton(responsive, Icons.favorite),
          SizedBox(width: responsive.getHorizontalSize(8)),
          _buildIconButton(responsive, Icons.shopping_cart),
          SizedBox(width: responsive.getHorizontalSize(16)),
          CircleAvatar(
            radius: responsive.getSize(18),
            backgroundColor: Colors.grey[200],
            child: Icon(
              Icons.person,
              size: responsive.getSize(24),
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(ScreenUtils responsive, IconData icon) {
    return Container(
      width: responsive.getSize(40),
      height: responsive.getSize(40),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: responsive.getBorderRadius(all: 8),
      ),
      child: IconButton(
        icon: Icon(icon, size: responsive.getSize(20), color: Colors.blue),
        onPressed: () {},
      ),
    );
  }

  // Continue in _HomePageState class...

  Widget _buildCategoryBar(ScreenUtils responsive) {
    return Container(
      height: responsive.getVerticalSize(50),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        padding: responsive.getPadding(horizontal: 16),
        itemBuilder: (context, index) {
          return Padding(
            padding: responsive.getPadding(right: 8),
            child: ChoiceChip(
              label: Text(
                _categories[index],
                style: TextStyle(
                  fontSize: responsive.getFontSize(14),
                  color:
                      _selectedIndex == index ? Colors.white : Colors.black87,
                ),
              ),
              selected: _selectedIndex == index,
              onSelected: (selected) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedBanner(ScreenUtils responsive) {
    return Container(
      height: responsive.getVerticalSize(150),
      margin: responsive.getMargin(all: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue, Colors.blue.shade700]),
        borderRadius: responsive.getBorderRadius(all: 12),
      ),
      child: Stack(
        children: [
          Positioned(
            right: responsive.getHorizontalSize(16),
            top: responsive.getVerticalSize(16),
            bottom: responsive.getVerticalSize(16),
            child: Icon(
              Icons.local_offer,
              size: responsive.getSize(80),
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          Padding(
            padding: responsive.getPadding(all: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Special Offer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: responsive.getFontSize(24),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: responsive.getVerticalSize(8)),
                Text(
                  'Get 20% off on all electronics',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: responsive.getFontSize(16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard(
    ScreenUtils responsive,
    String title,
    Color color,
  ) {
    return Container(
      width: responsive.getHorizontalSize(300),
      padding: responsive.getPadding(all: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: responsive.getBorderRadius(all: 12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: responsive.getFontSize(22),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: responsive.getVerticalSize(8)),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: color,
            ),
            child: Text('Shop Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsGrid(ScreenUtils responsive, {int? crossAxisCount}) {
    return GridView.builder(
      padding: responsive.getPadding(all: 16),
      gridDelegate: responsive.getResponsiveGridDelegate(
        itemWidth: 200,
        itemHeight: 280,
        spacing: 16,
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return _buildProductCard(responsive, product);
      },
    );
  }

  Widget _buildProductCard(ScreenUtils responsive, Product product) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: responsive.getBorderRadius(all: 12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(responsive.getSize(12)),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.image,
                  size: responsive.getSize(64),
                  color: Colors.grey[400],
                ),
              ),
            ),
          ),

          // Product details
          Padding(
            padding: responsive.getPadding(all: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    fontSize: responsive.getFontSize(16),
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: responsive.getVerticalSize(4)),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: responsive.getFontSize(14),
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: responsive.getVerticalSize(4)),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: responsive.getSize(16),
                    ),
                    SizedBox(width: responsive.getHorizontalSize(4)),
                    Text(
                      product.rating.toString(),
                      style: TextStyle(fontSize: responsive.getFontSize(12)),
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
}

class Product {
  final int id;
  final String name;
  final String category;
  final double price;
  final String imageUrl;
  final double rating;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.rating,
  });
}
