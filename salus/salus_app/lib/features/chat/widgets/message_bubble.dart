import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

enum MessageSender { user, bot }

/// Escala de Manchester — 5 níveis de triagem
/// Vermelho > Laranja > Amarelo > Verde > Azul
enum UrgencyLevel {
  /// Nível 1 — Imediato (vermelho)
  immediate,

  /// Nível 2 — Muito urgente (laranja)
  veryUrgent,

  /// Nível 3 — Urgente (amarelo)
  urgent,

  /// Nível 4 — Pouco urgente (verde)
  lessUrgent,

  /// Nível 5 — Não urgente (azul)
  notUrgent,
}

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

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == MessageSender.user;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isUser) _buildBotAvatar(),
          const SizedBox(height: 4),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.74,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              gradient: isUser ? AppColors.blueGradient : null,
              color: isUser ? null : AppColors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: isUser
                    ? const Radius.circular(18)
                    : const Radius.circular(4),
                bottomRight: isUser
                    ? const Radius.circular(4)
                    : const Radius.circular(18),
              ),
              border: isUser
                  ? null
                  : Border.all(color: AppColors.border, width: 0.8),
              boxShadow: [
                BoxShadow(
                  color: isUser
                      ? AppColors.blue.withValues(alpha: 0.18)
                      : Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              message.text,
              style: TextStyle(
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
            padding: EdgeInsets.only(
                left: isUser ? 0 : 4, right: isUser ? 4 : 0),
            child: Text(
              _formatTime(message.timestamp),
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textHint,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
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
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            gradient: AppColors.blueGradient,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.medical_services_rounded,
              color: AppColors.white, size: 12),
        ),
        const SizedBox(width: 6),
        const Text(
          'Salus',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }
}

/// Badge visual seguindo a Escala de Manchester
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
          // Quadrado colorido — padrão visual da Escala Manchester
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: cfg.color,
              borderRadius: BorderRadius.circular(3),
            ),
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

  _ManchesterConfig _config() {
    switch (level) {
      case UrgencyLevel.immediate:
        return _ManchesterConfig(
          levelLabel: 'Nível 1 — Imediato',
          actionText: 'Ligue 192 (SAMU) ou vá à UPA agora',
          color: AppColors.manchesterRed,
          surface: AppColors.manchesterRedSurface,
        );
      case UrgencyLevel.veryUrgent:
        return _ManchesterConfig(
          levelLabel: 'Nível 2 — Muito urgente',
          actionText: 'Busque atendimento em até 15 minutos',
          color: AppColors.manchesterOrange,
          surface: AppColors.manchesterOrangeSurface,
        );
      case UrgencyLevel.urgent:
        return _ManchesterConfig(
          levelLabel: 'Nível 3 — Urgente',
          actionText: 'Procure atendimento hoje',
          color: AppColors.manchesterYellow,
          surface: AppColors.manchesterYellowSurface,
        );
      case UrgencyLevel.lessUrgent:
        return _ManchesterConfig(
          levelLabel: 'Nível 4 — Pouco urgente',
          actionText: 'Consulte um médico em breve',
          color: AppColors.manchesterGreen,
          surface: AppColors.manchesterGreenSurface,
        );
      case UrgencyLevel.notUrgent:
        return _ManchesterConfig(
          levelLabel: 'Nível 5 — Não urgente',
          actionText: 'Monitore os sintomas',
          color: AppColors.manchesterBlue,
          surface: AppColors.manchesterBlueSurface,
        );
    }
  }
}

class _ManchesterConfig {
  final String levelLabel;
  final String actionText;
  final Color color;
  final Color surface;

  const _ManchesterConfig({
    required this.levelLabel,
    required this.actionText,
    required this.color,
    required this.surface,
  });
}

/// Mantido para retrocompatibilidade — use ManchesterBadge para novos usos
@Deprecated('Use ManchesterBadge com UrgencyLevel da Escala Manchester')
class UrgencyBadge extends ManchesterBadge {
  const UrgencyBadge({super.key, required super.level});
}