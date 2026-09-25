import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../flutter_flow/flutter_flow_theme.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedTabIndex = 0;

  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _orders = [];
  String _totalSales = '0.00';
  String _totalOrders = '0';

  final String _consumerKey = 'ck_45ae03c28b4b8b6fc1ff1b1d1ef3e6e0062db840';
  final String _consumerSecret = 'cs_6d16165fbc1a7815876093e225317dfe714f39e6';

  late final String _ordersUrl =
      'https://okybd.com/wp-json/wc/v3/orders?per_page=50&consumer_key=$_consumerKey&consumer_secret=$_consumerSecret';
  late final String _reportsUrl =
      'https://okybd.com/wp-json/wc/v3/reports/sales?consumer_key=$_consumerKey&consumer_secret=$_consumerSecret';

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  // কাস্টমারকে সরাসরি কল করার ফাংশন
  Future<void> _makePhoneCall(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$cleanNumber');
    try {
      await launchUrl(uri);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ফোন ডায়ালার ওপেন করা যায়নি!')),
        );
      }
    }
  }

  // সরাসরি হোয়াটসঅ্যাপে মেসেজ পাঠানোর ফাংশন
  Future<void> _openWhatsApp(dynamic order) async {
    final billing = order['billing'] ?? {};
    final rawPhone = billing['phone']?.toString() ?? '';
    if (rawPhone.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ফোন নম্বর পাওয়া যায়নি!')),
        );
      }
      return;
    }

    String cleanNumber = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanNumber.startsWith('0')) {
      cleanNumber = '88$cleanNumber';
    } else if (!cleanNumber.startsWith('880')) {
      cleanNumber = '880$cleanNumber';
    }

    final customerName = (billing['first_name'] != null &&
            billing['first_name'].toString().isNotEmpty)
        ? '${billing['first_name']} ${billing['last_name'] ?? ''}'.trim()
        : 'Customer';

    final lineItems = (order['line_items'] as List<dynamic>?) ?? [];
    String itemsText = '';
    for (var item in lineItems) {
      itemsText += '- ${item['name']} (x${item['quantity']})\n';
    }
    if (itemsText.isEmpty) itemsText = '- Product\n';

    final total = order['total']?.toString() ?? '0';
    final addressParts = [
      billing['address_1'],
      billing['city'],
    ].where((e) => e != null && e.toString().trim().isNotEmpty).toList();
    final address = addressParts.isNotEmpty ? addressParts.join(', ') : 'ঠিকানা';

    final fullMessage = '''
প্রিয় $customerName,
Okybd থেকে আপনার অর্ডারটি নিশ্চিত করতে যোগাযোগ করা হয়েছে।

📦 অর্ডার নম্বর: #${order['id']}
🛍️ পণ্যসমূহ:
$itemsText💰 মোট বিল: TK $total
🚚 ডেলিভারি ঠিকানা: $address

আপনার অর্ডারটি ডেলিভারির জন্য কনফার্ম করতে অনুগ্রহ করে 'YES' লিখে বা একটি রিপ্লাই দিন। ধন্যবাদ!
''';

    final encodedMessage = Uri.encodeComponent(fullMessage);
    final appUri =
        Uri.parse('whatsapp://send?phone=$cleanNumber&text=$encodedMessage');
    final webUri = Uri.parse('https://wa.me/$cleanNumber?text=$encodedMessage');

    try {
      bool launched =
          await launchUrl(appUri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      try {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('হোয়াটসঅ্যাপ ওপেন করা যায়নি!')),
          );
        }
      }
    }
  }

  // অর্ডার স্ট্যাটাস আপডেট
  Future<void> _updateOrderStatus(int orderId, String newStatus) async {
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('অর্ডার #$orderId স্ট্যাটাস সফলভাবে "$newStatus" হয়েছে!'),
              backgroundColor: Colors.green,
            ),
          );
        }
        _fetchDashboardData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('স্ট্যাটাস আপডেট ব্যর্থ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // অর্ডারের বিস্তারিত বটম শীট
  void _showOrderDetailsModal(dynamic order) {
    final billing = order['billing'] ?? {};
    final phone = billing['phone']?.toString() ?? '';
    final customerName = (billing['first_name'] != null &&
            billing['first_name'].toString().isNotEmpty)
        ? '${billing['first_name']} ${billing['last_name'] ?? ''}'.trim()
        : 'Guest Customer';

    final addressParts = [
      billing['address_1'],
      billing['address_2'],
      billing['city'],
      billing['state'],
    ].where((e) => e != null && e.toString().trim().isNotEmpty).toList();

    final address = addressParts.isNotEmpty
        ? addressParts.join(', ')
        : 'ঠিকানা পাওয়া যায়নি';

    final lineItems = (order['line_items'] as List<dynamic>?) ?? [];
    final total = order['total']?.toString() ?? '0.00';
    final currentStatus = order['status'] ?? 'pending';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order #${order['id']}',
                      style: GoogleFonts.interTight(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFD83B65),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.pink.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        currentStatus,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFD83B65),
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Text(
                  'কাস্টমার তথ্য:',
                  style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Text(
                  customerName,
                  style: GoogleFonts.inter(
                      fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.phone, size: 18, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      phone.isNotEmpty ? phone : 'ফোন নম্বর নেই',
                      style: GoogleFonts.inter(fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on,
                        size: 18, color: Colors.redAccent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        address,
                        style: GoogleFonts.inter(
                            fontSize: 14, color: Colors.black87, height: 1.3),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Text(
                  'অর্ডারকৃত পণ্যসমূহ:',
                  style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
                const SizedBox(height: 8),
                ...lineItems.map((item) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'] ?? 'Product',
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                              Text(
                                'পরিমাণ: ${item['quantity']} টি',
                                style: GoogleFonts.inter(
                                    fontSize: 12, color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'TK ${item['total'] ?? '0'}',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('মোট বিল:',
                        style: GoogleFonts.inter(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('TK $total',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF21D421),
                        )),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _fetchDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final headers = {
      'User-Agent':
          'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Mobile Safari/537.36',
      'Accept': 'application/json',
    };

    try {
      final ordersResponse =
          await http.get(Uri.parse(_ordersUrl), headers: headers);
      if (ordersResponse.statusCode == 200) {
        final dynamic decoded = json.decode(ordersResponse.body);
        if (decoded is List) {
          _orders = decoded;
          _totalOrders = _orders.length.toString();
          double sumSales = 0.0;
          for (var item in _orders) {
            final double val =
                double.tryParse(item['total']?.toString() ?? '0') ?? 0.0;
            sumSales += val;
          }
          _totalSales = sumSales.toStringAsFixed(2);
        }
      } else {
        _errorMessage = 'Order API Error: ${ordersResponse.statusCode}';
      }

      try {
        final reportsResponse =
            await http.get(Uri.parse(_reportsUrl), headers: headers);
        if (reportsResponse.statusCode == 200) {
          final dynamic decodedReports = json.decode(reportsResponse.body);
          if (decodedReports is List && decodedReports.isNotEmpty) {
            final repSales = decodedReports[0]['total_sales']?.toString();
            final repOrders = decodedReports[0]['total_orders']?.toString();
            if (repSales != null && repSales.isNotEmpty && repSales != '0.00') {
              _totalSales = repSales;
            }
            if (repOrders != null && repOrders.isNotEmpty && repOrders != '0') {
              _totalOrders = repOrders;
            }
          }
        }
      } catch (_) {}
    } catch (e) {
      _errorMessage = 'Connection Error: $e';
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ১ম স্ক্রিন: বর্তমান অর্ডার ড্যাশবোর্ড
  Widget _buildOrdersDashboard(FlutterFlowTheme theme) {
    return RefreshIndicator(
      onRefresh: _fetchDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Icon(Icons.monetization_on,
                                color: Color(0xFF119AFF), size: 32),
                            const SizedBox(height: 6),
                            Text(
                              'TK $_totalSales',
                              style: GoogleFonts.inter(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Total Revenue',
                              style: GoogleFonts.inter(
                                  fontSize: 13, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Icon(Icons.shopping_bag,
                                color: Color(0xFF1199FF), size: 32),
                            const SizedBox(height: 6),
                            Text(
                              _totalOrders,
                              style: GoogleFonts.inter(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Total Orders',
                              style: GoogleFonts.inter(
                                  fontSize: 13, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Orders',
                    style: GoogleFonts.inter(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 22),
                    onPressed: _fetchDashboardData,
                  ),
                ],
              ),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_orders.isEmpty && _errorMessage == null)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: Text('No orders found')),
              )
            else
              ListView.builder(
                padding: const EdgeInsets.only(bottom: 20),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _orders.length,
                itemBuilder: (context, index) {
                  final order = _orders[index];
                  final billing = order['billing'] ?? {};
                  final phone = billing['phone']?.toString() ?? '';
                  final customerName = (billing['first_name'] != null &&
                          billing['first_name'].toString().isNotEmpty)
                      ? '${billing['first_name']} ${billing['last_name'] ?? ''}'
                          .trim()
                      : 'Guest Customer';
                  final currentStatus = order['status'] ?? 'pending';

                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 1,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => _showOrderDetailsModal(order),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          customerName,
                                          style: GoogleFonts.inter(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '#${order['id']} • $currentStatus',
                                          style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    'TK ${order['total'] ?? '0'}',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF21D421),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  DropdownButton<String>(
                                    value: [
                                      'pending',
                                      'processing',
                                      'completed',
                                      'cancelled'
                                    ].contains(currentStatus)
                                        ? currentStatus
                                        : 'processing',
                                    isDense: true,
                                    underline: const SizedBox(),
                                    items: const [
                                      DropdownMenuItem(
                                          value: 'pending',
                                          child: Text('Pending',
                                              style: TextStyle(fontSize: 13))),
                                      DropdownMenuItem(
                                          value: 'processing',
                                          child: Text('Processing',
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.blue))),
                                      DropdownMenuItem(
                                          value: 'completed',
                                          child: Text('Completed',
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.green))),
                                      DropdownMenuItem(
                                          value: 'cancelled',
                                          child: Text('Cancelled',
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.red))),
                                    ],
                                    onChanged: (newStatus) {
                                      if (newStatus != null &&
                                          newStatus != currentStatus) {
                                        _updateOrderStatus(
                                            order['id'], newStatus);
                                      }
                                    },
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.call,
                                            color: Colors.green, size: 22),
                                        tooltip: 'Call Customer',
                                        onPressed: phone.isNotEmpty
                                            ? () => _makePhoneCall(phone)
                                            : null,
                                      ),
                                      const SizedBox(width: 4),
                                      IconButton(
                                        icon: const Icon(Icons.chat,
                                            color: Color(0xFF25D366),
                                            size: 22),
                                        tooltip: 'WhatsApp',
                                        onPressed: phone.isNotEmpty
                                            ? () => _openWhatsApp(order)
                                            : null,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // ২য় স্ক্রিন: স্বয়ংক্রিয় কমপ্লিটেড অর্ডার শিট / সেলস রেকর্ড
  Widget _buildCompletedOrdersSheet() {
    final completedOrders =
        _orders.where((o) => o['status'] == 'completed').toList();

    double totalCompletedAmount = 0.0;
    for (var o in completedOrders) {
      totalCompletedAmount +=
          double.tryParse(o['total']?.toString() ?? '0') ?? 0.0;
    }

    return RefreshIndicator(
      onRefresh: _fetchDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // সামারি ব্যানার
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'মোট সফল ডেলিভারি',
                        style: GoogleFonts.inter(
                            fontSize: 13, color: Colors.green.shade900),
                      ),
                      Text(
                        '${completedOrders.length} টি পার্সেল',
                        style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade900),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'মোট আদায়কৃত টাকা',
                        style: GoogleFonts.inter(
                            fontSize: 13, color: Colors.green.shade900),
                      ),
                      Text(
                        'TK ${totalCompletedAmount.toStringAsFixed(2)}',
                        style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade900),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (completedOrders.isEmpty)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                    child: Text('কোনো Completed অর্ডার পাওয়া যায়নি')),
              )
            else
              ...completedOrders.map((order) {
                final billing = order['billing'] ?? {};
                final customerName = (billing['first_name'] != null &&
                        billing['first_name'].toString().isNotEmpty)
                    ? '${billing['first_name']} ${billing['last_name'] ?? ''}'
                        .trim()
                    : 'Customer';
                final phone = billing['phone']?.toString() ?? 'নম্বর নেই';
                final address = [
                  billing['address_1'],
                  billing['city'],
                ]
                    .where((e) => e != null && e.toString().trim().isNotEmpty)
                    .join(', ');

                final lineItems = (order['line_items'] as List<dynamic>?) ?? [];
                String itemsSummary = lineItems
                    .map((i) => '${i['name']} (x${i['quantity']})')
                    .join(', ');

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 1,
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          customerName,
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          'TK ${order['total'] ?? '0'}',
                          style: GoogleFonts.inter(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('📞 $phone • #${order['id']}',
                            style: const TextStyle(fontSize: 13)),
                        if (address.isNotEmpty)
                          Text('📍 $address',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[700])),
                        if (itemsSummary.isNotEmpty)
                          Text('🛍️ $itemsSummary',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.blueGrey[800])),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: const Color(0xB2EE6083),
        automaticallyImplyLeading: false,
        title: Text(
          _selectedTabIndex == 0 ? 'Okybd' : 'Completed Sales Sheet',
          style: GoogleFonts.interTight(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchDashboardData,
          ),
        ],
        elevation: 2,
      ),
      body: SafeArea(
        top: true,
        child: _selectedTabIndex == 0
            ? _buildOrdersDashboard(theme)
            : _buildCompletedOrdersSheet(),
      ),
      // নিচে পরিষ্কার নেভিগেশন বার
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTabIndex,
        selectedItemColor: const Color(0xFFD83B65),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.table_chart_outlined),
            label: 'Sales Sheet',
          ),
        ],
      ),
    );
  }
}
