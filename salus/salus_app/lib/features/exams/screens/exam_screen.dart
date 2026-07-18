import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/ethical_warning_bar.dart';
import '../widgets/exam_result_table.dart';

class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  bool _hasResults = false;
  bool _isProcessing = false;

  final List<ExamResult> _mockResults = const [
    ExamResult(
      parameter: 'Glicose',
      value: '128',
      unit: 'mg/dL',
      reference: '70-99',
      status: ExamStatus.high,
    ),
    ExamResult(
      parameter: 'Hemoglobina',
      value: '13,5',
      unit: 'g/dL',
      reference: '12-16',
      status: ExamStatus.normal,
    ),
    ExamResult(
      parameter: 'Colesterol total',
      value: '215',
      unit: 'mg/dL',
      reference: '< 200',
      status: ExamStatus.high,
    ),
    ExamResult(
      parameter: 'Triglicerídeos',
      value: '142',
      unit: 'mg/dL',
      reference: '< 150',
      status: ExamStatus.normal,
    ),
    ExamResult(
      parameter: 'Potássio',
      value: '3,2',
      unit: 'mEq/L',
      reference: '3,5-5,0',
      status: ExamStatus.low,
    ),
  ];

  List<ExamResult> get _abnormal =>
      _mockResults.where((r) => r.status != ExamStatus.normal).toList();

  void _pickImage() {
    setState(() => _isProcessing = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _hasResults   = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return Scaffold(
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
              GestureDetector(
                onTap: () => Navigator.maybePop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_back_rounded,
                      color: AppColors.white, size: 18),
                ),
              ),
              const SizedBox(width: 12),
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
                  onTap: () => setState(() => _hasResults = false),
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
              'Extraindo valores com OCR',
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
        // Card principal -> câmera
        GestureDetector(
          onTap: _pickImage,
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
                  child: const Icon(Icons.camera_alt_rounded,
                      color: AppColors.white, size: 32),
                ),
                const SizedBox(height: 16),
                const Text(
                  AppStrings.examsUpload,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mintDark,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Aponte a câmera para o laudo laboratorial',
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
        const SizedBox(height: 12),
        // Ou separador
        Row(
          children: [
            const Expanded(child: Divider(color: AppColors.border)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: const Text(
                'ou',
                style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textHint,
                    fontWeight: FontWeight.w500),
              ),
            ),
            const Expanded(child: Divider(color: AppColors.border)),
          ],
        ),
        const SizedBox(height: 12),
        // Botão galeria
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_library_outlined,
                    color: AppColors.textSecondary, size: 20),
                SizedBox(width: 8),
                Text(
                  AppStrings.examsGallery,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
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

  Widget _buildResultsView() {
    return Column(
      key: const ValueKey('results'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header de resultados
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
        // Tabela
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
            child: ExamResultTable(results: _mockResults),
          ),
        ),
        // Alertas
        if (_abnormal.isNotEmpty) ...[
          const SizedBox(height: 16),
          ..._abnormal.map((r) => _buildAlertCard(r)),
        ],
        const SizedBox(height: 24),
        // CTA para localização
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
                Icon(Icons.arrow_forward_rounded,
                    color: AppColors.white, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAlertCard(ExamResult r) {
    final isHigh = r.status == ExamStatus.high;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.urgencyMediumSurface,
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: AppColors.urgencyMedium, width: 3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: AppColors.urgencyMedium, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${r.parameter} ${isHigh ? 'acima' : 'abaixo'} do valor de referência. Procure um médico.',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.urgencyMedium,
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