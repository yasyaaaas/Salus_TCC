import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  @override
  // inicializa a animação de entrada do onboarding
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  // libera os recursos do controlador de animação quando a tela é desmontada
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  // constrói a interface do onboarding com fundo gradiente, formas decorativas e conteúdo animado
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return Scaffold(
      body: Stack(
        children: [
          // Fundo com gradiente diagonal azul
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E3A8A), Color(0xFF1D4ED8), Color(0xFF0284C7)],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),
          // Círculo decorativo superior
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            top: 60,
            right: 40,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            top: 180,
            left: -50,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          // Forma inferior
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.32,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
              ),
            ),
          ),
          // Conteúdo
          SafeArea(
            child: FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideUp,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 36),
                      _buildLogo(),
                      const SizedBox(height: 48),
                      _buildFeatureCards(),
                      const Spacer(),
                      _buildButtons(context),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // monta a seção de logo com ícone, nome do app e slogan
  Widget _buildLogo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ícone em vidro fosco
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: AppColors.glassWhite,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.wechat_rounded,
            color: AppColors.white,
            size: 32,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          AppStrings.appName,
          style: TextStyle(
            color: AppColors.white,
            fontSize: 42,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.5,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.appTagline,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.72),
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }

  // cria os cards de recursos exibidos na tela de onboarding
  Widget _buildFeatureCards() {
    final features = [
      (
        Icons.chat_bubble_outline_rounded,
        AppColors.blue,
        AppColors.blueSurface,
        AppStrings.feature1Title,
        AppStrings.feature1Desc,
      ),
      (
        Icons.biotech_outlined,
        AppColors.mint,
        AppColors.mintSurface,
        AppStrings.feature2Title,
        AppStrings.feature2Desc,
      ),
      (
        Icons.location_on_outlined,
        const Color(0xFFF97316),
        const Color(0xFFFFF7ED),
        AppStrings.feature3Title,
        AppStrings.feature3Desc,
      ),
    ];

    return Column(
      children: features
          .asMap()
          .entries
          .map(
            (e) => AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final delay = e.key * 0.12;
                final progress = (((_controller.value - delay) / (1.0 - delay))
                    .clamp(0.0, 1.0));
                return Opacity(
                  opacity: progress,
                  child: Transform.translate(
                    offset: Offset(0, 16 * (1 - progress)),
                    child: child,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _FeatureCard(
                  icon: e.value.$1,
                  iconColor: e.value.$2,
                  iconBg: e.value.$3,
                  title: e.value.$4,
                  desc: e.value.$5,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  // cria a área de botões para iniciar cadastro ou acessar o login
  Widget _buildButtons(BuildContext context) {
    return Column(
      children: [
        // Botão primário com gradient
        Material(
          color: Colors.transparent,
          child: Ink(
            width: double.infinity,
            height: 54,
            decoration: BoxDecoration(
              gradient: AppColors.blueGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.blue.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.pushNamed(context, '/register'),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.onboardingStart,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded,
                        color: AppColors.white, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Botão secundário limpo
        Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Navigator.pushNamed(context, '/login'),
            child: Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: const Center(
                child: Text(
                  AppStrings.onboardingLogin,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String desc;

  // representa um card de recurso que aparece na tela de onboarding
  const _FeatureCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.cardBorderLight, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: iconColor.withValues(alpha: 0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      desc,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: AppColors.textHint),
            ],
          ),
        ),
      ),
    );
  }
}