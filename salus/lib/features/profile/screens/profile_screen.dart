import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Dados simulados — serão substituídos pela integração com FastAPI
  static const String _userName = 'Yasmin Viegas';
  static const String _userEmail = 'yasmin@email.com';
  static const String _userInitials = 'YV';

  // Dados de saúde simulados — virão do cadastro via FastAPI
  static const int _userAge = 22;
  static const String _userGender = 'Feminino';
  static const double _userWeight = 58.0;
  static const int _userHeight = 165;

  // IMC calculado
  static double get _userImc {
    final h = _userHeight / 100;
    return _userWeight / (h * h);
  }

  static (String, Color) get _imcCategory {
    final imc = _userImc;
    if (imc < 18.5) return ('Abaixo do peso', AppColors.manchesterBlue);
    if (imc < 25.0) return ('Peso normal', AppColors.manchesterGreen);
    if (imc < 30.0) return ('Sobrepeso', AppColors.manchesterYellow);
    if (imc < 35.0) return ('Obesidade grau I', AppColors.manchesterOrange);
    return ('Obesidade grau II+', AppColors.manchesterRed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHealthDataSection(),
                  const SizedBox(height: 24),
                  _buildHistorySection(),
                  const SizedBox(height: 24),
                  _buildSettingsSection(context),
                  const SizedBox(height: 20),
                  _buildLogoutButton(context),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: AppColors.blue,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.blue, AppColors.mint],
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 48),
              Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.blueLight,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 3),
                    ),
                    child: const Center(
                      child: Text(
                        _userInitials,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.blue,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4)
                        ],
                      ),
                      child: const Icon(Icons.edit_rounded,
                          size: 14, color: AppColors.blue),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                _userName,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _userEmail,
                style: TextStyle(
                  color: AppColors.white.withOpacity(0.8),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_outlined, size: 14, color: AppColors.white),
                    SizedBox(width: 4),
                    Text(
                      AppStrings.profileEdit,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Seção de dados de saúde ────────────────────────────────────────────

  Widget _buildHealthDataSection() {
    final (imcLabel, imcColor) = _imcCategory;
    final imc = _userImc;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Dados de saúde',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.blueSurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Editar',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Cards de métricas: linha 1
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: Icons.cake_outlined,
                label: 'Idade',
                value: '$_userAge anos',
                color: AppColors.blue,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.wc_rounded,
                label: 'Gênero',
                value: _userGender,
                color: AppColors.mint,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Cards de métricas: linha 2
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: Icons.monitor_weight_outlined,
                label: 'Peso',
                value: '${_userWeight.toStringAsFixed(1)} kg',
                color: AppColors.blue,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.height_rounded,
                label: 'Altura',
                value: '$_userHeight cm',
                color: AppColors.mint,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Card do IMC — ocupa linha inteira com barra de progresso
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: imcColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.calculate_outlined,
                        color: imcColor, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'IMC',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${imc.toStringAsFixed(1)} · $imcLabel',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: imcColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Barra visual do IMC (escala 15–40)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: ((imc - 15) / 25).clamp(0.0, 1.0),
                  backgroundColor: AppColors.surface,
                  valueColor: AlwaysStoppedAnimation<Color>(imcColor),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('15',
                      style: TextStyle(
                          fontSize: 10, color: AppColors.textHint)),
                  Text('18,5',
                      style: TextStyle(
                          fontSize: 10, color: AppColors.textHint)),
                  Text('25',
                      style: TextStyle(
                          fontSize: 10, color: AppColors.textHint)),
                  Text('30',
                      style: TextStyle(
                          fontSize: 10, color: AppColors.textHint)),
                  Text('40',
                      style: TextStyle(
                          fontSize: 10, color: AppColors.textHint)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Histórico ──────────────────────────────────────────────────────────

  Widget _buildHistorySection() {
    final history = [
      _HistoryItem(
        title: 'Dor de cabeça e febre',
        date: 'Hoje · 09:38',
        color: AppColors.blue,
        icon: Icons.chat_bubble_outline_rounded,
      ),
      _HistoryItem(
        title: 'Exame de glicose analisado',
        date: 'Ontem · 15:12',
        color: AppColors.mint,
        icon: Icons.science_outlined,
      ),
      _HistoryItem(
        title: 'Dor nas costas há 3 dias',
        date: '03 jun · 11:45',
        color: AppColors.blue,
        icon: Icons.chat_bubble_outline_rounded,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.profileHistory,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...history.map((item) => _buildHistoryCard(item)),
      ],
    );
  }

  Widget _buildHistoryCard(_HistoryItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, color: item.color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(item.date,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textHint)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.textHint, size: 20),
        ],
      ),
    );
  }

  // ── Configurações ──────────────────────────────────────────────────────

  Widget _buildSettingsSection(BuildContext context) {
    final settings = [
      _SettingsItem(
        icon: Icons.lock_outline_rounded,
        label: AppStrings.profilePrivacy,
        onTap: () {},
      ),
      _SettingsItem(
        icon: Icons.description_outlined,
        label: AppStrings.profileTerms,
        onTap: () {},
      ),
      _SettingsItem(
        icon: Icons.notifications_outlined,
        label: 'Notificações',
        onTap: () {},
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.profileSettings,
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Column(
            children: settings.asMap().entries.map((entry) {
              final isLast = entry.key == settings.length - 1;
              return Column(
                children: [
                  ListTile(
                    leading: Icon(entry.value.icon,
                        color: AppColors.textSecondary, size: 22),
                    title: Text(entry.value.label,
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.textPrimary)),
                    trailing: const Icon(Icons.chevron_right_rounded,
                        color: AppColors.textHint, size: 20),
                    onTap: entry.value.onTap,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  ),
                  if (!isLast)
                    const Divider(
                        height: 0.5, indent: 56, color: AppColors.border),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamedAndRemoveUntil(
          context, '/login', (route) => false),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF0F0),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFFCCCC), width: 0.5),
        ),
        child: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFE53935), size: 22),
            SizedBox(width: 12),
            Text(
              AppStrings.profileLogout,
              style: TextStyle(
                  color: Color(0xFFE53935),
                  fontSize: 15,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryItem {
  final String title;
  final String date;
  final Color color;
  final IconData icon;
  const _HistoryItem(
      {required this.title,
      required this.date,
      required this.color,
      required this.icon});
}

class _SettingsItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SettingsItem(
      {required this.icon, required this.label, required this.onTap});
}