import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:anttec_movil/data/services/api/v1/chat_service.dart';

// Widgets
import 'package:anttec_movil/app/ui/chat/widgets/chat_message_item.dart';
import 'package:anttec_movil/app/ui/chat/widgets/chat_input_area.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();

  final List<Map<String, dynamic>> _messages = [
    {
      'role': 'bot',
      'content':
          '¡Hola! Soy tu asistente virtual de ANTTEC. 🤖\n¿En qué puedo ayudarte hoy?',
      'products': []
    }
  ];

  bool _isLoading = false;
  String? _conversationId;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'content': text, 'products': []});
      _isLoading = true;
    });

    _textController.clear();
    _scrollToBottom();

    try {
      final data =
          await _chatService.sendMessage(text, conversationId: _conversationId);

      final String botMessage = data['message'] ?? "Entendido.";
      final List<dynamic> products =
          (data['products'] is List) ? data['products'] : [];
      _conversationId = data['conversation_id'];

      if (mounted) {
        setState(() {
          _messages.add(
              {'role': 'bot', 'content': botMessage, 'products': products});
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      final errorMessage = e.toString().replaceAll("Exception: ", "");
      if (mounted) {
        setState(() {
          _messages
              .add({'role': 'bot', 'content': errorMessage, 'products': []});
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fondo gris muy suave para resaltar las burbujas blancas
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        title: const Text("Asistente IA",
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor:
            Colors.transparent, // Evita cambio de color al scrollear
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back_ios_new,
              color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey[200], height: 1),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ChatMessageItem(message: _messages[index]);
              },
            ),
          ),

          // Indicador de escritura
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.only(bottom: 15, left: 20),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                        color: Colors.grey, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 5),
                  const Text("Escribiendo...",
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontStyle: FontStyle.italic)),
                ],
              ),
            ),

          // Área de input
          ChatInputArea(
            controller: _textController,
            onSend: _sendMessage,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
}
