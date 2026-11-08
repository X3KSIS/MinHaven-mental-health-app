import 'package:flutter/material.dart';

import '../../../../widgets/widget_support.dart';
class GoogleButton extends StatelessWidget {
  const GoogleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){AppWidget.showToast("Google");},
      child: Container(
        padding: EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Image.asset(
          "images/google.png",
          height: 32,
        ),
      ),
    );
  }
}
