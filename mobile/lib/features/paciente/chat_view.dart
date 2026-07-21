import 'package:flutter/material.dart';
import '../../core/app_state.dart';
import '../../core/theme.dart';
import '../../shared/models/chat_message.dart';
import 'widgets/chat/barra_entrada_chat.dart';
import 'widgets/chat/burbuja_mensaje_chat.dart';
import 'widgets/chat/encabezado_chat.dart';
import 'widgets/chat/indicador_escribiendo_chat.dart';
import 'widgets/chat/sugerencias_rapidas_chat.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final List<ChatMessage> _mensajes = [];
  final TextEditingController _controladorEntrada = TextEditingController();
  final ScrollController _controladorDesplazamiento = ScrollController();
  bool _estaEnviando = false;

  static const List<String> _sugerenciasRapidas = [
    '¿Qué especialidades médicas tienen?',
    '¿Qué médicos atienden en la clínica?',
    '¿Qué médicos están disponibles esta semana?',
    '¿Cómo solicito una cita médica?',
  ];

  @override
  void initState() {
    super.initState();
    _mensajes.add(
      ChatMessage(
        sender: MessageSender.assistant,
        text: '¡Hola! Soy el asistente virtual de la clínica. Puedo responder tus dudas sobre nuestras especialidades, médicos del staff y disponibilidad de horarios.\n\n¿En qué te puedo ayudar hoy?',
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _controladorEntrada.dispose();
    _controladorDesplazamiento.dispose();
    super.dispose();
  }

  void _desplazarAlFinal() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_controladorDesplazamiento.hasClients) {
        _controladorDesplazamiento.animateTo(
          _controladorDesplazamiento.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _enviarMensaje([String? textoPersonalizado]) async {
    final textoAEnviar = (textoPersonalizado ?? _controladorEntrada.text).trim();
    if (textoAEnviar.isEmpty || _estaEnviando) return;

    if (textoPersonalizado == null) {
      _controladorEntrada.clear();
    }

    final mensajeUsuario = ChatMessage(
      sender: MessageSender.user,
      text: textoAEnviar,
      timestamp: DateTime.now(),
    );

    setState(() {
      _mensajes.add(mensajeUsuario);
      _estaEnviando = true;
    });

    _desplazarAlFinal();

    final appState = AppStateProvider.of(context);

    try {
      final historial = _mensajes
          .where((m) => !m.isError)
          .take(_mensajes.length - 1)
          .toList();

      final respuestaTexto = await appState.enviarMensajeChat(textoAEnviar, historial);

      if (mounted) {
        setState(() {
          _mensajes.add(
            ChatMessage(
              sender: MessageSender.assistant,
              text: respuestaTexto,
              timestamp: DateTime.now(),
            ),
          );
          _estaEnviando = false;
        });
        _desplazarAlFinal();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _mensajes.add(
            ChatMessage(
              sender: MessageSender.assistant,
              text: 'Lo siento, no pude obtener respuesta en este momento. ${e.toString().replaceAll("Exception: ", "")}',
              timestamp: DateTime.now(),
              isError: true,
            ),
          );
          _estaEnviando = false;
        });
        _desplazarAlFinal();
      }
    }
  }

  void _reiniciarConversacion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.refresh_rounded, color: AppTheme.primary),
            SizedBox(width: 8),
            Text('Reiniciar Chat'),
          ],
        ),
        content: const Text('¿Deseas borrar el historial de la conversación actual?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _mensajes.clear();
                _mensajes.add(
                  ChatMessage(
                    sender: MessageSender.assistant,
                    text: 'Conversación reiniciada. ¿En qué más puedo ayudarte?',
                    timestamp: DateTime.now(),
                  ),
                );
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Reiniciar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Encabezado superior del chat
        EncabezadoChat(alReiniciar: _reiniciarConversacion),

        // Lista de mensajes del chat
        Expanded(
          child: Container(
            color: AppTheme.background,
            child: ListView.builder(
              controller: _controladorDesplazamiento,
              padding: const EdgeInsets.all(16),
              itemCount: _mensajes.length + (_estaEnviando ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _mensajes.length && _estaEnviando) {
                  return const IndicadorEscribiendoChat();
                }

                final mensaje = _mensajes[index];

                // Mostrar sugerencias rápidas directamente debajo del mensaje de bienvenida inicial
                if (index == 0 && _mensajes.length <= 2) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BurbujaMensajeChat(mensaje: mensaje),
                      SugerenciasRapidasChat(
                        sugerencias: _sugerenciasRapidas,
                        estaEnviando: _estaEnviando,
                        alSeleccionarSugerencia: _enviarMensaje,
                      ),
                    ],
                  );
                }

                return BurbujaMensajeChat(mensaje: mensaje);
              },
            ),
          ),
        ),

        // Barra inferior para escribir y enviar mensajes
        BarraEntradaChat(
          controlador: _controladorEntrada,
          estaEnviando: _estaEnviando,
          alEnviar: _enviarMensaje,
        ),
      ],
    );
  }
}
