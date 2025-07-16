import 'package:expensem_app/pages/about.dart';
import 'package:expensem_app/pages/add.dart';
import 'package:expensem_app/pages/list.dart';
import 'package:expensem_app/pages/loading.dart';
import 'package:expensem_app/pages/profile.dart';
import 'package:expensem_app/pages/settings.dart';
import 'package:expensem_app/pages/signin.dart';
import 'package:flutter/material.dart';
import 'package:expensem_app/pages/dash.dart';
import 'package:expensem_app/pages/signup.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        "/": (context) => Loading(),

        "/login": (context) => Dash(),
        "/signup": (context) => Signup(),
        "/signin": (context) => Signin(),
        "/add": (context) => const Add(),
        "/details": (context) => Listpg(),
        "/settings": (context) => settings(),
        "/about": (context) => About(),
        "/profile": (context) => Profile(),
      },
    ),
  );
}
