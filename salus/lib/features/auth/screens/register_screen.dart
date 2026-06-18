import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _lgpdAccepted = false;
  bool _isLoading = false;
  String? _selectedGender;

  final List<String> _genderOptions = ['Feminino', 'Masculino', 'Outro'];

  late final AnimationController _anim;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (!_lgpdAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Aceite os termos de uso para continuar'),
          backgroundColor: AppColors.urgencyMedium,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      // TODO: integrar com backend FastAPI — enviar todos os dados incluindo
      // age, weight, height e gender para o perfil do usuário
      Future.delayed(const Duration(seconds: 1), () {
        setState(() => _isLoading = false);
        Navigator.pushReplacementNamed(context, '/chat');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: FadeTransition(
              opacity: _fade,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Dados de conta ──────────────────────────────
                      _buildSectionTitle('Dados da conta'),
                      const SizedBox(height: 16),
                      _buildField(
                        label: AppStrings.fullName,
                        controller: _nameController,
                        hint: 'Seu nome completo',
                        icon: Icons.person_outline_rounded,
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Informe seu nome' : null,
                      ),
                      const SizedBox(height: 18),
                      _buildField(
                        label: AppStrings.email,
                        controller: _emailController,
                        hint: 'seu@email.com',
                        icon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Informe seu e-mail';
                          if (!v.contains('@')) return 'E-mail inválido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      _buildPasswordField(
                        label: AppStrings.password,
                        controller: _passController,
                        obscure: _obscurePass,
                        onToggle: () =>
                            setState(() => _obscurePass = !_obscurePass),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Informe sua senha';
                          if (v.length < 6) return 'Mínimo de 6 caracteres';
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      _buildPasswordField(
                        label: AppStrings.confirmPassword,
                        controller: _confirmPassController,
                        obscure: _obscureConfirm,
                        onToggle: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                        validator: (v) => v != _passController.text
                            ? 'As senhas não coincidem'
                            : null,
                      ),

                      // ── Dados de saúde ───────────────────────────────
                      const SizedBox(height: 32),
                      _buildSectionTitle('Dados de saúde'),
                      const SizedBox(height: 4),
                      _buildSectionSubtitle(
                          'Usados para contextualizar as orientações do chatbot.'),
                      const SizedBox(height: 16),

                      // Linha: Idade + Gênero
                      Row(
                        children: [
                          Expanded(
                            child: _buildField(
                              label: 'Idade',
                              controller: _ageController,
                              hint: 'Ex: 22',
                              icon: Icons.cake_outlined,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(3),
                              ],
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Obrigatório';
                                final age = int.tryParse(v);
                                if (age == null || age < 1 || age > 120) {
                                  return 'Inválida';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildGenderDropdown(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Linha: Peso + Altura
                      Row(
                        children: [
                          Expanded(
                            child: _buildField(
                              label: 'Peso (kg)',
                              controller: _weightController,
                              hint: 'Ex: 65',
                              icon: Icons.monitor_weight_outlined,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Obrigatório';
                                final w = double.tryParse(
                                    v.replaceAll(',', '.'));
                                if (w == null || w < 1 || w > 300) {
                                  return 'Inválido';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildField(
                              label: 'Altura (cm)',
                              controller: _heightController,
                              hint: 'Ex: 165',
                              icon: Icons.height_rounded,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(3),
                              ],
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Obrigatório';
                                final h = int.tryParse(v);
                                if (h == null || h < 50 || h > 250) {
                                  return 'Inválida';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      // IMC calculado dinamicamente
                      const SizedBox(height: 12),
                      _buildImcPreview(),

                      // ── LGPD + Botão ─────────────────────────────────
                      const SizedBox(height: 28),
                      _buildLgpdCheckbox(),
                      const SizedBox(height: 28),
                      _buildRegisterButton(),
                      const SizedBox(height: 24),
                      _buildLoginLink(context),
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

  // ── Helpers de layout ────────────────────────────────────────────────────

  Widget _buildSectionTitle(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.2,
        ),
      );

  Widget _buildSectionSubtitle(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.textSecondary,
          height: 1.4,
        ),
      );

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 24,
        right: 24,
        bottom: 28,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFF3B82F6)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25), width: 1),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: AppColors.white, size: 18),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Criar conta',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.15,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Rápido, gratuito e seguro.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            letterSpacing: 0.1,
          ),
        ),
      );

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Container(
              margin: const EdgeInsets.all(10),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.blueSurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.blue, size: 18),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: '••••••••',
            prefixIcon: Container(
              margin: const EdgeInsets.all(10),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.blueSurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.lock_outline_rounded,
                  color: AppColors.blue, size: 18),
            ),
            suffixIcon: GestureDetector(
              onTap: onToggle,
              child: Icon(
                obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.textHint,
                size: 20,
              ),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Gênero'),
        DropdownButtonFormField<String>(
          value: _selectedGender,
          decoration: InputDecoration(
            prefixIcon: Container(
              margin: const EdgeInsets.all(10),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.blueSurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.wc_rounded,
                  color: AppColors.blue, size: 18),
            ),
          ),
          hint: const Text('Selecione',
              style: TextStyle(fontSize: 14, color: AppColors.textHint)),
          items: _genderOptions
              .map((g) => DropdownMenuItem(
                    value: g,
                    child: Text(g,
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.textPrimary)),
                  ))
              .toList(),
          onChanged: (v) => setState(() => _selectedGender = v),
          validator: (v) => v == null ? 'Selecione' : null,
        ),
      ],
    );
  }

  /// Preview do IMC calculado em tempo real
  Widget _buildImcPreview() {
    final weight =
        double.tryParse(_weightController.text.replaceAll(',', '.'));
    final heightCm = int.tryParse(_heightController.text);

    if (weight == null || heightCm == null || heightCm == 0) {
      return const SizedBox.shrink();
    }

    final heightM = heightCm / 100;
    final imc = weight / (heightM * heightM);
    final (label, color) = _imcCategory(imc);

    return AnimatedOpacity(
      opacity: 1,
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.calculate_outlined, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              'IMC: ${imc.toStringAsFixed(1)} — $label',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color),
            ),
          ],
        ),
      ),
    );
  }

  (String, Color) _imcCategory(double imc) {
    if (imc < 18.5) return ('Abaixo do peso', AppColors.manchesterBlue);
    if (imc < 25.0) return ('Peso normal', AppColors.manchesterGreen);
    if (imc < 30.0) return ('Sobrepeso', AppColors.manchesterYellow);
    if (imc < 35.0) return ('Obesidade grau I', AppColors.manchesterOrange);
    return ('Obesidade grau II+', AppColors.manchesterRed);
  }

  Widget _buildLgpdCheckbox() {
    return GestureDetector(
      onTap: () => setState(() => _lgpdAccepted = !_lgpdAccepted),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _lgpdAccepted ? AppColors.blueSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _lgpdAccepted ? AppColors.blue : AppColors.border,
            width: _lgpdAccepted ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: _lgpdAccepted ? AppColors.blue : AppColors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color:
                      _lgpdAccepted ? AppColors.blue : AppColors.surfaceHigh,
                  width: 1.5,
                ),
              ),
              child: _lgpdAccepted
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: AppColors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RichText(
                text: const TextSpan(
                  text: 'Aceito os ',
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.5),
                  children: [
                    TextSpan(
                      text: 'Termos de Uso',
                      style: TextStyle(
                          color: AppColors.blue, fontWeight: FontWeight.w600),
                    ),
                    TextSpan(text: ' e a '),
                    TextSpan(
                      text: 'Política de Privacidade',
                      style: TextStyle(
                          color: AppColors.blue, fontWeight: FontWeight.w600),
                    ),
                    TextSpan(text: ' (LGPD)'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _handleRegister,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: _isLoading ? null : AppColors.blueGradient,
          color: _isLoading ? AppColors.surface : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isLoading
              ? []
              : [
                  BoxShadow(
                    color: AppColors.blue.withValues(alpha: 0.38),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: AppColors.blue, strokeWidth: 2.5),
                )
              : const Text(
                  'Criar minha conta',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => Navigator.pushReplacementNamed(context, '/login'),
        child: RichText(
          text: const TextSpan(
            text: 'Já tenho conta?  ',
            style: TextStyle(color: AppColors.textHint, fontSize: 14),
            children: [
              TextSpan(
                text: 'Entrar',
                style: TextStyle(
                  color: AppColors.blue,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}