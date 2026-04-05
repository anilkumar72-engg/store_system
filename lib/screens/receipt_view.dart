import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import '../models/order_model.dart';

class ReceiptView extends StatefulWidget {
  final OrderModel order;
  const ReceiptView({super.key, required this.order});

  @override
  State<ReceiptView> createState() => _ReceiptViewState();
}

class _ReceiptViewState extends State<ReceiptView> {
  final BlueThermalPrinter _printer = BlueThermalPrinter.instance;
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _selectedDevice;
  bool _isLoadingDevices = true;
  bool _isPrinting = false;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    try {
      final devices = await _printer.getBondedDevices();
      setState(() {
        _devices = devices;
        _isLoadingDevices = false;
      });
    } catch (_) {
      setState(() {
        _isLoadingDevices = false;
      });
    }
  }

  String _formatPrice(double value) => '₹${value.toStringAsFixed(2)}';

  String _formatLine(String label, String value, {int width = 32}) {
    final left = label;
    final right = value;
    final spaceCount = width - left.length - right.length;
    return left + (spaceCount > 0 ? ' ' * spaceCount : ' ') + right;
  }

  Future<void> _printReceipt() async {
    if (_selectedDevice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select a printer first')));
      return;
    }
    setState(() => _isPrinting = true);
    try {
      final connected = await _printer.connect(_selectedDevice!);
      if (connected) {
        _printer.printNewLine();
        _printer.printCustom('MANYAM MART', 3, 1);
        _printer.printNewLine();
        final date = widget.order.createdAt.toDate();
        _printer.printCustom('Date: ${date.day}-${date.month}-${date.year}', 1, 0);
        _printer.printCustom('Order: #${widget.order.orderId}', 1, 0);
        _printer.printNewLine();
        if ((widget.order.customerName ?? '').isNotEmpty) {
          _printer.printCustom('Customer: ${widget.order.customerName}', 1, 0);
        }
        if ((widget.order.customerMobile ?? '').isNotEmpty) {
          _printer.printCustom('Mobile: ${widget.order.customerMobile}', 1, 0);
        }
        _printer.printNewLine();
        _printer.printCustom('Item  Qty  Price', 1, 0);
        for (var item in widget.order.items) {
          final name = item['name'] ?? 'Item';
          final qty = (item['quantity'] as num?)?.toInt() ?? 1;
          final unitPrice = (item['unitPrice'] as num?)?.toDouble() ?? 0.0;
          _printer.printCustom(
              '$name ${qty.toString().padLeft(3)} ${_formatPrice(unitPrice)}', 1, 0);
        }
        _printer.printNewLine();
        _printer.printCustom(_formatLine('Subtotal', _formatPrice(widget.order.subtotal)), 1, 0);
        _printer.printCustom(_formatLine('Tax', _formatPrice(widget.order.tax)), 1, 0);
        _printer.printCustom(_formatLine('TOTAL', _formatPrice(widget.order.total)), 2, 0);
        _printer.printNewLine();
        _printer.printCustom('Payment: ${widget.order.paymentMethod}', 1, 0);
        _printer.printNewLine();
        _printer.printCustom('Thank You Visit Again', 1, 1);
        _printer.paperCut();
        await _printer.disconnect();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unable to connect to printer')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Print failed: $e')));
    } finally {
      setState(() => _isPrinting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = widget.order.createdAt.toDate();
    return Scaffold(
      appBar: AppBar(title: const Text('Receipt')),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 280,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                    child: Text('MANYAM MART',
                        style: TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 16,
                            fontWeight: FontWeight.bold))),
                const SizedBox(height: 8),
                Text('Date: ${date.day}-${date.month}-${date.year}',
                    style: const TextStyle(fontSize: 12, fontFamily: 'Courier')),
                Text('Order: #${widget.order.orderId}',
                    style: const TextStyle(fontSize: 12, fontFamily: 'Courier')),
                if ((widget.order.customerName ?? '').isNotEmpty)
                  Text('Customer: ${widget.order.customerName}',
                      style: const TextStyle(fontSize: 12, fontFamily: 'Courier')),
                if ((widget.order.customerMobile ?? '').isNotEmpty)
                  Text('Mobile: ${widget.order.customerMobile}',
                      style: const TextStyle(fontSize: 12, fontFamily: 'Courier')),
                const Divider(),
                const Text('Item      Qty   Price',
                    style: TextStyle(fontSize: 11, fontFamily: 'Courier', fontWeight: FontWeight.bold)),
                ...widget.order.items.map((item) {
                  final name = (item['name'] as String?) ?? 'Item';
                  final qty = (item['quantity'] as num?)?.toInt() ?? 1;
                  final unitPrice = (item['unitPrice'] as num?)?.toDouble() ?? 0.0;
                  final price = qty * unitPrice;
                  final itemLine = '${name.padRight(10).substring(0, name.length > 10 ? 10 : name.length)} ${qty.toString().padLeft(3)} ${_formatPrice(price).padLeft(8)}';
                  return Text(itemLine,
                      style: const TextStyle(fontSize: 11, fontFamily: 'Courier'));
                }).toList(),
                const Divider(),
                Text('Subtotal: ${_formatPrice(widget.order.subtotal)}',
                    style: const TextStyle(fontSize: 12, fontFamily: 'Courier')),
                Text('Tax: ${_formatPrice(widget.order.tax)}',
                    style: const TextStyle(fontSize: 12, fontFamily: 'Courier')),
                Text('TOTAL: ${_formatPrice(widget.order.total)}',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Courier')),
                const Divider(),
                Text('Payment: ${widget.order.paymentMethod}',
                    style: const TextStyle(fontSize: 12, fontFamily: 'Courier')),
                const SizedBox(height: 8),
                const Center(
                  child: Text('Thank You Visit Again',
                      style: TextStyle(fontFamily: 'Courier', fontSize: 12)),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const Text('Select Printer', style: TextStyle(fontWeight: FontWeight.bold)),
                if (_isLoadingDevices)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else ...[
                  DropdownButtonFormField<BluetoothDevice>(
                    value: _selectedDevice,
                    items: _devices
                        .map((d) => DropdownMenuItem(
                              value: d,
                              child: Text(d.name ?? d.address ?? 'Unknown'),
                            ))
                        .toList(),
                    onChanged: (device) => setState(() => _selectedDevice = device),
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isPrinting ? null : _printReceipt,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                      ),
                      child: Text(_isPrinting ? 'Printing...' : 'Print Receipt'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
