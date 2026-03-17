import 'package:flutter/material.dart';

class FirstRunScreen extends StatelessWidget {
  static const String onboardingCompleteKey = 'onboardingComplete';
  final VoidCallback? onComplete;

  const FirstRunScreen({Key? key, this.onComplete}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome to WebBuddy')),
      body: Center(
        child: ElevatedButton(
          onPressed: onComplete ?? () {},
          child: const Text('Finish Onboarding'),
        ),
      ),
    );
  }
}
