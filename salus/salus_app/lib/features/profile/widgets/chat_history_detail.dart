import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/formatted_text.dart';

// widget que mostra o detalhe de uma conversa salva no histórico
class ChatHistoryDetailSheet extends StatelessWidget {
  final String pergunta;
  final String resposta;
  final String data;
  final String? manchesterColor;
  final String? manchesterLabel;

  const ChatHistoryDetailSheet({
    super.key,
    required this.pergunta,
    required this.resposta,
    required this.data,
    this.manchesterColor,
    this.manchesterLabel,
  });

  // converte a cor recebida em uma cor visual para o badge de urgência
  Color _corDaFaixa(String? cor) {
    switch (cor) {
      case 'vermelho': return AppColors.manchesterRed;
      case 'laranja': return AppColors.manchesterOrange;
      case 'amarelo': return AppColors.manchesterYellow;
      case 'verde': return AppColors.manchesterGreen;
      case 'azul': return AppColors.manchesterBlue;
      default: return AppColors.textHint;
    }
  }

  // monta a tela em formato de bottom sheet com pergunta, resposta e badge
  @override
  Widget build(BuildContext context) {
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
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // cabeçalho com data e botão para fechar o detalhe
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(data, style: const TextStyle(fontSize: 13, color: AppColors.textHint)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close_rounded, color: AppColors.textHint),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border),
              // conteúdo rolável com a pergunta, a resposta e a indicação de urgência
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                        decoration: BoxDecoration(
                          color: AppColors.blueSurface,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(pergunta, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                      ),
                      const SizedBox(height: 16),
                      // resposta formatada do chatbot
                      FormattedText(
                        text: resposta,
                        baseStyle: const TextStyle(fontSize: 14, height: 1.55, color: AppColors.textPrimary),
                      ),
                      // badge visual da urgência quando a resposta tem classificação
                      if (manchesterColor != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: _corDaFaixa(manchesterColor).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: _corDaFaixa(manchesterColor).withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            manchesterLabel ?? '',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _corDaFaixa(manchesterColor)),
                          ),
                        ),
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
}