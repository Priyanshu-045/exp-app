import 'package:expensem_app/pages/database.dart';
import 'package:expensem_app/pages/list.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/services.dart';

class Dash extends StatefulWidget {
  const Dash({super.key});

  @override
  State<Dash> createState() => _DashState();
}

class _DashState extends State<Dash> {
  final TextEditingController _incomeController = TextEditingController();
  final TextEditingController _itemsController = TextEditingController();
  final TextEditingController _spentController = TextEditingController();
  final NotchBottomBarController _controller = NotchBottomBarController(
    index: 0,
  );

  double remaining = 0.0;
  double expectedSavings = 0.0;

  bool showAlert = false;

  void _updateSummary() async {
    final prefs = await SharedPreferences.getInstance();

    final totalItems = await DatabaseHelper.instance.getTotalItemsPurchased();
    final totalSpent = await DatabaseHelper.instance.getTotalAmountSpent();

    _spentController.text = totalSpent.toStringAsFixed(2);
    _itemsController.text = totalItems.toString();

    final incomeText = _incomeController.text.trim();
    if (incomeText.isNotEmpty) {
      await prefs.setString('user_income', incomeText);
    }

    final income = double.tryParse(incomeText) ?? 0;
    final spent = totalSpent;

    setState(() {
      remaining = income - spent;
      expectedSavings = income * 0.2;
      showAlert = income > 0 && remaining < income * 0.3;
    });
  }

  void _exitApp(BuildContext context) {
    SystemNavigator.pop();
  }

  @override
  void initState() {
    super.initState();
    _loadIncome().then((_) => _updateSummary());
  }

  Widget _buildDrawerTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(2, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 30, color: const Color(0xFF36454F)),
              const SizedBox(height: 6),
              SizedBox(width: 5),
              Text(
                label,
                style: GoogleFonts.montserrat(
                  color: const Color(0xFF36454F),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadIncome() async {
    final prefs = await SharedPreferences.getInstance();
    String? income = prefs.getString('user_income');

    if (income != null && income.isNotEmpty) {
      setState(() {
        _incomeController.text = income;
      });
    }
  }

  Future<void> clearSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> handleLogout(BuildContext context) async {
    await clearSharedPrefs();
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushNamedAndRemoveUntil('/signin', (route) => false);
  }

  Future<void> _handleAddIncomeNavigation() async {
    final incomeText = _incomeController.text.trim();
    final income = double.tryParse(incomeText);

    if (income == null || income <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid income amount.'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_income', incomeText);

      Navigator.pushNamed(context, "/add").then((_) {
        _updateSummary();
      });
    }
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _itemsController.dispose();
    _spentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DASHBOARD', style: GoogleFonts.montserrat()),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'details') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const Listpg()),
                );
              }

              if (value == 'exit') {
                _exitApp(context);
              }
              if (value == 'settings') {
                Navigator.pushNamed(context, "/settings");
              }
              if (value == 'about') {
                Navigator.pushNamed(context, "/about");
              }
            },
            itemBuilder: (BuildContext context) => const [
              PopupMenuItem<String>(
                value: 'details',
                child: Text('View Details'),
              ),
              PopupMenuItem<String>(value: 'settings', child: Text('Settings')),
              PopupMenuItem<String>(value: 'about', child: Text('About')),
              PopupMenuItem<String>(value: 'exit', child: Text('Exit')),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: const Color(0xFF5E2BBF),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: Color(0xFF7B47E0)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white24,
                      child: Icon(
                        Icons.account_circle,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Welcome, User!',
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              _buildDrawerTile(
                icon: Icons.account_circle_rounded,
                label: 'Profile',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/profile');
                },
              ),
              _buildDrawerTile(
                icon: Icons.info_outline,
                label: 'Details',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/details');
                },
              ),
              _buildDrawerTile(
                icon: Icons.add_circle_outline,
                label: 'Add',
                onTap: () {
                  Navigator.pop(context);
                  _handleAddIncomeNavigation();
                },
              ),
              _buildDrawerTile(
                icon: Icons.settings,
                label: 'Settings',
                onTap: () {
                  Navigator.pushNamed(context, "/settings");
                  ;
                },
              ),
              _buildDrawerTile(
                icon: Icons.logout_rounded,
                label: 'Logout',
                onTap: () {
                  handleLogout(context);
                },
              ),
            ],
          ),
        ),
      ),

      // floatingActionButton: FloatingActionButton(
      //   child: const Icon(Icons.add),
      //   onPressed: () async {
      //     final incomeText = _incomeController.text.trim();
      //     final income = double.tryParse(incomeText);
      //     if (income == null || income <= 0) {
      //       ScaffoldMessenger.of(context).showSnackBar(
      //         const SnackBar(
      //           content: Text('Please enter a valid income amount.'),
      //           backgroundColor: Colors.red,
      //         ),
      //       );
      //     } else {
      //       final prefs = await SharedPreferences.getInstance();
      //       await prefs.setString('user_income', incomeText);
      //       Navigator.pushNamed(context, "/add").then((_) {
      //         _updateSummary();
      //       });
      //     }
      //   },
      // ),
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset("images/bck.jpg", fit: BoxFit.cover),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16,
              ),
              child: Column(
                children: [
                  Text(
                    'WELCOME',
                    style: GoogleFonts.bebasNeue(
                      fontWeight: FontWeight.bold,
                      fontSize: 36,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 20),

                          InfoCard(
                            icon: Icons.attach_money,
                            iconColor: const Color.fromARGB(255, 7, 78, 9),
                            label: 'Your Income',
                            child: TextFormField(
                              style: GoogleFonts.roboto(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                              controller: _incomeController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                fillColor: Colors.white,
                                filled: true,
                              ),
                              onChanged: (value) async {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setString('user_income', value);
                                _updateSummary();
                              },
                            ),
                          ),

                          const SizedBox(height: 20),

                          InfoCard(
                            icon: Icons.shopping_cart,
                            iconColor: Colors.orange,
                            label: 'Items Purchased',
                            child: TextFormField(
                              textAlign: TextAlign.center,
                              style: GoogleFonts.roboto(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              readOnly: true,
                              controller: _itemsController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                fillColor: Colors.white,
                                filled: true,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          InfoCard(
                            icon: Icons.money_off,
                            iconColor: Colors.red,
                            label: 'Total Spent',
                            child: TextFormField(
                              textAlign: TextAlign.center,
                              style: GoogleFonts.roboto(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                              readOnly: true,
                              controller: _spentController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                fillColor: Colors.white,
                                filled: true,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          InfoCard(
                            icon: Icons.savings,
                            iconColor: Colors.pinkAccent,
                            label: 'Expected Savings',
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xffa0a9b8),
                                ),
                              ),
                              child: Text(
                                '${expectedSavings.toStringAsFixed(2)}\$',
                                style: GoogleFonts.roboto(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.pinkAccent,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          InfoCard(
                            icon: Icons.account_balance_wallet,
                            iconColor: const Color.fromARGB(255, 133, 67, 43),
                            label: 'Remaining',
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.green),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${remaining.toStringAsFixed(2)}\$',
                                style: GoogleFonts.roboto(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade900,
                                ),
                              ),
                            ),
                          ),

                          if (showAlert)
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.red.shade700,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.warning, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text(
                                      'Warning: Low remaining balance!',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          const SizedBox(height: 90),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        color: const Color(0xFF5E2BBF),
        child: AnimatedNotchBottomBar(
          notchBottomBarController: _controller,
          color: const Color(0xFFDCDCDC),
          showLabel: true,
          notchColor: Colors.white,
          kIconSize: 24.0,
          kBottomRadius: 28.0,
          bottomBarItems: [
            BottomBarItem(
              inActiveItem: Icon(Icons.dashboard, color: Color(0xFF36454F)),
              activeItem: Icon(Icons.dashboard, color: Colors.amber),
              itemLabel: 'Dashboard',
            ),
            BottomBarItem(
              inActiveItem: Icon(Icons.info, color: Color(0xFF36454F)),
              activeItem: Icon(Icons.info, color: Colors.amber),

              itemLabel: 'Details',
            ),
            BottomBarItem(
              inActiveItem: Icon(Icons.add, color: Color(0xFF36454F)),
              activeItem: Icon(Icons.add, color: Colors.amber),
              itemLabel: 'Add',
            ),
          ],
          onTap: (index) async {
            _controller.index = index;
            switch (index) {
              case 0:
                break;
              case 1:
                Navigator.pushNamed(context, '/details');
                break;
              case 2:
                await _handleAddIncomeNavigation();
                break;
            }
            if (mounted) {
              setState(() {
                _controller.index = 0;
              });
            }
          },
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final Widget child;

  const InfoCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Card(
      elevation: 5,
      shadowColor: Colors.black45,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 26),
            const SizedBox(width: 12),
            SizedBox(
              width: screenWidth * 0.40,
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            const Spacer(),
            SizedBox(width: screenWidth * 0.30, child: child),
          ],
        ),
      ),
    );
  }
}
