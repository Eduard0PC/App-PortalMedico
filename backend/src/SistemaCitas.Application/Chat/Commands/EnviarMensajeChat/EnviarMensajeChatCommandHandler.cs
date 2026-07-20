using MediatR;
using SistemaCitas.Application.Common.Interfaces;

namespace SistemaCitas.Application.Chat.Commands.EnviarMensajeChat;

public sealed class EnviarMensajeChatCommandHandler
    : IRequestHandler<EnviarMensajeChatCommand, RespuestaChatDto>
{
    private readonly IChatService _chatService;

    public EnviarMensajeChatCommandHandler(IChatService chatService) => _chatService = chatService;

    public async Task<RespuestaChatDto> Handle(EnviarMensajeChatCommand request, CancellationToken ct)
    {
        var respuesta = await _chatService.ObtenerRespuestaAsync(
            request.Mensaje, request.Historial, ct);

        return new RespuestaChatDto(respuesta);
    }
}