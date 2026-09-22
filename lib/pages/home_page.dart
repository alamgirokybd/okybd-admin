[9/23/2026 12:09 AM] Okybd: import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../flutter_flow/flutter_flow_theme.dart';
import '../flutter_flow/flutter_flow_util.dart';
import 'order_details_page.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Map<String, dynamic>> mockOrders = [
    {
      'id': 1024,
      'customer': 'Akash Hossain',
      'item': 'Smart Fingerprint Padlock',
      'total': '৳ 1,450',
      'status': 'Processing',
      'date': '22 Sep 2026',
    },
    {
      'id': 1023,
      'customer': 'Rahim Uddin',
      'item': 'Bluetooth Smart Lock',
      'total': '৳ 2,200',
      'status': 'Completed',
      'date': '21 Sep 2026',
    },
    {
      'id': 1022,
      'customer': 'Kamal Hossain',
      'item': 'Smart Padlock A3',
      'total': '৳ 1,450',
      'status': 'Processing',
      'date': '20 Sep 2026',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: const Color(0xFF25E6B3),
        automaticallyImplyLeading: false,
        title: Text(
          'Okybd Admin',
          style: theme.headlineMedium.override(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
        elevation: 2.0,
      ),
      body: SafeArea(
        top: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard Overview',
                style: theme.titleLarge.override(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryText,
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Total Sales',
                      value: '৳ 42,500',
                      icon: Icons.attach_money,
                      color: const Color(0xFF4B39EF),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Total Orders',
                      value: '28',
                      icon: Icons.shopping_bag_outlined,
                      color: const Color(0xFF39D2C0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Orders',
                    style: theme.titleMedium.override(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryText,
                    ),
                  ),
                  Text(
                    '3 Orders',
                    style: theme.bodySmall.override(
                      color: theme.secondaryText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
[9/23/2026 12:09 AM] Okybd: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: mockOrders.length,
                itemBuilder: (context, index) {
                  final order = mockOrders[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    elevation: 1.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFFE8F5E9),
                        child: const Icon(
                          Icons.inventory_2_outlined,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      title: Text(
                        '#${order['id']} - ${order['customer']}',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 16.0,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4.0),
                          Text(
                            order['item'],
                            style: GoogleFonts.inter(fontSize: 14.0),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            '${order['date']} • ${order['status']}',
                            style: GoogleFonts.inter(
                              fontSize: 12.0,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            order['total'],
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.0,
                              color: const Color(0xFF4B39EF),
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: Colors.grey,
                            size: 20.0,
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const OrderDetailsPageWidget(),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
[9/23/2026 12:09 AM] Okybd: boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 6.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.12),
            radius: 20.0,
            child: Icon(icon, color: color, size: 22.0),
          ),
          const SizedBox(height: 12.0),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 13.0,
              color: const Color(0xFF57636C),
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF14181B),
            ),
          ),
        ],
      ),
    );
  }
}
