import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../core/constants/app_routes.dart';
import '../auth/auth_service.dart';
import '../models/cart_item.dart';
import '../screens/receipt_view.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../services/order_service.dart';
import '../services/product_service.dart';
import '../store/product_grid.dart';
import '../widgets/store_header.dart';
import 'cart_panel.dart';
import 'billing_summary.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final AuthService _authService = AuthService();
  final OrderService _orderService = OrderService();
  final ProductService _productService = ProductService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<CartItem> cart = [];
  String paymentMethod = 'Cash';
  String searchQuery = '';
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _productService.seedDefaultProductsIfEmpty();
  }

  Future<void> _playBeep() async {
    try {
      await _audioPlayer.play(AssetSource('beep.mp3'));
    } catch (_) {
      // Ignore sound errors so UI still functions.
    }
  }

  void addToCart(ProductModel product) {
    if (product.stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product is out of stock')));
      return;
    }
    final id = product.id;
    final name = product.name;
    final price = product.price;
    final index = cart.indexWhere((item) => item.id == id);
    if (index >= 0) {
      setState(() => cart[index].quantity++);
    } else {
      setState(() => cart.add(CartItem(id: id, name: name, price: price)));
    }
    _playBeep();
  }

  void increase(CartItem item) => setState(() => item.quantity++);

  void decrease(CartItem item) {
    setState(() {
      if (item.quantity > 1) {
        item.quantity--;
      } else {
        cart.remove(item);
      }
    });
  }

  void removeItem(CartItem item) => setState(() => cart.remove(item));

  double get subtotal => cart.fold(0.0, (sum, item) => sum + item.total);
  double get tax => subtotal * 0.05;
  double get total => subtotal + tax;

  Stream<QuerySnapshot<Map<String, dynamic>>> get todayOrdersStream {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    return FirebaseFirestore.instance
        .collection('orders')
        .where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .snapshots();
  }

  Future<Map<String, String>?> _showCustomerDialog() async {
    final nameController = TextEditingController();
    final mobileController = TextEditingController();
    String? errorText;
    bool isValid = false;

    bool validate(String mobile) {
      if (mobile.isEmpty) return false;
      final digits = RegExp(r'^\d{10}$');
      return digits.hasMatch(mobile);
    }

    return showDialog<Map<String, String>?>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Customer details'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration:
                      const InputDecoration(labelText: 'Customer Name (optional)'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: mobileController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Mobile Number'),
                  onChanged: (value) {
                    final valid = validate(value.trim());
                    setState(() {
                      isValid = valid;
                      errorText = valid
                          ? null
                          : 'Please enter a valid 10-digit mobile number';
                    });
                  },
                ),
                if (errorText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(errorText!,
                        style: const TextStyle(color: Colors.red, fontSize: 12)),
                  ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text('Cancel')),
              ElevatedButton(
                onPressed: isValid
                    ? () {
                        Navigator.pop(context, {
                          'name': nameController.text.trim(),
                          'mobile': mobileController.text.trim(),
                        });
                      }
                    : null,
                child: const Text('Continue'),
              ),
            ],
          );
        });
      },
    );
  }

  Future<void> checkout() async {
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Cart is empty')));
      return;
    }

    final customerDetails = await _showCustomerDialog();
    if (customerDetails == null) {
      return;
    }

    final customerName = customerDetails['name']?.trim() ?? '';
    final customerMobile = customerDetails['mobile']?.trim() ?? '';

    // save or find customer in Firestore
    final customerCollection = FirebaseFirestore.instance.collection('customers');
    final existing = await customerCollection
        .where('mobile', isEqualTo: customerMobile)
        .limit(1)
        .get();
    if (existing.docs.isEmpty) {
      await customerCollection.add({
        'name': customerName,
        'mobile': customerMobile,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    final order = OrderModel(
      orderId: DateTime.now().millisecondsSinceEpoch.toString(),
      items: cart
          .map((item) => {
                'productId': item.id,
                'name': item.name,
                'quantity': item.quantity,
                'unitPrice': item.price,
                'lineTotal': item.total,
              })
          .toList(),
      subtotal: subtotal,
      tax: tax,
      total: total,
      paymentMethod: paymentMethod,
      createdAt: Timestamp.now(),
      customerName: customerName,
      customerMobile: customerMobile,
    );

    final stockUpdates =
        cart.map((item) => {'id': item.id, 'quantity': item.quantity}).toList();
    await _orderService.createOrder(order, stockUpdates);
    if (mounted) {
      setState(() => cart.clear());
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bill generated and stock updated')));
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ReceiptView(order: order),
              fullscreenDialog: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          StoreHeader(
            onAdmin: () =>
                Navigator.pushNamed(context, AppRoutes.adminProducts),
            onLogout: () async {
              await _authService.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              }
            },
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: LayoutBuilder(builder: (context, constraints) {
                final isWide = constraints.maxWidth > 1100;
                final leftPanel = Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 14,
                          offset: const Offset(0, 5))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: TextField(
                            onChanged: (value) =>
                                setState(() => searchQuery = value),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 14),
                              prefixIcon:
                                  const Icon(Icons.search, color: Colors.grey),
                              hintText: 'Search product or scan barcode',
                              border: InputBorder.none,
                              hintStyle:
                                  TextStyle(color: Colors.grey.shade500),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              'All',
                              'Handbags',
                              'Food',
                              'Personal Care',
                              'Home Decor',
                              'Accessories',
                              'Toiletries',
                              'Kitchen'
                            ].map((category) {
                              final isSelected = selectedCategory == category;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(category,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500)),
                                  selected: isSelected,
                                  selectedColor: const Color(0xFF2E7D32),
                                  backgroundColor: const Color(0xFFECEFF1),
                                  labelStyle: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black87),
                                  onSelected: (_) => setState(
                                      () => selectedCategory = category),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: todayOrdersStream,
                        builder: (context, snapshot) {
                          double todaySales = 0;
                          int ordersToday = 0;
                          int productsSold = 0;
                          if (snapshot.hasData) {
                            final docs = snapshot.data!.docs;
                            ordersToday = docs.length;
                            for (var doc in docs) {
                              final data = doc.data();
                              todaySales +=
                                  (data['total'] as num?)?.toDouble() ?? 0.0;
                              final items =
                                  data['items'] as List<dynamic>? ?? [];
                              for (var item in items) {
                                if (item is Map<String, dynamic>) {
                                  productsSold +=
                                      (item['quantity'] as num?)?.toInt() ?? 0;
                                } else if (item is Map) {
                                  productsSold +=
                                      (item['quantity'] as num?)?.toInt() ?? 0;
                                }
                              }
                            }
                          }
                          return Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: Colors.green.shade200)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(children: const [
                                  Icon(Icons.bar_chart,
                                      color: Color(0xFF2E7D32)),
                                  SizedBox(width: 8),
                                  Text('Today Summary',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2E7D32)))
                                ]),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text(
                                        'Sales ₹${todaySales.toStringAsFixed(0)} | Orders $ordersToday | Products Sold $productsSold',
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87)),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ProductGrid(
                          addToCart: addToCart,
                          selectedCategory: selectedCategory,
                          searchQuery: searchQuery,
                          onCategorySelected: (category) =>
                              setState(() => selectedCategory = category),
                        ),
                      ),
                    ],
                  ),
                );

                final rightPanel = Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FBF8),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.green.shade100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(children: const [
                        Icon(Icons.shopping_cart_outlined,
                            color: Color(0xFF2E7D32)),
                        SizedBox(width: 8),
                        Text('Cart',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700))
                      ]),
                      const Divider(),
                      Expanded(
                        child: CartPanel(
                            cart: cart,
                            onIncrease: increase,
                            onDecrease: decrease,
                            onRemove: removeItem),
                      ),
                      const SizedBox(height: 10),
                      BillingSummary(
                          subtotal: subtotal, tax: tax, total: total),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: ['Cash', 'UPI', 'Card'].map((method) {
                            final selected = paymentMethod == method;
                            return Expanded(
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: selected
                                        ? const Color(0xFF2E7D32)
                                        : Colors.white,
                                    side: BorderSide(
                                        color: selected
                                            ? const Color(0xFF2E7D32)
                                            : Colors.grey.shade300),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                  ),
                                  onPressed: () =>
                                      setState(() => paymentMethod = method),
                                  child: Text(method,
                                      style: TextStyle(
                                          color: selected
                                              ? Colors.white
                                              : Colors.black87,
                                          fontWeight: FontWeight.w600)),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: SizedBox(
                          height: 52,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: checkout,
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith((states) {
                                if (states.contains(MaterialState.hovered) ||
                                    states.contains(MaterialState.pressed)) {
                                  return const Color(0xFF256628);
                                }
                                return const Color(0xFF2E7D32);
                              }),
                              foregroundColor:
                                  MaterialStateProperty.all(Colors.white),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            child: const Text('Generate Bill',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ),
                        ),
                      ),
                    ],
                  ),
                );

                if (isWide) {
                  return Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(flex: 3, child: leftPanel),
                        const SizedBox(width: 12),
                        Expanded(flex: 2, child: rightPanel)
                      ]);
                }

                return Column(
                  children: [
                    Expanded(flex: 2, child: leftPanel),
                    const SizedBox(height: 10),
                    Expanded(flex: 1, child: rightPanel),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
