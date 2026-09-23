import 'package:flutter/material.dart';
import '../home/widgets/my_profile_content.dart';

class MyProfilePage extends StatelessWidget {
  const MyProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: const MyProfileContent(),
      ),
    );
  }
}
