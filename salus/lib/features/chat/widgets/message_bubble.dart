import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

enum MessageSender { user, bot }

enum UrgencyLevel { high, medium, low }

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
                      : Colors.black.withValues(alpha: 0.5),
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
            UrgencyBadge(level: message.urgency!),
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

class UrgencyBadge extends StatelessWidget {
  final UrgencyLevel level;

  const UrgencyBadge({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final cfg = _config();
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: cfg.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cfg.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: cfg.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            cfg.text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: cfg.color,
            ),
          ),
        ],
      ),
    );
  }

  _UrgencyConfig _config() {
    switch (level) {
      case UrgencyLevel.high:
        return const _UrgencyConfig(
          text: 'Urgência alta · Atendimento imediato',
          color: AppColors.urgencyHigh,
          surface: AppColors.urgencyHighSurface,
          border: AppColors.urgencyHighBorder,
        );
      case UrgencyLevel.medium:
        return const _UrgencyConfig(
          text: 'Urgência moderada · Procure atendimento hoje',
          color: AppColors.urgencyMedium,
          surface: AppColors.urgencyMediumSurface,
          border: AppColors.urgencyMediumBorder,
        );
      case UrgencyLevel.low:
        return const _UrgencyConfig(
          text: 'Urgência baixa · Monitore os sintomas',
          color: AppColors.urgencyLow,
          surface: AppColors.urgencyLowSurface,
          border: AppColors.urgencyLowBorder,
        );
    }
  }
}

class _UrgencyConfig {
  final String text;
  final Color color;
  final Color surface;
  final Color border;
  const _UrgencyConfig(
      {required this.text,
      required this.color,
      required this.surface,
      required this.border});
}