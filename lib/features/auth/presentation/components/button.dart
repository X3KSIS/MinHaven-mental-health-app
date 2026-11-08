import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final void Function()? onTap;
  final String text;
  const MyButton({super.key, required this.onTap, required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(25.0),
        decoration: BoxDecoration(
          // button color
          color: Theme.of(context).colorScheme.tertiary,

          // curve corners
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Center(
          child: Text(
            text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
