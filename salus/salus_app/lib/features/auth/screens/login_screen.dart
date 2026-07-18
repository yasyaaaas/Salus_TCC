import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  // Controle do formulário e dos campos de entrada.
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  // Controla a visibilidade da senha e o estado de carregamento do botão.
  bool _obscurePass = true;
  bool _isLoading = false;

  // Animação de entrada da tela para dar um efeito mais refinado.
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
    // libera os recursos da animação e dos controladores de texto ao sair da tela
    _anim.dispose();
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  // Valida os campos, envia a tentativa de login e trata a resposta da API.
  void _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return; // se o formulário não for válido, não faz nada

    setState(() => _isLoading = true); // mostra o indicador de carregamento

    final resultado = await ApiService().login( // faz a chamada para a API de login com os dados do formulário
      email: _emailController.text.trim(),
      password: _passController.text,
    );

    if (!mounted) return; // se a tela não estiver mais montada não faz nada
    setState(() => _isLoading = false); // esconde o indicador de carregamento

    if (resultado.isSuccess) {
      Navigator.pushReplacementNamed(context, '/chat'); // se o login for bem sucedido, navega para a tela de chat
    } else {
      ScaffoldMessenger.of(context).showSnackBar( // se o login falhar mostra uma mensagem de erro
        SnackBar(
          content: Text(resultado.error ?? 'Erro ao fazer login'),
          backgroundColor: AppColors.urgencyHigh,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // garante que a barra de status fique com estilo claro na tela de login
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: FadeTransition(
              opacity: _fade,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(24),
                        border:
                            Border.all(color: AppColors.cardBorderLight, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowSoft,
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel(AppStrings.email),
                            const SizedBox(height: 8),
                            _buildEmailField(),
                            const SizedBox(height: 20),
                            _buildLabel(AppStrings.password),
                            const SizedBox(height: 8),
                            _buildPasswordField(),
                            const SizedBox(height: 6),
                            _buildForgotPassword(),
                            const SizedBox(height: 22),
                            _buildLoginButton(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildRegisterLink(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // monta o topo da tela com o cabeçalho visual e a mensagem de boas-vindas
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 24,
        right: 24,
        bottom: 32,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF047857), Color(0xFF059669), Color(0xFF10B981)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Column(
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
          const SizedBox(height: 16),
          // Logo
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.favorite_rounded,
                    color: AppColors.white, size: 16),
              ),
              const SizedBox(width: 10),
              const Text(
                AppStrings.appName,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Bem-vinda\nde volta!',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.15,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Entre na sua conta para continuar',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0.1,
      ),
    );
  }

  // campo de email com validação simples para garantir que o usuário informe um valor válido.
  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: 'seu@email.com',
        filled: true,
        fillColor: AppColors.surface,
        prefixIcon: Container(
          margin: const EdgeInsets.all(10),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.mintSurface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.mail_outline_rounded,
              color: AppColors.mint, size: 18),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.mint, width: 1.5),
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Informe seu e-mail';
        if (!v.contains('@')) return 'E-mail inválido';
        return null;
      },
    );
  }

  // campo de senha com alternância entre mostrar e ocultar o conteúdo
  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passController,
      obscureText: _obscurePass,
      style: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: '••••••••',
        filled: true,
        fillColor: AppColors.surface,
        prefixIcon: Container(
          margin: const EdgeInsets.all(10),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.mintSurface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.lock_outline_rounded,
              color: AppColors.mint, size: 18),
        ),
        suffixIcon: GestureDetector(
          onTap: () => setState(() => _obscurePass = !_obscurePass),
          child: Icon(
            _obscurePass
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: AppColors.textHint,
            size: 20,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.mint, width: 1.5),
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Informe sua senha';
        if (v.length < 6) return 'Mínimo de 6 caracteres';
        return null;
      },
    );
  }

  // link para recuperação de senha -> "em desenvolvimento"
  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => _showEmDesenvolvimentoDialog(context),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
          foregroundColor: AppColors.mint,
        ),
        child: const Text(
          AppStrings.forgotPassword,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

 // mostra um diálogo informando que a funcionalidade ainda está em desenvolvimento
  void _showEmDesenvolvimentoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(
          Icons.construction_rounded,
          color: AppColors.mint,
          size: 32,
        ),
        title: const Text(
          'Em desenvolvimento',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        content: const Text(
          'A recuperação de senha por e-mail ainda está sendo desenvolvida. Em breve essa funcionalidade estará disponível.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Entendi',
              style: TextStyle(
                color: AppColors.mint,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // botão principal de login com feedback de carregamento
  Widget _buildLoginButton() {
    return Material(
      color: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: _isLoading ? null : AppColors.mintGradient,
          color: _isLoading ? AppColors.surface : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isLoading
              ? []
              : [
                  BoxShadow(
                    color: AppColors.mint.withValues(alpha: 0.4),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _isLoading ? null : _handleLogin,
            child: Center(
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: AppColors.mint, strokeWidth: 2.5),
                    )
                  : const Text(
                      AppStrings.login,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  // link de navegação para a tela de cadastro
  Widget _buildRegisterLink(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => Navigator.pushReplacementNamed(context, '/register'),
        child: RichText(
          text: const TextSpan(
            text: 'Não tem conta?',
            style: TextStyle(color: AppColors.textHint, fontSize: 14),
            children: [
              TextSpan(
                text: 'Cadastrar',
                style: TextStyle(
                  color: AppColors.mint,
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