import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart'; // ✅ Vital para el texto bonito
import 'package:flutter_spinkit/flutter_spinkit.dart'; // ✅ Para la animación de carga
import 'package:anttec_movil/data/services/api/v1/rag_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final RagService _ragService = RagService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Lista de mensajes
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  // Colores de la marca (Morado Anttec)
  final Color _primaryColor = const Color(0xFF7E33A3);
  final Color _secondaryColor = const Color(0xFF5D247A);

  @override
  void initState() {
    super.initState();
    _initRAG();
  }

  /// Inicializa la IA y carga el saludo
  Future<void> _initRAG() async {
    setState(() => _isLoading = true);

    // Pequeña pausa para efecto visual
    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      setState(() {
        _messages.add({
          'role': 'assistant',
          'text':
              '¡Hola! 👋 Soy el asistente virtual de Anttec.\n\nEstoy listo para buscar en nuestro inventario. **¿Qué producto buscas hoy?**'
        });
      });
      _scrollToBottom();
    }

    // Indexamos la base de datos en segundo plano
    await _ragService.indexProducts();

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

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

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // 1. Agregamos el mensaje del usuario
    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _isLoading = true;
      _controller.clear();
    });
    _scrollToBottom();

    try {
      // 2. Consultamos a la IA (Mistral)
      final response = await _ragService.askQuestion(text);

      if (mounted) {
        setState(() {
          _messages.add({'role': 'assistant', 'text': response});
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({
            'role': 'assistant',
            'text': 'Tuve un error de conexión. Intenta de nuevo.'
          });
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _scrollToBottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7), // Fondo gris suave
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: _primaryColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                // ✅ .withValues para evitar el error de deprecated
                color: _primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child:
                  Icon(Icons.smart_toy_rounded, color: _primaryColor, size: 20),
            ),
            const SizedBox(width: 8),
            const Text(
              "Soporte IA",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              // Si está cargando, agregamos +1 item para el indicador
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return _buildTypingIndicator();
                }
                final msg = _messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  /// Indicador de "Escribiendo..." animado
  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, left: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SpinKitThreeBounce(
          color: _primaryColor,
          size: 15.0,
        ),
      ),
    );
  }

  /// Burbuja de mensaje (Aquí está la magia del Markdown)
  Widget _buildMessageBubble(Map<String, String> msg) {
    final isUser = msg['role'] == 'user';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar del Asistente (solo si no es usuario)
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: _primaryColor,
                child: const Icon(Icons.smart_toy_outlined,
                    size: 18, color: Colors.white),
              ),
            ),
            const SizedBox(width: 8),
          ],

          // Contenido del mensaje
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: isUser
                    ? LinearGradient(
                        colors: [_primaryColor, _secondaryColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isUser ? null : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: isUser
                  ? Text(
                      msg['text']!,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    )
                  : MarkdownBody(
                      data: msg['text']!,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(
                            color: Colors.black87, fontSize: 15, height: 1.4),
                        // Estilo para Negritas (Precios y Nombres)
                        strong: TextStyle(
                            color: _primaryColor, fontWeight: FontWeight.bold),
                        // Estilo para Listas
                        listBullet:
                            TextStyle(color: _primaryColor, fontSize: 16),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// Área de input (Caja de texto)
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F5),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.transparent),
                ),
                child: TextField(
                  controller: _controller,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: "Pregunta por un producto...",
                    hintStyle: TextStyle(color: Colors.black38, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _isLoading ? null : _sendMessage,
              child: Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: _isLoading ? Colors.grey[300] : _primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    if (!_isLoading)
                      BoxShadow(
                        color: _primaryColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
