import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

// representa o estado visual de um resultado de exame
enum ExamStatus { normal, high, low, indefinido }

// guarda os dados de um parâmetro do exame para exibir na tabela
class ExamResult {
  final String parameter;
  final String value;
  final String unit;
  final String reference;
  final ExamStatus status;
  final String? mensagem;

  const ExamResult({
    required this.parameter,
    required this.value,
    required this.unit,
    required this.reference,
    required this.status,
    this.mensagem,
  });

  // cria um objeto a partir do json retornado pela api
  factory ExamResult.fromJson(Map<String, dynamic> json) {
    return ExamResult(
      parameter: json['parametro'] as String,
      value: _formatNumero(json['valor']),
      unit: json['unidade'] as String,
      reference: _formatReferencia(json['valor_min'], json['valor_max']),
      status: _parseStatus(json['status'] as String),
      mensagem: json['mensagem'] as String?,
    );
  }

  // formata números para o padrão brasileiro com vírgula
  static String _formatNumero(dynamic valor) {
    final numero = (valor as num).toDouble();
    // troca ponto por vírgula pro padrão brasileiro (ex: 217.6 -> 217,6)
    final texto = numero % 1 == 0
        ? numero.toStringAsFixed(0)
        : numero.toString();
    return texto.replaceAll('.', ',');
  }

  // monta a faixa de referência para exibir na tabela
  static String _formatReferencia(dynamic min, dynamic max) {
    if (min == null && max == null) return 'Não determinada';
    if (min == null) return '< ${_formatNumero(max)}';
    if (max == null) return '> ${_formatNumero(min)}';
    return '${_formatNumero(min)} - ${_formatNumero(max)}';
  }

  // converte o status vindo da api em um enum interno
  static ExamStatus _parseStatus(String status) {
    switch (status) {
      case 'acima':
        return ExamStatus.high;
      case 'abaixo':
        return ExamStatus.low;
      case 'indefinido':
        return ExamStatus.indefinido;
      default:
        return ExamStatus.normal;
    }
  }
}

// widget que monta a tabela visual com os resultados do exame
class ExamResultTable extends StatelessWidget {
  final List<ExamResult> results;

  const ExamResultTable({super.key, required this.results});

  // monta o cabeçalho e as linhas da tabela
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        ...results.asMap().entries.map(
              (e) => _buildRow(e.value, isLast: e.key == results.length - 1),
            ),
      ],
    );
  }

  // cria o cabeçalho da tabela com os nomes das colunas
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: const Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Parâmetro',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Valor',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Referência',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Status',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // cria uma linha da tabela com os dados de um parâmetro
  Widget _buildRow(ExamResult r, {required bool isLast}) {
    final isAbnormal = r.status == ExamStatus.high || r.status == ExamStatus.low;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: isAbnormal
            ? AppColors.urgencyMediumSurface.withValues(alpha: 0.5)
            : AppColors.white,
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: AppColors.border, width: 0.5),
              ),
        borderRadius: isLast
            ? const BorderRadius.vertical(bottom: Radius.circular(16))
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                if (isAbnormal)
                  Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: r.status == ExamStatus.high
                          ? AppColors.urgencyMedium
                          : AppColors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
                Flexible(
                  child: Text(
                    r.parameter,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isAbnormal
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${r.value} ${r.unit}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isAbnormal
                    ? AppColors.urgencyMedium
                    : AppColors.mintDark,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              r.reference,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textHint,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(child: _buildStatusBadge(r.status)),
          ),
        ],
      ),
    );
  }

  // mostra o badge visual de acordo com o status do resultado
  Widget _buildStatusBadge(ExamStatus status) {
    switch (status) {
      case ExamStatus.normal:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.urgencyLowSurface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.urgencyLowBorder, width: 0.8),
          ),
          child: const Text(
            '✓ Ok',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.mintDark,
            ),
          ),
        );
      case ExamStatus.high:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.urgencyMediumSurface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.urgencyMediumBorder, width: 0.8),
          ),
          child: const Text(
            '↑ Alto',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.urgencyMedium,
            ),
          ),
        );
      case ExamStatus.low:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.blueSurface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.blueLight, width: 0.8),
          ),
          child: const Text(
            '↓ Baixo',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.blueDark,
            ),
          ),
        );
      case ExamStatus.indefinido:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border, width: 0.8),
          ),
          child: const Text(
            '? Consulte',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        );
    }
  }
}