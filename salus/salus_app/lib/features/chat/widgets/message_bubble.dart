import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/formatted_text.dart';

// identifica se a mensagem foi enviada pelo usuário ou pelo chatbot
enum MessageSender { user, bot }

// escala de manchester com 5 níveis de triagem
// vermelho, laranja, amarelo, verde e azul
// escala de manchester usada para classificar a urgência da resposta
enum UrgencyLevel {
  // nível 1 imediato vermelho
  immediate,

  // nível 2 muito urgente laranja
  veryUrgent,

  // nível 3 urgente amarelo
  urgent,

  // nível 4 pouco urgente verde
  lessUrgent,

  // nível 5 não urgente azul
  notUrgent,
}

// representa uma mensagem da conversa com os dados básicos de exibição
class ChatMessage {
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final UrgencyLevel? urgency;

  const ChatMessage({
    required this.text,
    required this.sender,
    required this.timestamp,
    this.urgency,
  });
}

// widget responsável por montar a bolha visual de cada mensagem
class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == MessageSender.user;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
      builder: (context, valor, child) {
        return Opacity(
          opacity: valor,
          child: Transform.translate(
            offset: Offset(0, 12 * (1 - valor)),
            child: child,
          ),
        );
      },
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isUser) _buildBotAvatar(),
            const SizedBox(height: 4),
            Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.74),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                gradient: isUser ? AppColors.blueGradient : null,
                color: isUser ? null : AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: isUser ? const Radius.circular(18) : const Radius.circular(4),
                  bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(18),
                ),
                border: isUser ? null : Border.all(color: AppColors.cardBorderLight, width: 0.8),
                boxShadow: [
                  BoxShadow(
                    color: isUser ? AppColors.blue.withValues(alpha: 0.18) : AppColors.shadowSoft,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: FormattedText( // transforma a resposta da api em um texto formatado
                text: message.text,
                baseStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.55,
                  color: isUser ? AppColors.white : AppColors.textPrimary,
                ),
              ),
            ),
            if (message.urgency != null) ...[
              const SizedBox(height: 6),
              ManchesterBadge(level: message.urgency!),
            ],
            const SizedBox(height: 2),
            Padding(
              padding: EdgeInsets.only(left: isUser ? 0 : 4, right: isUser ? 4 : 0),
              child: Text(
                _formatTime(message.timestamp),
                style: const TextStyle(fontSize: 10, color: AppColors.textHint, fontWeight: FontWeight.w400),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Widget _buildBotAvatar() {
    return Row(
      children: [
        Container(
          width: 26, height: 26,
          decoration: const BoxDecoration(gradient: AppColors.blueGradient, shape: BoxShape.circle),
          child: const Icon(Icons.favorite_rounded, color: AppColors.white, size: 12),
        ),
        const SizedBox(width: 6),
        const Text(
          'Salus',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.1),
        ),
      ],
    );
  }
}

// badge visual seguindo a escala de manchester
// badge visual que mostra o nível de urgência da resposta
class ManchesterBadge extends StatelessWidget {
  final UrgencyLevel level;

  const ManchesterBadge({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final cfg = _config();
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: cfg.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cfg.color.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // quadrado colorido com padrão visual da escala manchester
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(color: cfg.color, shape: BoxShape.circle),
            child: Icon(cfg.icon, size: 13, color: AppColors.white),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cfg.levelLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: cfg.color,
                  letterSpacing: 0.3,
                ),
              ),
              Text(
                cfg.actionText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: cfg.color.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // define as informações visuais de acordo com o nível de urgência
  _ManchesterConfig _config() {
    switch (level) {
      case UrgencyLevel.immediate:
        return _ManchesterConfig(
          levelLabel: 'Nível 1 — Imediato',
          actionText: 'Ligue 192 (SAMU) ou vá à UPA agora',
          color: AppColors.manchesterRed,
          surface: AppColors.manchesterRedSurface,
          icon: Icons.emergency_rounded,
        );
      case UrgencyLevel.veryUrgent:
        return _ManchesterConfig(
          levelLabel: 'Nível 2 — Muito urgente',
          actionText: 'Busque atendimento em até 15 minutos',
          color: AppColors.manchesterOrange,
          surface: AppColors.manchesterOrangeSurface,
          icon: Icons.priority_high_rounded,
        );
      case UrgencyLevel.urgent:
        return _ManchesterConfig(
          levelLabel: 'Nível 3 — Urgente',
          actionText: 'Procure atendimento hoje',
          color: AppColors.manchesterYellow,
          surface: AppColors.manchesterYellowSurface,
          icon: Icons.info_rounded,
        );
      case UrgencyLevel.lessUrgent:
        return _ManchesterConfig(
          levelLabel: 'Nível 4 — Pouco urgente',
          actionText: 'Consulte um médico em breve',
          color: AppColors.manchesterGreen,
          surface: AppColors.manchesterGreenSurface,
          icon: Icons.check_circle_outline_rounded,
        );
      case UrgencyLevel.notUrgent:
        return _ManchesterConfig(
          levelLabel: 'Nível 5 — Não urgente',
          actionText: 'Monitore os sintomas',
          color: AppColors.manchesterBlue,
          surface: AppColors.manchesterBlueSurface,
          icon: Icons.schedule_rounded,
        );
    }
  }
}

// guarda os dados de estilo usados pelo badge de urgência
class _ManchesterConfig {
  final String levelLabel;
  final String actionText;
  final Color color;
  final Color surface;
  final IconData icon;

  const _ManchesterConfig({
    required this.levelLabel,
    required this.actionText,
    required this.color,
    required this.surface,
    required this.icon,
  });
}

// mantido para retrocompatibilidade use ManchesterBadge para novos usos
@Deprecated('Use ManchesterBadge com UrgencyLevel da Escala Manchester')
class UrgencyBadge extends ManchesterBadge {
  const UrgencyBadge({super.key, required super.level});
}