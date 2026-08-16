import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/widgets/ethical_warning_bar.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../widgets/exam_result_table.dart';

// tela de upload e análise de exames
class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

// controla o estado da tela de exames e os resultados recebidos
class _ExamScreenState extends State<ExamScreen> {
  bool _hasResults = false;
  bool _isProcessing = false;
  String? _errorMessage;
  List<ExamResult> _results = [];

  // lista apenas os resultados que precisam de atenção
  List<ExamResult> get _abnormal =>
      _results.where((r) => r.status != ExamStatus.normal).toList();

  // escolhe um pdf e envia para análise na api
  Future<void> _pickAndUploadPdf() async {
    final resultadoArquivo = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (resultadoArquivo == null || resultadoArquivo.files.single.path == null) {
      return; // usuário cancelou a seleção
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    final arquivo = File(resultadoArquivo.files.single.path!);
    final resultado = await ApiService().uploadExam(arquivo);

    if (!mounted) return;

    if (resultado.isSuccess) {
      setState(() {
        _results = resultado.data!
            .map((item) => ExamResult.fromJson(item as Map<String, dynamic>))
            .toList();
        _isProcessing = false;
        _hasResults = true;
      });
    } else {
      setState(() {
        _isProcessing = false;
        _errorMessage = resultado.error;
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resultado.error ?? 'Erro ao analisar o exame')),
        );
      }
    }
  }

  // monta a estrutura principal da tela com cabeçalho e conteúdo
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return Scaffold(
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
      body: Column(
        children: [
          _buildHeader(context),
          const EthicalWarningBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: _hasResults
                    ? _buildResultsView()
                    : _buildUploadView(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // cria o cabeçalho da tela com título e ação para iniciar outro exame
  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF047857), Color(0xFF059669), Color(0xFF10B981)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      AppStrings.examsTitle,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      AppStrings.examsSubtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (_hasResults)
                GestureDetector(
                  onTap: () => setState(() {
                    _hasResults = false;
                    _results = [];
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh_rounded,
                            color: AppColors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Novo',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // mostra a tela de upload quando ainda não há resultado
  Widget _buildUploadView() {
    if (_isProcessing) {
      return Container(
        key: const ValueKey('processing'),
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: AppColors.mintGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.mint.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                      color: AppColors.white, strokeWidth: 2.5),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Processando seu laudo...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Extraindo e interpretando os valores do PDF',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      key: const ValueKey('upload'),
      children: [
        if (_errorMessage != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.urgencyMediumSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.urgencyMediumBorder, width: 0.8),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: AppColors.urgencyMedium, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(fontSize: 12, color: AppColors.urgencyMedium),
                  ),
                ),
              ],
            ),
          ),
        ],
        // Card principal -> seleção de PDF
        GestureDetector(
          onTap: _pickAndUploadPdf,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.mintSurface, Color(0xFFD1FAE5)],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.urgencyLowBorder, width: 1),
            ),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: AppColors.mintGradient,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.mint.withValues(alpha: 0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.picture_as_pdf_rounded,
                      color: AppColors.white, size: 32),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Selecionar PDF do laudo',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mintDark,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Escolha o arquivo PDF do seu exame laboratorial',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        // Card informativo
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.blueSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.blueLight.withValues(alpha: 0.4)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.shield_outlined,
                  color: AppColors.blue, size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Seus dados são tratados com privacidade e não são compartilhados com terceiros.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.blueDark,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // mostra a tabela e os alertas quando o exame já foi processado
  Widget _buildResultsView() {
    return Column(
      key: const ValueKey('results'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.mintSurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.biotech_rounded,
                  color: AppColors.mint, size: 18),
            ),
            const SizedBox(width: 10),
            const Text(
              AppStrings.examsResults,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 0.8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: ExamResultTable(results: _results),
          ),
        ),
        if (_abnormal.isNotEmpty) ...[
          const SizedBox(height: 16),
          ..._abnormal.map((r) => _buildAlertCard(r)),
        ],
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.urgencyMediumSurface.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.urgencyMediumBorder.withValues(alpha: 0.45), width: 0.8),
          ),
          child: Row(
            children: [
              const Icon(Icons.medical_services_outlined,
                  color: AppColors.urgencyMedium, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Este resultado não substitui a avaliação de um médico',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.urgencyMedium,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/location'),
          child: Container(
            width: double.infinity,
            height: 54,
            decoration: BoxDecoration(
              gradient: AppColors.mintGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.mint.withValues(alpha: 0.38),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on_rounded,
                    color: AppColors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  AppStrings.examsCtaLocation,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 4),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // cria o card de alerta para resultados fora da referência
  Widget _buildAlertCard(ExamResult r) {
    final isIndefinido = r.status == ExamStatus.indefinido;
    final corPrincipal = isIndefinido ? AppColors.textSecondary : AppColors.urgencyMedium;
    final corSurface = isIndefinido ? AppColors.surface : AppColors.urgencyMediumSurface;
    final icone = isIndefinido ? Icons.help_outline_rounded : Icons.warning_amber_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: corSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: corPrincipal, width: 3)),
      ),
      child: Row(
        children: [
          Icon(icone, color: corPrincipal, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              r.mensagem ??
                  '${r.parameter} fora do valor de referência. Procure um médico.',
              style: TextStyle(
                fontSize: 13,
                color: corPrincipal,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}