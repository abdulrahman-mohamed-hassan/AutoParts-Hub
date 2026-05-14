import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class OrderSummaryPage extends StatelessWidget {
  final Map<String, dynamic> orderDetails;

  const OrderSummaryPage({super.key, required this.orderDetails});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Summary'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success Icon
            Center(
              child: Column(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 80),
                  const SizedBox(height: 10),
                  const Text(
                    'Order Placed Successfully!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Your order has been confirmed',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            // Order Details Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Details',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    _buildDetailRow('Order Number', '#${DateTime.now().millisecondsSinceEpoch}'),
                    _buildDetailRow('Date', DateTime.now().toString().split(' ')[0]),
                    _buildDetailRow('Payment Method', orderDetails['paymentMethod'] ?? 'Credit Card'),
                    const Divider(),
                    const Text(
                      'Shipping Address',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(orderDetails['address'] ?? '123 Main Street, Cairo, Egypt'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Items Summary
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Items Summary',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    _buildDetailRow('Subtotal', '\$${orderDetails['subtotal'] ?? '120.00'}'),
                    _buildDetailRow('Shipping', '\$${orderDetails['shipping'] ?? '10.00'}'),
                    _buildDetailRow('Tax', '\$${orderDetails['tax'] ?? '5.00'}'),
                    const Divider(),
                    _buildDetailRow(
                      'Total',
                      '\$${orderDetails['total'] ?? '135.00'}',
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('CONTINUE SHOPPING'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to orders page or track order
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Order tracking coming soon!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('TRACK ORDER'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppTheme.accentColor : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}