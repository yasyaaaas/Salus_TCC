import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class EthicalWarningBar extends StatelessWidget {
  const EthicalWarningBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.warning,
        border: Border(
          bottom: BorderSide(color: AppColors.warningBorder, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.warningBorder,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              size: 16,
              color: AppColors.warningPhrase,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              AppStrings.ethicalWarning,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.warningPhrase,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}