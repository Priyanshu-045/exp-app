import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class settings extends StatefulWidget {
  const settings({super.key});

  @override
  State<settings> createState() => _settingsState();
}

class _settingsState extends State<settings> {
    Future<void> clearSharedPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear(); 
 }

 Future<void> handleLogout(BuildContext context) async {

  await clearSharedPrefs();
  Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil('/signin', (route) => false);
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'General Settings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            subtitle: const Text('English'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.file_copy_rounded),
            title: const Text('Terms and conditions'),
            onTap: () {},
          ),

          const Divider(),

          const Text(
            'Account',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              handleLogout(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.policy),
            title: const Text('Privacy policy'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Security'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
