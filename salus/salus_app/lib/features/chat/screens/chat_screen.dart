import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/ethical_warning_bar.dart';
import '../widgets/message_bubble.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/widgets/app_bottom_nav.dart';

// tela principal de conversa com o chatbot
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  late final AnimationController _dotAnim;

  // converte a cor recebida em um nível de urgência
  UrgencyLevel? _urgencyFromColor(String? color) {
    switch (color) {
      case 'vermelho':
        return UrgencyLevel.immediate;
      case 'laranja':
        return UrgencyLevel.veryUrgent;
      case 'amarelo':
        return UrgencyLevel.urgent;
      case 'verde':
        return UrgencyLevel.lessUrgent;
      case 'azul':
        return UrgencyLevel.notUrgent;
      default:
        return null;
    }
  }

  // inicializa o controlador de animação e carrega o histórico anterior
  @override
  void initState() {
  super.initState();
  _dotAnim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200))
    ..repeat();
  _carregarHistorico();
}

  // busca o histórico de mensagens já salvo para exibir na tela
  Future<void> _carregarHistorico() async {
    final resultado = await ApiService().getChatHistory();

    if (!mounted) return;

    if (resultado.isSuccess && resultado.data!.isNotEmpty) {
      final historico =
          resultado.data!.reversed; // API devolve mais recente primeiro

      for (final item in historico) { // a linah da tabela chat_messages guarda a mensagem e a resposta na mesma linha
        _messages.add( // assim separei em 2 bolhas
          // mensagem do usuario
          ChatMessage(
            text: item['mensagem_usuario'],
            sender: MessageSender.user,
            timestamp: DateTime.parse(item['created_at']),
          ),
        );
        _messages.add(
          // mensagem do chat
          ChatMessage(
            text: item['resposta_chatbot'],
            sender: MessageSender.bot,
            timestamp: DateTime.parse(item['created_at']),
            urgency: _urgencyFromColor(item['manchester_color']),
          ),
        );
      }
      setState(() {});
      _scrollToBottom();
    } else {
      _addBotMessage(AppStrings.chatWelcome); // se não tiver histórico cai na mesma inicial de sempre
    }
  }

  // libera os recursos usados pelo estado da tela
  @override
  void dispose() {
    _dotAnim.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // adiciona uma resposta do chatbot na lista de mensagens
  void _addBotMessage(String text, {UrgencyLevel? urgency}) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        sender: MessageSender.bot,
        timestamp: DateTime.now(),
        urgency: urgency,
      ));
    });
    _scrollToBottom();
  }

  // envia a mensagem do usuário e espera a resposta do chatbot
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage( // quem está mandando a mensagem é o usuario
          text: text,
          sender: MessageSender.user,
          timestamp: DateTime.now(),
        ),
      );
      _isTyping = true; // ... da ia "pensando"
    });
    _messageController.clear();
    _scrollToBottom();

    final resultado = await ApiService().sendChatMessage(text); // espera a resposta do chat

    if (!mounted) return;
    setState(() => _isTyping = false); // parou de pensar

    if (resultado.isSuccess) { // sucesso -> devolve a resposta do chat
      final dados = resultado.data!;
      _addBotMessage(
        dados['resposta'],
        urgency: _urgencyFromColor(dados['manchester_color']), // usa a mancgerter color depois avisando
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar( // se der erro msg de erro
        SnackBar(
          content: Text(resultado.error ?? 'Erro ao enviar mensagem'),
          backgroundColor: AppColors.urgencyHigh,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // leva a lista de mensagens para o fim após cada atualização
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // monta a estrutura visual da tela de chat
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          const EthicalWarningBar(),
          Expanded(child: _buildMessageList()),
          if (_isTyping) _buildTypingIndicator(),
          _buildInputBar(),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0), // navegação inferior entre chat, exames, unidades e perfil
    );
  }

  // constrói o cabeçalho com o nome e o status do chatbot
  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.blueGradient,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        child: Stack(
          children: [
            Positioned(
              top: -40,
              right: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              left: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: AppColors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            AppStrings.chatBotName,
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF4ADE80),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                AppStrings.chatOnline,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // exibe a lista de mensagens em formato de conversa
  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: MessageBubble(message: _messages[index]),
        );
      },
    );
  }

  // mostra a animação de digitação enquanto o chatbot responde
  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              gradient: AppColors.blueGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.favorite_rounded,
                color: AppColors.white, size: 12),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(18),
              ),
              border: Border.all(color: AppColors.border, width: 0.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) => _buildAnimatedDot(i)),
            ),
          ),
        ],
      ),
    );
  }

  // cria cada ponto da animação de digitação
  Widget _buildAnimatedDot(int index) {
    return Padding(
      padding: EdgeInsets.only(right: index < 2 ? 4 : 0),
      child: AnimatedBuilder(
        animation: _dotAnim,
        builder: (context, _) {
          final phase = (((_dotAnim.value * 3) - index) % 1.0).clamp(0.0, 1.0);
          final opacity = 0.3 + 0.7 * (1 - (phase - 0.5).abs() * 2).clamp(0.0, 1.0);
          return Opacity(
            opacity: opacity,
            child: Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: AppColors.blue,
                shape: BoxShape.circle,
              ),
            ),
          );
        },
      ),
    );
  }

  // monta a barra de digitação com campo de texto e botão de envio
  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: const Border(
            top: BorderSide(color: AppColors.border, width: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Botão de anexo
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/exams'),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.blueSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.attach_file_rounded,
                  color: AppColors.blue, size: 20),
            ),
          ),
          const SizedBox(width: 8),
          // Campo de texto
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border, width: 0.8),
              ),
              child: TextField(
                controller: _messageController,
                maxLines: 4,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: AppStrings.chatPlaceholder,
                  hintStyle: TextStyle(
                      fontSize: 14,
                      color: AppColors.textHint,
                      fontWeight: FontWeight.w400),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Botão enviar com gradient
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: AppColors.blueGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blue.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.send_rounded,
                  color: AppColors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}