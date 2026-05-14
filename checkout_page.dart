import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../widgets/animated_button.dart';
import 'order_summary_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool _payWithCard = true;
  
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  double get subtotal => 120.00;
  double get shipping => 10.00;
  double get tax => 5.00;
  double get total => subtotal + shipping + tax;

  @override
  void dispose() {
    _fullNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shipping Address Section
            _buildSectionHeader("Shipping Address", Icons.location_on),
            const SizedBox(height: 10),
            TextField(
              controller: _fullNameController,
              decoration: InputDecoration(
                labelText: "Full Name",
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: "Address Line",
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Phone Number",
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Payment Method Section
            _buildSectionHeader("Payment Method", Icons.payment),
            const SizedBox(height: 10),
            
            // Credit / Debit Card option
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: _payWithCard ? AppTheme.primaryColor : Colors.grey.shade300,
                  width: _payWithCard ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  ListTile(
                    onTap: () => setState(() => _payWithCard = true),
                    leading: Icon(Icons.credit_card, color: AppTheme.primaryColor),
                    title: const Text("Credit / Debit Card"),
                    subtitle: const Text("Visa, Mastercard, etc.", style: TextStyle(fontSize: 12)),
                    trailing: Radio<bool>(
                      value: true,
                      groupValue: _payWithCard,
                      onChanged: (v) => setState(() => _payWithCard = v!),
                      activeColor: AppTheme.primaryColor,
                    ),
                  ),
                  if (_payWithCard) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Divider(),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          TextField(
                            controller: _cardNumberController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Card Number",
                              prefixIcon: const Icon(Icons.credit_card),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _expiryController,
                                  decoration: InputDecoration(
                                    labelText: "MM/YY",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _cvvController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: "CVV",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Cash on Delivery option
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: !_payWithCard ? AppTheme.primaryColor : Colors.grey.shade300,
                  width: !_payWithCard ? 2 : 1,
                ),
              ),
              child: ListTile(
                onTap: () => setState(() => _payWithCard = false),
                leading: Icon(Icons.account_balance_wallet, color: AppTheme.primaryColor),
                title: const Text("Cash on Delivery"),
                subtitle: const Text("Pay when you receive", style: TextStyle(fontSize: 12)),
                trailing: Radio<bool>(
                  value: false,
                  groupValue: _payWithCard,
                  onChanged: (v) => setState(() => _payWithCard = v!),
                  activeColor: AppTheme.primaryColor,
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Order Summary Section
            _buildSectionHeader("Order Summary", Icons.receipt),
            const SizedBox(height: 10),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  _buildSummaryRow("Subtotal", "\$${subtotal.toStringAsFixed(2)}"),
                  const SizedBox(height: 8),
                  _buildSummaryRow("Shipping", "\$${shipping.toStringAsFixed(2)}"),
                  const SizedBox(height: 8),
                  _buildSummaryRow("Tax", "\$${tax.toStringAsFixed(2)}"),
                  const Divider(height: 30),
                  _buildSummaryRow("Total", "\$${total.toStringAsFixed(2)}", isTotal: true),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Payment Method Badge
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _payWithCard ? Colors.blue.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        _payWithCard ? Icons.credit_card : Icons.money,
                        key: ValueKey(_payWithCard),
                        size: 16,
                        color: _payWithCard ? Colors.blue : Colors.green,
                      ),
                    ),
                    const SizedBox(width: 6),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        _payWithCard ? "Paying with Card" : "Paying with Cash on Delivery",
                        key: ValueKey(_payWithCard),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _payWithCard ? Colors.blue : Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Animated Confirm Button
            AnimatedButton(
              onPressed: () => _placeOrder(),
              color: AppTheme.accentColor,
              width: double.infinity,
              height: 55,
              child: const Center(
                child: Text(
                  "CONFIRM ORDER",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
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
            fontSize: isTotal ? 20 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? AppTheme.accentColor : Colors.black,
          ),
        ),
      ],
    );
  }

  void _placeOrder() {
    if (_fullNameController.text.isEmpty) {
      _showError("Please enter your full name");
      return;
    }
    if (_addressController.text.isEmpty) {
      _showError("Please enter your address");
      return;
    }
    if (_phoneController.text.isEmpty) {
      _showError("Please enter your phone number");
      return;
    }

    if (_payWithCard) {
      if (_cardNumberController.text.isEmpty) {
        _showError("Please enter card number");
        return;
      }
      if (_expiryController.text.isEmpty) {
        _showError("Please enter expiry date");
        return;
      }
      if (_cvvController.text.isEmpty) {
        _showError("Please enter CVV");
        return;
      }
    }

    final orderDetails = {
      'paymentMethod': _payWithCard ? 'Credit Card' : 'Cash on Delivery',
      'subtotal': subtotal.toStringAsFixed(2),
      'shipping': shipping.toStringAsFixed(2),
      'tax': tax.toStringAsFixed(2),
      'total': total.toStringAsFixed(2),
      'address': _addressController.text,
      'fullName': _fullNameController.text,
      'phone': _phoneController.text,
    };
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => OrderSummaryPage(orderDetails: orderDetails),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}