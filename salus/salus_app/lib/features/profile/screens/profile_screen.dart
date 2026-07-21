import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/widgets/legal_content.dart';
import '../../../core/constants/legal_texts.dart';
import '../widgets/edit_profile.dart';
import '../widgets/avatar_picker.dart';
import '../../../core/constants/avatars.dart';
import '../widgets/chat_history_detail.dart';
import '../../../shared/widgets/app_bottom_nav.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _historico = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });

    final resultados = await Future.wait([
      ApiService().getProfile(),
      ApiService().getChatHistory(),
    ]);

    if (!mounted) return;

    final resultadoPerfil = resultados[0];
    final resultadoHistorico = resultados[1];

    setState(() {
      _isLoading = false;
      if (resultadoPerfil.isSuccess) {
        _profile = resultadoPerfil.data as Map<String, dynamic>?;
      }
      if (resultadoHistorico.isSuccess) {
        _historico = (resultadoHistorico.data as List<dynamic>?) ?? [];
      }
    });
  }

  String get _userName => _profile?['full_name'] ?? '';
  String get _userEmail => _profile?['email'] ?? '';
  int get _userAge => _profile?['age'] ?? 0;
  String get _userGender => _profile?['gender'] ?? '';
  double get _userWeight => (_profile?['weight_kg'] as num?)?.toDouble() ?? 0;
  int get _userHeight => _profile?['height_cm'] ?? 0;
  double get _userImc => (_profile?['imc'] as num?)?.toDouble() ?? 0;
  String get _imcClassificationLabel => _profile?['imc_classification'] ?? '';

  Color get _imcColor {
    final imc = _userImc;
    if (imc < 18.5) return AppColors.manchesterBlue;
    if (imc < 25.0) return AppColors.manchesterGreen;
    if (imc < 30.0) return AppColors.manchesterYellow;
    if (imc < 35.0) return AppColors.manchesterOrange;
    return AppColors.manchesterRed;
  }

  Future<void> _abrirEdicaoPerfil() async { // abre o bottom sheet de edição de perfil e atualiza os dados se salvou
    if (_profile == null) return;

    final salvou = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditProfileSheet(currentProfile: _profile!),
    );

    if (salvou == true) {
      _loadProfile(); // recarrega os dados atualizados
    }
  }

  Future<void> _trocarAvatar() async {
    if (_profile == null) return;

    final novoAvatar = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          AvatarPickerSheet(currentAvatar: _profile!['avatar']),
    );

    if (novoAvatar == null) return; // pessoa fechou sem escolher nada

    final resultado = await ApiService().updateAvatar(novoAvatar); // chama a função de atualização do avatar na API
    if (!mounted) return;

    if (resultado.isSuccess) {
      setState(() => _profile = resultado.data); // atualiza a tela na hora
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resultado.error ?? 'Erro ao trocar avatar')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: const Center(
            child: CircularProgressIndicator(color: AppColors.blue)),
        bottomNavigationBar: AppBottomNav(currentIndex: 3), //  barra de navegação inferior, igual à usada no chat, exames e unidades
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.urgencyHigh,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(_errorMessage!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadProfile,
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: AppBottomNav(currentIndex: 3), // barra de navegação inferior, igual à usada no chat, exames e unidades
      );
    }

    // monta a tela principal com um layout rolável e as seções do perfil
    return Scaffold(
      backgroundColor: AppColors.background,
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
      bottomNavigationBar: AppBottomNav(currentIndex: 3),
    );
  }

  // cria o cabeçalho superior do perfil com foto, nome, email e botão de editar
  SliverAppBar _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: Colors.transparent,
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
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: -70,
                right: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.07),
                  ),
                ),
              ),
              Positioned(
                bottom: -20,
                left: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Positioned.fill(
                child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
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
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        AppAvatars.path(_profile?['avatar'] ?? 'Davely.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _trocarAvatar,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          size: 14,
                          color: AppColors.blue,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _userName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _userEmail,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.white.withValues(alpha: 0.8),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _abrirEdicaoPerfil,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: 14,
                        color: AppColors.white,
                      ),
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

  // Seção de dados de saúde

  // exibe os dados de saúde do usuário e um resumo visual do IMC
  Widget _buildHealthDataSection() {
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
            GestureDetector(
              onTap: _abrirEdicaoPerfil,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
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
            ),
          ],
        ),
        const SizedBox(height: 12),

        // cards de métricas linha 1
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
        ),
        const SizedBox(height: 10),

        // cards de métricas linha 2
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
        ),
        const SizedBox(height: 10),

        // card do IMC -> ocupa linha inteira com barra de progresso
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 0.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowSoft,
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _imcColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.calculate_outlined,
                      color: _imcColor,
                      size: 18,
                    ),
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
                        '${_userImc.toStringAsFixed(1)} · $_imcClassificationLabel',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _imcColor,
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
                  valueColor: AlwaysStoppedAnimation<Color>(_imcColor),
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

  // card reutilizável para mostrar cada métrica de saúde em formato compacto
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
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
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

  // Histórico 

  // monta a seção de histórico de conversas do usuário
  Widget _buildHistorySection() {
    // mostra uma mensagem simples quando ainda não existe nenhum registro
    if (_historico.isEmpty) {
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
          Container(
            padding: const EdgeInsets.all(20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: const Text(
              'Você ainda não conversou com o Salus',
              style: TextStyle(fontSize: 13, color: AppColors.textHint),
            ),
          ),
        ],
      );
    }

    // transforma cada item do histórico que veio da API em um card visual com título e data
    final items = _historico.map((registro) {
      return _HistoryItem(
        title: registro['mensagem_usuario'],
        date: _formatarDataHistorico(DateTime.parse(registro['created_at'])),
        color: AppColors.blue,
        icon: Icons.chat_bubble_outline_rounded,
        resposta: registro['resposta_chatbot'],
        manchesterColor: registro['manchester_color'],
        manchesterLabel: registro['manchester_label'],
      );
    }).toList();

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
        ...items.map((item) => _buildHistoryCard(item)),
      ],
    );
  }

  // formata a data do registro para mostrar hoje, ontem ou uma data resumida
  String _formatarDataHistorico(DateTime data) {
    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);
    final diaDoRegistro = DateTime(data.year, data.month, data.day);
    final hora =
        '${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';

    // mostra a hora diretamente quando o registro é de hoje
    if (diaDoRegistro == hoje) {
      return 'Hoje · $hora';
    }
    // usa a palavra ontem para o dia anterior
    if (diaDoRegistro == hoje.subtract(const Duration(days: 1))) {
      return 'Ontem · $hora';
    }
    final dia = data.day.toString().padLeft(2, '0');
    final meses = [
      'jan',
      'fev',
      'mar',
      'abr',
      'mai',
      'jun',
      'jul',
      'ago',
      'set',
      'out',
      'nov',
      'dez',
    ];
    return '$dia ${meses[data.month - 1]} · $hora';
  }

  // card individual para cada item do histórico exibido na tela
  Widget _buildHistoryCard(_HistoryItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: item.resposta == null
              ? null // se por algum motivo não tiver resposta associada, o card fica sem reagir ao toque
              : () {
                  showModalBottomSheet( // abre a tela de detalhe da conversa ao tocar no card
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => ChatHistoryDetailSheet(
                      pergunta: item.title,
                      resposta: item.resposta!,
                      data: item.date,
                      manchesterColor: item.manchesterColor,
                      manchesterLabel: item.manchesterLabel,
                    ),
                  );
                },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.12),
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
          ),
        ),
      ),
    );
  }

  // Configurações

  // exibe a seção de configurações com links para política de privacidade e termos de uso
  Widget _buildSettingsSection(BuildContext context) {
    final settings = [
      _SettingsItem(
        icon: Icons.lock_outline_rounded,
        label: AppStrings.profilePrivacy,
        onTap: () => LegalContentSheet.show(
          context,
          title: AppStrings.profilePrivacy,
          content: LegalTexts.privacyPolicy,
        ),
      ),
      _SettingsItem(
        icon: Icons.description_outlined,
        label: AppStrings.profileTerms,
        onTap: () => LegalContentSheet.show(
          context,
          title: AppStrings.profileTerms,
          content: LegalTexts.termsOfUse,
        ),
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
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowSoft,
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
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

  // botão de logout para encerrar a sessão e voltar para a tela de login
  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFCCCC), width: 0.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _handleLogout(context),
          child: const Padding(
            padding: EdgeInsets.all(14),
            child: Row(
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
        ),
      ),
    );
  }

  // exibe um diálogo de confirmação antes de efetuar o logout e limpar o token de autenticação
  Future<void> _handleLogout(BuildContext context) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(
          Icons.logout_rounded,
          color: Color(0xFFE53935),
          size: 32,
        ),
        title: const Text(
          'Sair da conta',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        content: const Text(
          'Tem certeza que deseja sair? Você vai precisar fazer login novamente.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Sair',
              style: TextStyle(
                color: Color(0xFFE53935),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmou != true) return;

    await ApiService().ClearToken();

    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }
}

class _HistoryItem {
  final String title;
  final String date;
  final Color color;
  final IconData icon;
  final String? resposta;
  final String? manchesterColor;
  final String? manchesterLabel;
  const _HistoryItem({
    required this.title,
    required this.date,
    required this.color,
    required this.icon,
    this.resposta,
    this.manchesterColor,
    this.manchesterLabel,
  });
}

class _SettingsItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SettingsItem(
      {required this.icon, required this.label, required this.onTap});
}