class DemoProduct {
  const DemoProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.mrp,
    required this.rating,
    required this.reviewCount,
    required this.image,
    required this.category,
    this.badge,
  });

  final String id;
  final String name;
  final int price;
  final int mrp;
  final double rating;
  final int reviewCount;
  final String image;
  final String category;
  final String? badge;

  int get discountPercent => mrp > price ? (((mrp - price) / mrp) * 100).round() : 0;
}

class DemoPosItem {
  const DemoPosItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.category,
    this.veg = true,
  });

  final String id;
  final String name;
  final int price;
  final String image;
  final String category;
  final bool veg;
}

class DemoPortfolioProject {
  const DemoPortfolioProject({
    required this.title,
    required this.category,
    required this.image,
  });

  final String title;
  final String category;
  final String image;
}

class DemoTransaction {
  const DemoTransaction({
    required this.merchant,
    required this.amount,
    required this.isCredit,
    required this.time,
    required this.icon,
  });

  final String merchant;
  final double amount;
  final bool isCredit;
  final String time;
  final String icon;
}

abstract final class DemoSampleData {
  static const products = [
    DemoProduct(id: '1', name: 'boAt Airdopes 131 Wireless Earbuds', price: 999, mrp: 2990, rating: 4.3, reviewCount: 284521, image: 'assets/demos/images/products/earbuds.jpg', category: 'Electronics', badge: 'Bestseller'),
    DemoProduct(id: '2', name: 'Noise ColorFit Pro 4 Smart Watch', price: 2499, mrp: 5999, rating: 4.1, reviewCount: 98234, image: 'assets/demos/images/products/watch.jpg', category: 'Electronics'),
    DemoProduct(id: '3', name: 'Premium Leather Laptop Bag', price: 1299, mrp: 3499, rating: 4.4, reviewCount: 12456, image: 'assets/demos/images/products/bag.jpg', category: 'Fashion'),
    DemoProduct(id: '4', name: 'Nike Revolution Running Shoes', price: 3499, mrp: 5995, rating: 4.5, reviewCount: 45678, image: 'assets/demos/images/products/shoes.jpg', category: 'Fashion', badge: 'Deal of the Day'),
    DemoProduct(id: '5', name: 'Philips LED Desk Lamp', price: 899, mrp: 1899, rating: 4.2, reviewCount: 8765, image: 'assets/demos/images/products/lamp.jpg', category: 'Home'),
    DemoProduct(id: '6', name: 'Prestige Coffee Maker', price: 4299, mrp: 6999, rating: 4.0, reviewCount: 3421, image: 'assets/demos/images/products/coffee.jpg', category: 'Home'),
    DemoProduct(id: '7', name: 'Samsung Galaxy M14 5G', price: 12499, mrp: 15999, rating: 4.2, reviewCount: 156789, image: 'assets/demos/images/products/phone.jpg', category: 'Electronics'),
    DemoProduct(id: '8', name: 'Sony WH-CH520 Headphones', price: 3990, mrp: 5490, rating: 4.6, reviewCount: 67890, image: 'assets/demos/images/products/headphones.jpg', category: 'Electronics'),
  ];

  static const posItems = [
    DemoPosItem(id: 'tea', name: 'Masala Chai', price: 25, image: 'assets/demos/images/food/tea.jpg', category: 'Beverages'),
    DemoPosItem(id: 'coffee', name: 'Filter Coffee', price: 40, image: 'assets/demos/images/food/coffee.jpg', category: 'Beverages'),
    DemoPosItem(id: 'juice', name: 'Fresh Orange Juice', price: 60, image: 'assets/demos/images/food/juice.jpg', category: 'Beverages'),
    DemoPosItem(id: 'water', name: 'Mineral Water', price: 20, image: 'assets/demos/images/food/water.jpg', category: 'Beverages'),
    DemoPosItem(id: 'sandwich', name: 'Veg Grilled Sandwich', price: 80, image: 'assets/demos/images/food/sandwich.jpg', category: 'Snacks'),
    DemoPosItem(id: 'dosa', name: 'Masala Dosa', price: 70, image: 'assets/demos/images/food/dosa.jpg', category: 'Meals', veg: true),
    DemoPosItem(id: 'biryani', name: 'Chicken Biryani', price: 180, image: 'assets/demos/images/food/biryani.jpg', category: 'Meals', veg: false),
    DemoPosItem(id: 'cake', name: 'Chocolate Pastry', price: 60, image: 'assets/demos/images/food/cake.jpg', category: 'Snacks'),
  ];

  static const portfolio = [
    DemoPortfolioProject(title: 'Brand Refresh — Kerala Spices', category: 'Branding', image: 'assets/demos/images/portfolio/brand.jpg'),
    DemoPortfolioProject(title: 'E-commerce Launch — ShopLocal', category: 'Web', image: 'assets/demos/images/portfolio/ecommerce.jpg'),
    DemoPortfolioProject(title: 'Mobile Banking App', category: 'App', image: 'assets/demos/images/portfolio/banking.jpg'),
    DemoPortfolioProject(title: 'Festival Campaign Site', category: 'Marketing', image: 'assets/demos/images/portfolio/campaign.jpg'),
    DemoPortfolioProject(title: 'SaaS Analytics Dashboard', category: 'Product', image: 'assets/demos/images/portfolio/saas.jpg'),
    DemoPortfolioProject(title: '3D Product Configurator', category: '3D', image: 'assets/demos/images/portfolio/3d.jpg'),
  ];

  static const categories = ['All', 'Electronics', 'Fashion', 'Home', 'Beauty'];

  static const posCategories = ['All', 'Beverages', 'Snacks', 'Meals'];

  static const ecommerceBanner = 'assets/demos/images/banners/sale.jpg';

  static const transactions = [
    DemoTransaction(merchant: 'Swiggy', amount: -320, isCredit: false, time: 'Today, 2:30 PM', icon: '🍔'),
    DemoTransaction(merchant: 'Amazon Pay', amount: -1299, isCredit: false, time: 'Today, 11:00 AM', icon: '📦'),
    DemoTransaction(merchant: 'Salary Credit', amount: 45000, isCredit: true, time: 'Yesterday', icon: '💰'),
    DemoTransaction(merchant: 'KSEB Electricity', amount: -850, isCredit: false, time: 'Mar 28', icon: '⚡'),
    DemoTransaction(merchant: 'PhonePe Transfer', amount: -500, isCredit: false, time: 'Mar 27', icon: '📱'),
  ];
}
