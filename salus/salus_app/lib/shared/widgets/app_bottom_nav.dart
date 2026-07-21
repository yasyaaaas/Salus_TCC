import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

// barra de navegação inferior usada em todas as telas principais
// cada tela informa apenas o índice da aba atual
class AppBottomNav extends StatelessWidget {
  final int currentIndex;

  const AppBottomNav({super.key, required this.currentIndex});

  // lista das rotas acessadas ao selecionar cada item da barra
  static const _rotas = ['/chat', '/exams', '/location', '/profile'];

  // monta a barra de navegação com os itens principais do app
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.8)),
      ),
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          // evita recarregar a mesma tela quando a aba atual é escolhida novamente
          if (index == currentIndex) return;
          Navigator.pushReplacementNamed(context, _rotas[index]);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: Icon(Icons.chat_bubble_rounded, color: AppColors.blue),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.biotech_outlined),
            selectedIcon: Icon(Icons.biotech_rounded, color: AppColors.mint),
            label: 'Exames',
          ),
          NavigationDestination(
            icon: Icon(Icons.location_on_outlined),
            selectedIcon: Icon(Icons.location_on_rounded, color: AppColors.mint),
            label: 'Unidades',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: AppColors.blue),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}