import 'package:flutter/material.dart';
import 'custom_buttons.dart'; // Import the custom buttons file

class ButtonShowCase extends StatefulWidget {
  const ButtonShowCase({super.key});

  @override
  State<ButtonShowCase> createState() => _ButtonShowcaseState();
}

class _ButtonShowcaseState extends State<ButtonShowCase> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Custom Buttons Showcase')),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Primary Button
              CustomButton.primary(
                text: 'Primary Button',
                onPressed: () {
                  print('Primary Button Pressed');
                },
                prefixIcon: Icons.send,
              ),
              SizedBox(height: 16),

              // Secondary Button
              CustomButton.secondary(
                text: 'Secondary Button',
                onPressed: () {
                  print('Secondary Button Pressed');
                },
                suffixIcon: Icons.arrow_forward,
              ),
              SizedBox(height: 16),

              // Success Button
              CustomButton.success(
                text: 'Success Button',
                onPressed: () {
                  print('Success Button Pressed');
                },
              ),
              SizedBox(height: 16),

              // Danger Button
              CustomButton.danger(
                text: 'Danger Button',
                onPressed: () {
                  print('Danger Button Pressed');
                },
                prefixIcon: Icons.delete,
              ),
              SizedBox(height: 16),

              // Gradient Button
              CustomButton.gradient(
                text: 'Gradient Button',
                gradient: LinearGradient(
                  colors: [Colors.purple, Colors.pink],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onPressed: () {
                  print('Gradient Button Pressed');
                },
              ),
              SizedBox(height: 16),

              // Loading Button
              CustomButton(
                text: 'Loading Button',
                isLoading: _isLoading,
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                  });

                  // Simulate an async operation
                  Future.delayed(Duration(seconds: 2), () {
                    setState(() {
                      _isLoading = false;
                    });
                  });
                },
              ),
              SizedBox(height: 16),

              // Disabled Button
              CustomButton(
                text: 'Disabled Button',
                isDisabled: true,
                onPressed: () {
                  // This won't be called
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}