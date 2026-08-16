import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../exams/widgets/exam_result_table.dart';

// widget que mostra o detalhe de uma análise de exame salva no histórico
class ExamHistoryDetailSheet extends StatelessWidget {
  final String nomeArquivo;
  final String data;
  final List<dynamic> resultadosJson;

  const ExamHistoryDetailSheet({
    super.key,
    required this.nomeArquivo,
    required this.data,
    required this.resultadosJson,
  });

  // monta o bottom sheet com a tabela de resultados e os alertas
  @override
  Widget build(BuildContext context) {
    final resultados = resultadosJson
        .map((item) => ExamResult.fromJson(item as Map<String, dynamic>))
        .toList();
    final alterados =
        resultados.where((r) => r.status != ExamStatus.normal).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // cabeçalho com nome do arquivo, data e botão de fechar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nomeArquivo,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            data,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textHint),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close_rounded,
                          color: AppColors.textHint),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border),
              // conteúdo rolável com a tabela de resultados e os alertas
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border, width: 0.8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: ExamResultTable(results: resultados),
                        ),
                      ),
                      if (alterados.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        ...alterados.map(_buildAlertRow),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // cria a caixa de alerta para resultados fora da referência
  Widget _buildAlertRow(ExamResult r) {
    final isIndefinido = r.status == ExamStatus.indefinido;
    final cor = isIndefinido ? AppColors.textSecondary : AppColors.urgencyMedium;
    final fundo = isIndefinido ? AppColors.surface : AppColors.urgencyMediumSurface;
    final icone = isIndefinido ? Icons.help_outline_rounded : Icons.warning_amber_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: cor, width: 3)),
      ),
      child: Row(
        children: [
          Icon(icone, color: cor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              r.mensagem ?? '${r.parameter} fora do valor de referência.',
              style: TextStyle(
                  fontSize: 13, color: cor, height: 1.4, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}