import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';

class SalusAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Gradient gradient;
  final List<Widget>? actions;
  final bool showBackButton;
  final Widget? leading;

  const SalusAppBar({
    super.key,
    required this.title,
    this.gradient = AppColors.blueGradient,
    this.actions,
    this.showBackButton = true,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: kToolbarHeight,
            child: Row(
              children: [
                if (showBackButton)
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: AppColors.white, size: 22),
                    onPressed: () => Navigator.maybePop(context),
                  )
                else if (leading != null)
                  leading!
                else
                  const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                if (actions != null) ...actions!,
                if (actions == null) const SizedBox(width: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + MediaQueryData.fromView(
          WidgetsBinding.instance.platformDispatcher.views.first,
        ).padding.top,
      );
}