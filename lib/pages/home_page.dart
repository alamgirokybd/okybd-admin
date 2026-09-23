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
  String? _errorMessage;
  List<dynamic> _orders = [];
  String _totalSales = '0.00';
  String _totalOrders = '0';

  final String _ordersUrl =
      'https://okybd.com/wp-json/wc/v3/orders?per_page=50&consumer_key=ck_45ae03c28b4b8b6fc1ff1b1d1ef3e6e0062db840&consumer_secret=cs_6d16165fbc1a7815876093e225317dfe714f39e6';
  final String _reportsUrl =
      'https://okybd.com/wp-json/wc/v3/reports/sales?consumer_key=ck_45ae03c28b4b8b6fc1ff1b1d1ef3e6e0062db840&consumer_secret=cs_6d16165fbc1a7815876093e225317dfe714f39e6';

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
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
                                const Icon(Icons.monetization_on,
                                    color: Color(0xFF119AFF), size: 32),
                                const SizedBox(height: 6),
                                Text(
                                  'TK $_totalSales',
                                  style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Total Revenue',
                                  style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: Colors.grey[700]),
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
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Total Orders',
                                  style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: Colors.grey[700]),
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
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      final order = _orders[index];
                      final billing = order['billing'] ?? {};
                      final customerName = (billing['first_name'] != null &&
                              billing['first_name'].toString().isNotEmpty)
                          ? '${billing['first_name']} ${billing['last_name'] ?? ''}'
                              .trim()
                          : 'Guest Customer';

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 1,
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      OrderDetailsPageWidget(orderData: order),
                                ),
                              );
                            },
                            title: Text(
                              customerName,
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            subtitle:
                                Text('#${order['id']} • ${order['status'] ?? ''}'),
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
