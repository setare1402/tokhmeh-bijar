import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const TokhmehBijarApp());

const Color green = Color(0xFF174D32);
const Color gold = Color(0xFFFFD778);
const Color pageBg = Color(0xFFF8F6EF);
const String adminPassword = '2468';

class Product {
  String id;
  String name;
  String category;
  String emoji;
  String? imagePath;
  double price;
  bool available;
  List<Product> children;

  Product({
    required this.id,
    required this.name,
    required this.category,
    this.emoji = '📦',
    this.imagePath,
    this.price = 0,
    this.available = true,
    List<Product>? children,
  }) : children = children ?? [];

  factory Product.fromJson(Map<String, dynamic> j) => Product(
        id: j['id'] as String,
        name: j['name'] as String,
        category: j['category'] as String? ?? 'سایر',
        emoji: j['emoji'] as String? ?? '📦',
        imagePath: j['imagePath'] as String?,
        price: (j['price'] as num?)?.toDouble() ?? 0,
        available: j['available'] as bool? ?? true,
        children: ((j['children'] as List?) ?? [])
            .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'emoji': emoji,
        'imagePath': imagePath,
        'price': price,
        'available': available,
        'children': children.map((e) => e.toJson()).toList(),
      };
}

class StoreData {
  static const _key = 'tokhmeh_bijar_products_v2';

  static List<Product> defaults() => [
        Product(
          id: 'sunflower',
          name: 'تخمه آفتابگردان',
          category: 'تخمه و دانه',
          emoji: '🌻',
          children: [
            'ساده شور', 'نمکی', 'لیموئی', 'کچاپ', 'شکری', 'سس رنچ',
            'پیاز جعفری', 'گلپر', 'گلپر لیمو', 'پنیری', 'خام'
          ].asMap().entries.map((e) => Product(
                id: 'sunflower_${e.key}',
                name: e.value,
                category: 'تخمه آفتابگردان',
                emoji: '🌻',
              )).toList(),
        ),
        Product(
          id: 'pumpkin',
          name: 'تخمه کدو',
          category: 'تخمه و دانه',
          emoji: '🎃',
          children: ['ساده', 'نمکی', 'دو آتیشه', 'خام'].asMap().entries
              .map((e) => Product(
                    id: 'pumpkin_${e.key}',
                    name: e.value,
                    category: 'تخمه کدو',
                    emoji: '🎃',
                  )).toList(),
        ),
        Product(
          id: 'pistachio',
          name: 'پسته',
          category: 'آجیل و خشکبار',
          emoji: '🥜',
          children: ['خام', 'زعفرانی', 'شور'].asMap().entries
              .map((e) => Product(
                    id: 'pistachio_${e.key}',
                    name: e.value,
                    category: 'پسته',
                    emoji: '🥜',
                  )).toList(),
        ),
        Product(
          id: 'almond',
          name: 'بادام',
          category: 'آجیل و خشکبار',
          emoji: '🌰',
          children: ['درختی', 'زمینی', 'خام'].asMap().entries
              .map((e) => Product(
                    id: 'almond_${e.key}',
                    name: e.value,
                    category: 'بادام',
                    emoji: '🌰',
                  )).toList(),
        ),
        Product(
          id: 'raisin',
          name: 'کشمش',
          category: 'آجیل و خشکبار',
          emoji: '🍇',
          children: ['پلویی', 'سبز', 'طلایی'].asMap().entries
              .map((e) => Product(
                    id: 'raisin_${e.key}',
                    name: e.value,
                    category: 'کشمش',
                    emoji: '🍇',
                  )).toList(),
        ),
        Product(
          id: 'beans',
          name: 'حبوبات',
          category: 'حبوبات',
          emoji: '🫘',
          children: [
            'لوبیا سفید', 'لوبیا قرمز', 'لوبیا چیتی', 'لوبیا چشم‌بلبلی',
            'لوبیا محلی', 'ذرت', 'گندم', 'جو پوست‌کنده', 'جو پرک', 'عدس',
            'لپه', 'گندم مرغی', 'ماش سبز', 'قره ماش', 'ارزن ریز', 'ارزن درشت'
          ].asMap().entries.map((e) => Product(
                id: 'beans_${e.key}',
                name: e.value,
                category: 'حبوبات',
                emoji: '🫘',
              )).toList(),
        ),
      ];

  static Future<List<Product>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return defaults();
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return defaults();
    }
  }

  static Future<void> save(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(products.map((e) => e.toJson()).toList()),
    );
  }
}

class TokhmehBijarApp extends StatelessWidget {
  const TokhmehBijarApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'تخمه بیجار',
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: pageBg,
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

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Product> products = [];
  bool loading = true;
  final List<String> cart = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    products = await StoreData.load();
    if (mounted) setState(() => loading = false);
  }

  Future<void> _save() async {
    await StoreData.save(products);
    if (mounted) setState(() {});
  }

  void _adminLogin() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (d) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('ورود مدیر'),
          content: TextField(
            controller: ctrl,
            obscureText: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'رمز ورود مدیر',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(d),
              child: const Text('انصراف'),
            ),
            FilledButton(
              onPressed: () {
                if (ctrl.text == adminPassword) {
                  Navigator.pop(d);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminPage(
                        products: products,
                        onChanged: _save,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('رمز ورود اشتباه است')),
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

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: GestureDetector(
              onLongPress: _adminLogin,
              child: const Text('تخمه بیجار'),
            ),
            actions: [
              IconButton(
                tooltip: 'ورود مدیر',
                onPressed: _adminLogin,
                icon: const Icon(Icons.admin_panel_settings_outlined),
              ),
            ],
          ),
          body: loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: const BoxDecoration(
                        color: green,
                        borderRadius:
                            BorderRadius.vertical(bottom: Radius.circular(24)),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('به تخمه بیجار خوش آمدید',
                              style: TextStyle(
                                  color: gold,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(height: 6),
                          Text('برای مشاهده محصولات، یک دسته را انتخاب کنید',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: products.isEmpty
                          ? const Center(child: Text('محصولی برای نمایش وجود ندارد'))
                          : GridView.builder(
                              padding: const EdgeInsets.all(12),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: .82,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: products.length,
                              itemBuilder: (context, i) {
                                final p = products[i];
                                return ProductCard(
                                  product: p,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CustomerSubPage(product: p),
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

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) => Card(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: ProductPicture(product: product)),
                const SizedBox(height: 6),
                Text(product.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(product.available ? 'موجود' : 'ناموجود',
                    style: TextStyle(
                        color: product.available ? green : Colors.red)),
                const SizedBox(height: 6),
                const Text('مشاهده زیرمجموعه‌ها',
                    style: TextStyle(fontSize: 11, color: Colors.black54)),
              ],
            ),
          ),
        ),
      );
}

class ProductPicture extends StatelessWidget {
  final Product product;
  const ProductPicture({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    if (product.imagePath != null &&
        File(product.imagePath!).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(File(product.imagePath!),
            fit: BoxFit.cover, width: double.infinity),
      );
    }
    return Center(
      child: Text(product.emoji, style: const TextStyle(fontSize: 54)),
    );
  }
}

class CustomerSubPage extends StatelessWidget {
  final Product product;
  const CustomerSubPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(title: Text(product.name)),
          body: product.children.isEmpty
              ? Center(
                  child: Text(product.available
                      ? '${product.name}\nقیمت هر کیلو: ${product.price.toStringAsFixed(0)} تومان'
                      : 'این محصول ناموجود است',
                      textAlign: TextAlign.center))
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: .82,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: product.children.length,
                  itemBuilder: (context, i) {
                    final child = product.children[i];
                    return Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Expanded(child: ProductPicture(product: child)),
                            Text(child.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Text(child.available ? 'موجود' : 'ناموجود',
                                style: TextStyle(
                                    color: child.available ? green : Colors.red)),
                            Text(child.price > 0
                                ? 'هر کیلو ${child.price.toStringAsFixed(0)} تومان'
                                : 'قیمت: استعلام'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      );
}

class AdminPage extends StatefulWidget {
  final List<Product> products;
  final Future<void> Function() onChanged;
  const AdminPage(
      {super.key, required this.products, required this.onChanged});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  Future<void> _persist() async {
    await widget.onChanged();
    if (mounted) setState(() {});
  }

  Future<String?> _pickAndStoreImage() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1600,
    );
    if (picked == null) return null;
    final dir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${dir.path}/product_images');
    if (!await imagesDir.exists()) await imagesDir.create(recursive: true);
    final ext = picked.name.contains('.') ? picked.name.split('.').last : 'jpg';
    final target = '${imagesDir.path}/img_${DateTime.now().microsecondsSinceEpoch}.$ext';
    return (await File(picked.path).copy(target)).path;
  }

  void _editProduct({Product? product, required List<Product> targetList,
      String? defaultCategory}) {
    final name = TextEditingController(text: product?.name ?? '');
    final category = TextEditingController(
        text: product?.category ?? defaultCategory ?? 'سایر');
    final emoji = TextEditingController(text: product?.emoji ?? '📦');
    final price = TextEditingController(
        text: product == null || product.price == 0
            ? ''
            : product.price.toStringAsFixed(0));
    bool available = product?.available ?? true;
    String? imagePath = product?.imagePath;

    showDialog(
      context: context,
      builder: (d) => StatefulBuilder(
        builder: (context, setDialog) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text(product == null ? 'افزودن محصول' : 'ویرایش محصول'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 120,
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: pageBg,
                        borderRadius: BorderRadius.circular(12)),
                    child: imagePath != null && File(imagePath!).existsSync()
                        ? Image.file(File(imagePath!), fit: BoxFit.contain)
                        : Text(emoji.text.isEmpty ? '📦' : emoji.text,
                            style: const TextStyle(fontSize: 48)),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final path = await _pickAndStoreImage();
                      if (path != null) setDialog(() => imagePath = path);
                    },
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('انتخاب عکس از گالری'),
                  ),
                  TextField(controller: name,
                      decoration: const InputDecoration(labelText: 'نام محصول')),
                  TextField(controller: category,
                      decoration: const InputDecoration(labelText: 'دسته‌بندی')),
                  TextField(controller: emoji,
                      decoration: const InputDecoration(labelText: 'آیکون / ایموجی')),
                  TextField(
                    controller: price,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'قیمت هر کیلو (تومان)'),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('محصول موجود است'),
                    value: available,
                    onChanged: (v) => setDialog(() => available = v),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(d),
                  child: const Text('انصراف')),
              FilledButton(
                onPressed: () async {
                  final parsedPrice = double.tryParse(price.text.trim()) ?? 0;
                  if (name.text.trim().isEmpty || parsedPrice < 0) {
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      const SnackBar(content: Text('نام و قیمت معتبر وارد کنید')));
                    return;
                  }
                  if (product == null) {
                    targetList.add(Product(
                      id: DateTime.now().microsecondsSinceEpoch.toString(),
                      name: name.text.trim(),
                      category: category.text.trim().isEmpty ? 'سایر' : category.text.trim(),
                      emoji: emoji.text.trim().isEmpty ? '📦' : emoji.text.trim(),
                      imagePath: imagePath,
                      price: parsedPrice,
                      available: available,
                    ));
                  } else {
                    product
                      ..name = name.text.trim()
                      ..category = category.text.trim().isEmpty ? 'سایر' : category.text.trim()
                      ..emoji = emoji.text.trim().isEmpty ? '📦' : emoji.text.trim()
                      ..imagePath = imagePath
                      ..price = parsedPrice
                      ..available = available;
                  }
                  Navigator.pop(d);
                  await _persist();
                },
                child: const Text('ذخیره'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _delete(Product p, List<Product> list) {
    showDialog(
      context: context,
      builder: (d) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('حذف محصول'),
          content: Text('«${p.name}» حذف شود؟'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(d),
                child: const Text('انصراف')),
            FilledButton(
              onPressed: () async {
                list.remove(p);
                Navigator.pop(d);
                await _persist();
              },
              child: const Text('حذف'),
            ),
          ],
        ),
      ),
    );
  }

  void _openChildren(Product parent) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminSubPage(
          parent: parent,
          onChanged: _persist,
          onAdd: () => _editProduct(
              targetList: parent.children, defaultCategory: parent.name),
          onEdit: (p) => _editProduct(product: p, targetList: parent.children),
          onDelete: (p) => _delete(p, parent.children),
        ),
      ),
    ).then((_) => _persist());
  }

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(title: const Text('مدیریت محصولات و قیمت‌ها')),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: green,
            foregroundColor: Colors.white,
            onPressed: () => _editProduct(targetList: widget.products),
            icon: const Icon(Icons.add),
            label: const Text('افزودن محصول'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              const Card(
                color: green,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('فهرست محصولات\nبرای مدیریت عکس، قیمت، موجودی و زیرمجموعه‌ها، محصول را باز کنید.',
                      style: TextStyle(color: Colors.white, height: 1.7)),
                ),
              ),
              ...widget.products.map((p) => Card(
                    color: Colors.white,
                    child: ListTile(
                      leading: SizedBox(
                        width: 48,
                        height: 48,
                        child: ProductPicture(product: p),
                      ),
                      title: Text(p.name),
                      subtitle: Text(
                          '${p.available ? 'موجود' : 'ناموجود'} • ${p.children.length} زیرمجموعه'),
                      trailing: const Icon(Icons.chevron_left),
                      onTap: () => _openChildren(p),
                      onLongPress: () => _editProduct(
                          product: p, targetList: widget.products),
                    ),
                  )),
              const SizedBox(height: 80),
            ],
          ),
        ),
      );
}

class AdminSubPage extends StatefulWidget {
  final Product parent;
  final Future<void> Function() onChanged;
  final VoidCallback onAdd;
  final void Function(Product) onEdit;
  final void Function(Product) onDelete;

  const AdminSubPage({
    super.key,
    required this.parent,
    required this.onChanged,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<AdminSubPage> createState() => _AdminSubPageState();
}

class _AdminSubPageState extends State<AdminSubPage> {
  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(title: Text(widget.parent.name)),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: green,
            foregroundColor: Colors.white,
            onPressed: widget.onAdd,
            icon: const Icon(Icons.add),
            label: const Text('افزودن زیرمحصول'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Card(
                color: Colors.white,
                child: ListTile(
                  leading: SizedBox(
                    width: 52,
                    height: 52,
                    child: ProductPicture(product: widget.parent),
                  ),
                  title: Text(widget.parent.name),
                  subtitle: const Text('ویرایش محصول اصلی'),
                  trailing: const Icon(Icons.edit),
                  onTap: () => widget.onEdit(widget.parent),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('زیرمجموعه‌ها',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              if (widget.parent.children.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('هنوز زیرمحصولی ثبت نشده است'),
                ),
              ...widget.parent.children.map((p) => Card(
                    color: Colors.white,
                    child: ListTile(
                      leading: SizedBox(
                        width: 48,
                        height: 48,
                        child: ProductPicture(product: p),
                      ),
                      title: Text(p.name),
                      subtitle: Text(
                          '${p.price.toStringAsFixed(0)} تومان • ${p.available ? 'موجود' : 'ناموجود'}'),
                      onTap: () => widget.onEdit(p),
                      trailing: PopupMenuButton<String>(
                        onSelected: (v) {
                          if (v == 'edit') widget.onEdit(p);
                          if (v == 'delete') widget.onDelete(p);
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'edit', child: Text('ویرایش')),
                          PopupMenuItem(value: 'delete', child: Text('حذف')),
                        ],
                      ),
                    ),
                  )),
              const SizedBox(height: 80),
            ],
          ),
        ),
      );
}