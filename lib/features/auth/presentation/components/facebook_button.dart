import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../../widgets/widget_support.dart';

class FacebookButton extends StatelessWidget {
  const FacebookButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){AppWidget.showToast("Facebook");},
      child: Container(
        padding: EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Image.asset("images/facebook.png", height: 32,),
      ),
    );
  }
}
