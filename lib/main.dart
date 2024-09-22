import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slip_genrater/Provider/report_provider.dart';
import 'package:slip_genrater/Screen/login_page.dart';

void main() => runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ReportProvider()),
      ],
      child: MyApp(),
    ));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}
