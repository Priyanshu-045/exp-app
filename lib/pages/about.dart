import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About Expensly',
              style: GoogleFonts.bebasNeue(fontSize: 32, color: Colors.teal),
            ),
            const SizedBox(height: 16),
            Text(
              'Expensly helps you manage your money with ease. Track your expenses and income, and get a clear overview of your total spending, remaining balance, and expected savings — all in one place.',
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: Colors.black87,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Key Features',
              style: GoogleFonts.bebasNeue(fontSize: 26, color: Colors.black),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: Icon(Icons.attach_money, color: Colors.green),
              title: Text('Track Expenses'),
              subtitle: Text('Log daily spending with ease.'),
            ),
            ListTile(
              leading: Icon(Icons.analytics, color: Colors.deepPurple),
              title: Text('Data Analytics'),
              subtitle: Text('Dashboard for income & expenses.'),
            ),
            ListTile(
              leading: Icon(Icons.savings, color: Colors.blue),
              title: Text('Savings Goals'),
              subtitle: Text('Plan and monitor savings targets.'),
            ),
          ],
        ),
      ),
    );
  }
}
