import 'package:flutter/material.dart';

void main() {
  runApp(const TokhmehBijarApp());
}

const Color green = Color(0xFF174D32);
const Color gold = Color(0xFFFFD778);
const Color background = Color(0xFFF8F6EF);

class TokhmehBijarApp extends StatelessWidget {
  const TokhmehBijarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'تخمه بیجار',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(seedColor: green),
        appBarTheme: const AppBarTheme(
          backgroundColor: green,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class Product {
  final String name;
  final String category;
  final String emoji;
  final double price;

  const Product({
    required this.name,
    required this.category,
    required this.emoji,
    this.price = 0,
  });
}

const List<Product> products = [
  Product(name: 'تخمه آفتابگردان', category: 'تخمه و دانه', emoji: '🌻'),
  Product(name: 'تخمه کدو', category: 'تخمه و دانه', emoji: '🎃'),
  Product(name: 'پسته', category: 'آجیل و خشکبار', emoji: '🥜'),
  Product(name: 'بادام', category: 'آجیل و خشکبار', emoji: '🌰'),
  Product(name: 'کشمش', category: 'آجیل و خشکبار', emoji: '🍇'),
  Product(name: 'حبوبات', category: 'حبوبات', emoji: '🫘'),
];

class CartItem {
  final Product product;
  final int weight;

  const CartItem(this.product, this.weight);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedCategory = 'همه محصولات';
  final List<CartItem> cart = [];

  final List<String> categories = [
    'همه محصولات',
    'تخمه و دانه',
    'آجیل و خشکبار',
    'حبوبات',
  ];

  List<Product> get visibleProducts {
    if (selectedCategory == 'همه محصولات') {
      return products;
    }
    return products
        .where((product) => product.category == selectedCategory)
        .toList();
  }

  void addToCart(Product product, int weight) {
    setState(() {
      cart.add(CartItem(product, weight));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} به سبد خرید اضافه شد'),
        backgroundColor: green,
      ),
    );
  }

  void showWeightDialog(Product product) {
    int weight = 5;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(product.name),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('وزن مورد نظر را انتخاب کنید'),
                  const SizedBox(height: 15),
                  Wrap(
                    spacing: 8,
                    children: [5, 10, 20].map((value) {
                      return ChoiceChip(
                        label: Text('$value کیلو'),
                        selected: weight == value,
                        onSelected: (_) {
                          setDialogState(() => weight = value);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('انصراف'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    addToCart(product, weight);
                  },
                  child: const Text('افزودن به سبد'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showCart() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final totalWeight =
                cart.fold<int>(0, (sum, item) => sum + item.weight);

            return Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'سبد خرید',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    if (cart.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(25),
                        child: Text('سبد خرید شما خالی است'),
                      ),
                    ...cart.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;

                      return ListTile(
                        title: Text(item.product.name),
                        subtitle: Text('${item.weight} کیلوگرم'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            setState(() => cart.removeAt(index));
                            setSheetState(() {});
                          },
                        ),
                      );
                    }),
                    if (cart.isNotEmpty) ...[
                      const Divider(),
                      Text('مجموع وزن: $totalWeight کیلوگرم'),
                      const SizedBox(height: 12),
                      const Text(
                        'قیمت: استعلام از فروشگاه',
                        style: TextStyle(color: green),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'هزینه ارسال فعلاً رایگان است',
                        style: TextStyle(color: green),
                      ),
                    ],
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: cart.isEmpty
                            ? null
                            : () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'ثبت نهایی سفارش در نسخه بعدی فعال می‌شود',
                                    ),
                                  ),
                                );
                              },
                        child: const Text('ادامه ثبت سفارش'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'تخمه بیجار',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              onPressed: showCart,
              icon: Badge(
                label: Text('${cart.length}'),
                isLabelVisible: cart.isNotEmpty,
                child: const Icon(Icons.shopping_cart_outlined),
              ),
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: green),
                child: Center(
                  child: Text(
                    '🌻 تخمه بیجار',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.store),
                title: const Text('فروشگاه'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.receipt_long),
                title: const Text('سفارش‌های من'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('هنوز سفارشی ثبت نشده است')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('حساب کاربری'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ورود و ساخت حساب در مرحله بعد فعال می‌شود'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.admin_panel_settings),
                title: const Text('مدیریت'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                color: green,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(25),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'به تخمه بیجار خوش آمدید',
                    style: TextStyle(
                      color: gold,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'خرید آسان و مطمئن محصولات باکیفیت',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 65,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(10),
                children: categories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: selectedCategory == category,
                      selectedColor: gold,
                      onSelected: (_) {
                        setState(() => selectedCategory = category);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.83,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: visibleProducts.length,
                itemBuilder: (context, index) {
                  final product = visibleProducts[index];

                  return Card(
                    color: Colors.white,
                    elevation: 2,
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          product.emoji,
                          style: const TextStyle(fontSize: 55),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'قیمت: استعلام از فروشگاه',
                          style: TextStyle(fontSize: 11),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: green,
                              ),
                              onPressed: () => showWeightDialog(product),
                              child: const Text('انتخاب وزن'),
                            ),
                          ),
                        ),
                      ],
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
}

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('مدیریت تخمه بیجار')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Card(
              child: ListTile(
                leading: Icon(Icons.inventory_2, color: green),
                title: Text('مدیریت محصولات'),
                subtitle: Text('افزودن و ویرایش محصولات'),
              ),
            ),
            const Card(
              child: ListTile(
                leading: Icon(Icons.price_change, color: green),
                title: Text('مدیریت قیمت‌ها'),
                subtitle: Text('ویرایش قیمت محصولات'),
              ),
            ),
            const Card(
              child: ListTile(
                leading: Icon(Icons.people, color: green),
                title: Text('مدیریت مشتریان'),
                subtitle: Text('مشاهده و مدیریت مشتریان'),
              ),
            ),
            const Card(
              child: ListTile(
                leading: Icon(Icons.account_balance_wallet, color: green),
                title: Text('حسابداری'),
                subtitle: Text('مانده حساب و تراکنش‌ها'),
              ),
            ),
            const Card(
              child: ListTile(
                leading: Icon(Icons.chat, color: green),
                title: Text('گفت‌وگو با مشتریان'),
                subtitle: Text('پیام‌های مشتریان'),
              ),
            ),
            const Card(
              child: ListTile(
                leading: Icon(Icons.local_shipping, color: green),
                title: Text('مدیریت سفارش‌ها'),
                subtitle: Text('پیگیری سفارش و ارسال'),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'این بخش در حال حاضر نمونه نمایشی است و هنوز به پایگاه داده متصل نشده است.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}