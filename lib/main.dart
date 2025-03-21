import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const ShipmentApp());
}

class ShipmentApp extends StatelessWidget {
  const ShipmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shipment Booking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: const TextTheme(bodyLarge: TextStyle(fontSize: 16)),
      ),
      home: const BookShipmentScreen(),
    );
  }
}

class BookShipmentScreen extends StatefulWidget {
  const BookShipmentScreen({super.key});

  @override
  State<BookShipmentScreen> createState() => _BookShipmentScreenState();
}

class _BookShipmentScreenState extends State<BookShipmentScreen> {
  final TextEditingController pickupController = TextEditingController();
  final TextEditingController deliveryController = TextEditingController();
  String selectedCourier = 'Delhivery';
  double price = 0.0;
  bool isLoading = false;

  final List<String> couriers = [
    'Delhivery',
    'DTDC',
    'Bluedart',
    'Ecom Express',
    'India Post',
    'XpressBees',
    'Shadowfax',
    'DHL',
    'FedEx',
  ];

  // Function to fetch shipping rate from API
  Future<void> fetchShippingRate() async {
    setState(() {
      isLoading = true;
    });

    // Use your actual API endpoint (replace with your own if needed)
    final url = Uri.parse(
      'https://67dd3b7be00db03c406aba39.mockapi.io/courierRates',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // data is assumed to be a list of rates; we filter for the selected courier.
        final rateData = (data as List).firstWhere(
          (item) => item['courier'] == selectedCourier,
          orElse: () => null,
        );

        if (rateData != null) {
          setState(() {
            price = double.parse(rateData['rate'].toString());
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No rate found for the selected courier.'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch price: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Updated calculatePrice to call the API function
  void calculatePrice() {
    if (pickupController.text.trim().isEmpty ||
        deliveryController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both pickup & delivery addresses!'),
        ),
      );
      return;
    }
    fetchShippingRate();
  }

  void navigateToPayment() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PaymentScreen(price: price)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('📦 Book a Shipment'),
        backgroundColor: Colors.deepPurpleAccent.withOpacity(0.9),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0C3FC), Color(0xFFFFF4E0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('🚚 Pickup Address'),
                          _buildInputField(
                            pickupController,
                            'Enter pickup address',
                          ),
                          const SizedBox(height: 20),
                          _buildLabel('📍 Delivery Address'),
                          _buildInputField(
                            deliveryController,
                            'Enter delivery address',
                          ),
                          const SizedBox(height: 20),
                          _buildLabel('✈️ Select Courier'),
                          _buildCourierDropdown(),
                          const SizedBox(height: 25),
                          _buildCalculateButton(),
                          const SizedBox(height: 10),
                          // Show a loading indicator when fetching API
                          isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : Text(
                                'Total Price: ₹${price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          const SizedBox(height: 20),
                          const Spacer(),
                          _buildPaymentButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        color: Colors.black87,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String hint) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildCourierDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        value: selectedCourier,
        underline: Container(),
        items:
            couriers.map((String courier) {
              return DropdownMenuItem<String>(
                value: courier,
                child: Text(courier),
              );
            }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            selectedCourier = newValue!;
          });
        },
      ),
    );
  }

  Widget _buildCalculateButton() {
    return ElevatedButton(
      onPressed: calculatePrice,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Text(
        '💰 Calculate Price',
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }

  Widget _buildPaymentButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
      child: Center(
        child: ElevatedButton(
          onPressed: price > 0.0 ? navigateToPayment : null,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                price > 0
                    ? const Color.fromARGB(255, 151, 116, 213)
                    : Colors.grey,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 25),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Proceed to Payment ➡️',
            style: TextStyle(
              fontSize: 16,
              color: Color.fromARGB(255, 15, 0, 0),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------- Payment Screen ----------------

class PaymentScreen extends StatelessWidget {
  final double price;
  const PaymentScreen({super.key, required this.price});

  void _showPaymentOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Select Payment Method'),
          children: [
            _buildPaymentOption(context, 'PhonePe', Icons.phone_android),
            _buildPaymentOption(context, 'Paytm', Icons.payment),
            _buildPaymentOption(context, 'GPay', Icons.account_balance_wallet),
          ],
        );
      },
    );
  }

  Widget _buildPaymentOption(
    BuildContext context,
    String method,
    IconData icon,
  ) {
    return SimpleDialogOption(
      onPressed: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('okkyy via $method!')),
        );
      },
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple),
          const SizedBox(width: 10),
          Text(method),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💳 Payment'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Total Amount to Pay: ₹${price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => _showPaymentOptions(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 25,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Pay Now',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
