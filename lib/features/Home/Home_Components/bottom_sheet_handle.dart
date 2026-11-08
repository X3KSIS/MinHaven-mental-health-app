import 'package:flutter/material.dart';
import '../../../themes/app_colors.dart';

class BottomSheetHandle extends StatelessWidget {
  const BottomSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: context.borderStrong,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}