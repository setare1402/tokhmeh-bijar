
import 'package:flutter/material.dart';

void main() {
  runApp(const TokhmehBijarApp());
}

const Color green = Color(0xFF174D32);
const Color gold = Color(0xFFFFD778);
const Color background = Color(0xFFF8F6EF);
const String adminPassword = '2468';

class Product {
  String name;
  String category;
  String emoji;
  double price;
  bool available;

  Product({
    required this.name,
    required this.category,
    required this.emoji,
    this.price = 0,
    this.available = true,
  });
}

class CartItem {
  final Product product;
  final double weight;

  CartItem(this.product, this.weight);
}

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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Product> products = [
    Product(name: 'تخمه آفتابگردان', category: 'تخمه و دانه', emoji: '🌻'),
    Product(name: 'تخمه کدو', category: 'تخمه و دانه', emoji: '🎃'),
    Product(name: 'پسته', category: 'آجیل و خشکبار', emoji: '🥜'),
    Product(name: 'بادام', category: 'آجیل و خشکبار', emoji: '🌰'),
    Product(name: 'کشمش', category: 'آجیل و خشکبار', emoji: '🍇'),
    Product(name: 'حبوبات', category: 'حبوبات', emoji: '🫘'),
  ];

  final List<CartItem> cart = [];
  String selectedCategory = 'همه محصولات';

  List<String> get categories {
    final result = <String>['همه محصولات'];
    for (final product in products) {
      if (!result.contains(product.category)) {
        result.add(product.category);
      }
    }
    return result;
  }

  List<Product> get visibleProducts {
    if (selectedCategory == 'همه محصولات') {
      return products;
    }
    return products
        .where((product) => product.category == selectedCategory)
        .toList();
  }

  void openAdminLogin() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('ورود مدیر'),
          content: TextField(
            controller: controller,
            obscureText: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'رمز ورود مدیر',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('انصراف'),
            ),
            FilledButton(
              onPressed: () {
                if (controller.text == adminPassword) {
                  Navigator.pop(dialogContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminPage(
                        products: products,
                        onChanged: () => setState(() {}),
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('رمز ورود اشتباه است'),
                    ),
                  );
                }
              },
              child: const Text('ورود'),
            ),
          ],
        ),
      ),
    );
  }

  void addToCart(Product product, double weight) {
    if (!product.available) return;

    setState(() {
      cart.add(CartItem(product, weight));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} به سبد اضافه شد')),
    );
  }

  void showWeightDialog(Product product) {
    double weight = 5;
    final customController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text(product.name),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('وزن مورد نظر را انتخاب کنید'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [5, 10, 20].map((value) {
                    return ChoiceChip(
                      label: Text('$value کیلو'),
                      selected: weight == value.toDouble(),
                      onSelected: (_) {
                        setDialogState(() {
                          weight = value.toDouble();
                          customController.clear();
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: customController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'وزن دلخواه به کیلوگرم',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    final parsed = double.tryParse(value);
                    if (parsed != null && parsed > 0) {
                      setDialogState(() => weight = parsed);
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('انصراف'),
              ),
              FilledButton(
                onPressed: () {
                  if (weight <= 0) return;
                  Navigator.pop(dialogContext);
                  addToCart(product, weight);
                },
                child: const Text('افزودن به سبد'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showCart() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder: (context, setSheetState) {
            final totalWeight = cart.fold<double>(
              0,
              (sum, item) => sum + item.weight,
            );

            return Padding(
              padding: const EdgeInsets.all(18),
              child: SafeArea(
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
                    const SizedBox(height: 12),
                    if (cart.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('سبد خرید خالی است'),
                      ),
                    ...cart.asMap().entries.map((entry) {
                      final item = entry.value;
                      return ListTile(
                        title: Text(item.product.name),
                        subtitle: Text('${item.weight} کیلوگرم'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            setState(() {
                              cart.removeAt(entry.key);
                            });
                            setSheetState(() {});
                          },
                        ),
                      );
                    }),
                    if (cart.isNotEmpty) ...[
                      const Divider(),
                      Text('مجموع وزن: $totalWeight کیلوگرم'),
                      const Text('قیمت نهایی پس از استعلام اعلام می‌شود'),
                    ],
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: cart.isEmpty
                            ? null
                            : () {
                                Navigator.pop(sheetContext);
                                ScaffoldMessenger.of(this.context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'ثبت سفارش آنلاین هنوز به سرور متصل نشده است',
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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: GestureDetector(
            onLongPress: openAdminLogin,
            child: const Text(
              'تخمه بیجار',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
                leading: const Icon(Icons.shopping_bag_outlined),
                title: const Text('سبد خرید'),
                onTap: () {
                  Navigator.pop(context);
                  showCart();
                },
              ),
              const ListTile(
                leading: Icon(Icons.person_outline),
                title: Text('حساب کاربری'),
                subtitle: Text('پس از اتصال سرور فعال می‌شود'),
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
                    'خرید آسان محصولات باکیفیت',
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
                  childAspectRatio: 0.82,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: visibleProducts.length,
                itemBuilder: (context, index) {
                  final product = visibleProducts[index];

                  return Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            product.emoji,
                            style: const TextStyle(fontSize: 48),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            product.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            product.available ? 'موجود' : 'ناموجود',
                            style: TextStyle(
                              color: product.available ? green : Colors.red,
                            ),
                          ),
                          Text(
                            product.price > 0
                                ? 'هر کیلو: ${product.price.toStringAsFixed(0)} تومان'
                                : 'قیمت: استعلام',
                            style: const TextStyle(fontSize: 11),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: product.available
                                  ? () => showWeightDialog(product)
                                  : null,
                              child: Text(
                                product.available
                                    ? 'انتخاب وزن'
                                    : 'ناموجود',
                              ),
                            ),
                          ),
                        ],
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
}

class AdminPage extends StatefulWidget {
  final List<Product> products;
  final VoidCallback onChanged;

  const AdminPage({
    super.key,
    required this.products,
    required this.onChanged,
  });

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  void refresh() {
    setState(() {});
    widget.onChanged();
  }

  void editProduct([Product? product]) {
    final nameController = TextEditingController(
      text: product?.name ?? '',
    );
    final categoryController = TextEditingController(
      text: product?.category ?? 'تخمه و دانه',
    );
    final emojiController = TextEditingController(
      text: product?.emoji ?? '🌻',
    );
    final priceController = TextEditingController(
      text: product == null || product.price == 0
          ? ''
          : product.price.toStringAsFixed(0),
    );

    bool available = product?.available ?? true;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text(
              product == null ? 'افزودن محصول' : 'ویرایش محصول',
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'نام محصول',
                    ),
                  ),
                  TextField(
                    controller: categoryController,
                    decoration: const InputDecoration(
                      labelText: 'دسته‌بندی',
                    ),
                  ),
                  TextField(
                    controller: emojiController,
                    decoration: const InputDecoration(
                      labelText: 'نشانه محصول',
                    ),
                  ),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'قیمت هر کیلو به تومان',
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('کالا موجود است'),
                    value: available,
                    onChanged: (value) {
                      setDialogState(() => available = value);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('انصراف'),
              ),
              FilledButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  final category = categoryController.text.trim();
                  final emoji = emojiController.text.trim();
                  final price = double.tryParse(
                        priceController.text.trim(),
                      ) ??
                      0;

                  if (name.isEmpty || price < 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('نام و قیمت معتبر وارد کنید'),
                      ),
                    );
                    return;
                  }

                  if (product == null) {
                    widget.products.add(
                      Product(
                        name: name,
                        category: category.isEmpty ? 'سایر' : category,
                        emoji: emoji.isEmpty ? '📦' : emoji,
                        price: price,
                        available: available,
                      ),
                    );
                  } else {
                    product.name = name;
                    product.category =
                        category.isEmpty ? 'سایر' : category;
                    product.emoji = emoji.isEmpty ? '📦' : emoji;
                    product.price = price;
                    product.available = available;
                  }

                  Navigator.pop(dialogContext);
                  refresh();
                },
                child: const Text('ذخیره'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void deleteProduct(Product product) {
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('حذف محصول'),
          content: Text('آیا محصول «${product.name}» حذف شود؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('انصراف'),
            ),
            FilledButton(
              onPressed: () {
                widget.products.remove(product);
                Navigator.pop(dialogContext);
                refresh();
              },
              child: const Text('حذف'),
            ),
          ],
        ),
      ),
    );
  }

  void showInfoSection(
    String title,
    IconData icon,
    String message,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(title: Text(title)),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 60, color: green),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(message, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    const Text(
                      'این بخش هنوز به سرور و پایگاه داده متصل نشده است.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget sectionCard(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: green, size: 30),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('پنل مدیریت تخمه بیجار'),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: green,
          foregroundColor: Colors.white,
          onPressed: () => editProduct(),
          icon: const Icon(Icons.add),
          label: const Text('افزودن محصول'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(14),
          children: [
            Card(
              color: green,
              child: const Padding(
                padding: EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'خوش آمدید مدیر',
                      style: TextStyle(
                        color: gold,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'مدیریت فروشگاه تخمه بیجار',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            sectionCard(
              'مدیریت محصولات و قیمت‌ها',
              'افزودن، ویرایش، حذف و تعیین موجودی کالا',
              Icons.inventory_2,
              () => showInfoSection(
                'مدیریت محصولات',
                Icons.inventory_2,
                'فهرست محصولات در پایین همین صفحه قرار دارد.',
              ),
            ),
            sectionCard(
              'مدیریت سفارش‌ها',
              'مشاهده و پیگیری سفارش‌های مشتریان',
              Icons.receipt_long,
              () => showInfoSection(
                'مدیریت سفارش‌ها',
                Icons.receipt_long,
                'ثبت سفارش هنوز پیاده‌سازی نشده است.',
              ),
            ),
            sectionCard(
              'مدیریت مشتریان',
              'اطلاعات و حساب مشتریان',
              Icons.people,
              () => showInfoSection(
                'مدیریت مشتریان',
                Icons.people,
                'فهرست مشتریان پس از راه‌اندازی ورود فعال می‌شود.',
              ),
            ),
            sectionCard(
              'حسابداری',
              'پرداخت‌ها، بدهی‌ها و مانده حساب',
              Icons.account_balance_wallet,
              () => showInfoSection(
                'حسابداری',
                Icons.account_balance_wallet,
                'ثبت تراکنش و مانده حساب هنوز پیاده‌سازی نشده است.',
              ),
            ),
            sectionCard(
              'گفت‌وگو با مشتریان',
              'پیام‌های خصوصی مشتریان',
              Icons.chat,
              () => showInfoSection(
                'گفت‌وگو با مشتریان',
                Icons.chat,
                'گفت‌وگوی آنلاین هنوز پیاده‌سازی نشده است.',
              ),
            ),
            sectionCard(
              'مدیریت کارمندان',
              'تعریف کارمند و سطح دسترسی',
              Icons.badge,
              () => showInfoSection(
                'مدیریت کارمندان',
                Icons.badge,
                'تعریف حساب و سطح دسترسی هنوز پیاده‌سازی نشده است.',
              ),
            ),
            const Divider(height: 28),
            const Text(
              'فهرست محصولات',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (widget.products.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text('هنوز محصولی ثبت نشده است'),
              ),
            ...widget.products.map((product) {
              return Card(
                child: ListTile(
                  leading: Text(
                    product.emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                  title: Text(product.name),
                  subtitle: Text(
                    '${product.category} | '
                    '${product.price.toStringAsFixed(0)} تومان | '
                    '${product.available ? 'موجود' : 'ناموجود'}',
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        editProduct(product);
                      } else if (value == 'delete') {
                        deleteProduct(product);
                      } else if (value == 'stock') {
                        product.available = !product.available;
                        refresh();
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('ویرایش و تغییر قیمت'),
                      ),
                      const PopupMenuItem(
                        value: 'stock',
                        child: Text('تغییر موجودی'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('حذف محصول'),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
