import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/avatars.dart';

class AvatarPickerSheet extends StatelessWidget {
  final String currentAvatar;

  const AvatarPickerSheet({super.key, required this.currentAvatar});

  @override
  Widget build(BuildContext context) {
    // monta a folha inferior com a lista de avatares disponíveis para escolha
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Escolha seu avatar',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          // exibe os avatares em grade, destacando o item atualmente selecionado
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: AppAvatars.all.map((fileName) {
              final isSelected = fileName == currentAvatar;
              return GestureDetector(
                onTap: () => Navigator.pop(context, fileName),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.blueLight,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.blue : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: ClipOval(
                    child: Image.asset(AppAvatars.path(fileName)),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}