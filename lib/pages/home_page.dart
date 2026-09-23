import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../flutter_flow/flutter_flow_theme.dart';
import 'order_details_page.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;
  List<dynamic> _orders = [];
  String _totalSales = '0.00';
  String _totalOrders = '0';

  // WooCommerce Credentials
  final String _baseUrl = 'https://okybd.com/wp-json/wc/v3';
  final String _consumerKey = 'ck_daec87e411b0e02c6fe9fc975f70bdf0a693ec97';
  final String _consumerSecret = 'cs_9fb28e7e1a6c4349dbfa22b10a2f1a66ffad164f';

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() => _isLoading = true);
    final String auth = 'Basic ' + base64Encode(utf8.encode('$_consumerKey:$_consumerSecret'));

    try {
      // 1. Fetch Orders
      final ordersResponse = await http.get(
        Uri.parse('$_baseUrl/orders?per_page=20'),
        headers: {'Authorization': auth},
      );

      if (ordersResponse.statusCode == 200) {
        final List<dynamic> ordersData = json.decode(ordersResponse.body);
        _orders = ordersData;
      }

      // 2. Fetch Reports
      final reportsResponse = await http.get(
        Uri.parse('$_baseUrl/reports/sales'),
        headers: {'Authorization': auth},
      );

      if (reportsResponse.statusCode == 200) {
        final List<dynamic> reportsData = json.decode(reportsResponse.body);
        if (reportsData.isNotEmpty) {
          _totalSales = reportsData[0]['total_sales']?.toString() ?? '0.00';
          _totalOrders = reportsData[0]['total_orders']?.toString() ?? '0';
        }
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
          'Okybd',
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
        child: RefreshIndicator(
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
                                const Icon(Icons.monetization_on, color: Color(0xFF119AFF), size: 32),
                                const SizedBox(height: 6),
                                Text(
                                  'TK $_totalSales',
                                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Total Revenue',
                                  style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[700]),
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
                                const Icon(Icons.shopping_bag, color: Color(0xFF1199FF), size: 32),
                                const SizedBox(height: 6),
                                Text(
                                  _totalOrders,
                                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Total Orders',
                                  style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[700]),
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
                        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 22),
                        onPressed: _fetchDashboardData,
                      ),
                    ],
                  ),
                ),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_orders.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: Text('No orders found')),
                  )
                else
                  ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      final order = _orders[index];
                      final billing = order['billing'] ?? {};
                      final customerName = (billing['first_name'] != null && billing['first_name'].toString().isNotEmpty)
                          ? '${billing['first_name']} ${billing['last_name'] ?? ''}'.trim()
                          : 'Guest Customer';

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 1,
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrderDetailsPageWidget(orderData: order),
                                ),
                              );
                            },
                            title: Text(
                              customerName,
                              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            subtitle: Text('#${order['id']} • ${order['status'] ?? ''}'),
                            trailing: Text(
                              'TK ${order['total'] ?? '0'}',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF21D421),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
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
        ),
      ),
    );
  }
}
