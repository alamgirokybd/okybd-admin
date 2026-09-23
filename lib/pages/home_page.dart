import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class OrderDetailsPageWidget extends StatefulWidget {
  final dynamic orderData;

  const OrderDetailsPageWidget({super.key, required this.orderData});

  @override
  State<OrderDetailsPageWidget> createState() => _OrderDetailsPageWidgetState();
}

class _OrderDetailsPageWidgetState extends State<OrderDetailsPageWidget> {
  late String _currentStatus;
  bool _isUpdating = false;

  final String _consumerKey = 'ck_45ae03c28b4b8b6fc1ff1b1d1ef3e6e0062db840';
  final String _consumerSecret = 'cs_6d16165fbc1a7815876093e225317dfe714f39e6';

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.orderData['status'] ?? 'pending';
  }

  // কাস্টমারকে সরাসরি কল দেওয়ার ফাংশন
  Future<void> _makePhoneCall(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$cleanNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ফোন ডায়ালার ওপেন করা যায়নি!')),
        );
      }
    }
  }

  // কাস্টমারকে সরাসরি হোয়াটসঅ্যাপ মেসেজ পাঠানোর ফাংশন
  Future<void> _openWhatsApp(String phoneNumber, String orderId) async {
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanNumber.startsWith('0')) {
      cleanNumber = '88$cleanNumber';
    } else if (!cleanNumber.startsWith('880')) {
      cleanNumber = '880$cleanNumber';
    }

    final message = Uri.encodeComponent(
      'প্রিয় কাস্টমার, Okybd থেকে আপনার #$orderId নম্বর অর্ডারের বিষয়ে যোগাযোগ করা হয়েছে। আপনার অর্ডারটি কনফার্ম করতে অনুগ্রহ করে রিপ্লাই দিন। ধন্যবাদ!',
    );

    final uri = Uri.parse('https://wa.me/$cleanNumber?text=$message');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('হোয়াটসঅ্যাপ ওপেন করা যায়নি!')),
        );
      }
    }
  }

  // ওয়েবসাইট ও অ্যাপে স্ট্যাটাস আপডেট করার ফাংশন
  Future<void> _updateOrderStatus(String newStatus) async {
    setState(() => _isUpdating = true);
    final orderId = widget.orderData['id'];

    final url = Uri.parse(
      'https://okybd.com/wp-json/wc/v3/orders/$orderId?consumer_key=$_consumerKey&consumer_secret=$_consumerSecret',
    );

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'Mozilla/5.0 (Linux; Android 10; Mobile)',
        },
        body: json.encode({'status': newStatus}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _currentStatus = newStatus;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('অর্ডার স্ট্যাটাস সফলভাবে "$newStatus" হয়েছে!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('স্ট্যাটাস আপডেট ব্যর্থ হয়েছে: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.orderData;
    final billing = order['billing'] ?? {};
    final phone = billing['phone']?.toString() ?? '';
    final customerName = (billing['first_name'] != null &&
            billing['first_name'].toString().isNotEmpty)
        ? '${billing['first_name']} ${billing['last_name'] ?? ''}'.trim()
        : 'Guest Customer';

    final address = [
      billing['address_1'],
      billing['city'],
      billing['state'],
    ].where((e) => e != null && e.toString().isNotEmpty).join(', ');

    final lineItems = (order['line_items'] as List<dynamic>?) ?? [];
    final total = order['total']?.toString() ?? '0.00';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order #${order['id']}',
          style: GoogleFonts.interTight(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xB2EE6083),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // কাস্টমার ইনফরমেশন কার্ড
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customerName,
                      style: GoogleFonts.inter(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 18, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          phone.isNotEmpty ? phone : 'ফোন নম্বর দেওয়া নেই',
                          style: GoogleFonts.inter(fontSize: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on,
                            size: 18, color: Colors.redAccent),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            address.isNotEmpty ? address : 'ঠিকানা দেওয়া নেই',
                            style: GoogleFonts.inter(
                                fontSize: 14, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('মোট বিল:',
                            style: GoogleFonts.inter(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        Text('TK $total',
                            style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF21D421))),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // এক ক্লিকে কল এবং হোয়াটসঅ্যাপ বাটন
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.call, color: Colors.white),
                    label: Text(
                      'Call',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    onPressed: phone.isNotEmpty
                        ? () => _makePhoneCall(phone)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.chat, color: Colors.white),
                    label: Text(
                      'WhatsApp',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    onPressed: phone.isNotEmpty
                        ? () => _openWhatsApp(phone, order['id'].toString())
                        : null,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // অর্ডার স্ট্যাটাস পরিবর্তন
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'অর্ডার স্ট্যাটাস পরিবর্তন করুন:',
                      style: GoogleFonts.inter(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    if (_isUpdating)
                      const Center(child: CircularProgressIndicator())
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: ['pending', 'processing', 'completed', 'cancelled']
                                    .contains(_currentStatus)
                                ? _currentStatus
                                : 'processing',
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(
                                  value: 'pending', child: Text('Pending Payment')),
                              DropdownMenuItem(
                                  value: 'processing', child: Text('Processing (চলমান)')),
                              DropdownMenuItem(
                                  value: 'completed', child: Text('Completed (সম্পন্ন)')),
                              DropdownMenuItem(
                                  value: 'cancelled', child: Text('Cancelled (বাতিল)')),
                            ],
                            onChanged: (val) {
                              if (val != null && val != _currentStatus) {
                                _updateOrderStatus(val);
                              }
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // প্রোডাক্ট আইটেমসমূহ
            Text(
              'অর্ডারকৃত পণ্যসমূহ:',
              style: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...lineItems.map((item) {
              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                child: ListTile(
                  title: Text(
                    item['name'] ?? 'Product',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('পরিমাণ: ${item['quantity']} টি'),
                  trailing: Text(
                    'TK ${item['total'] ?? '0'}',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
