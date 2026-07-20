using MediatR;
using SistemaCitas.Application.Common.Interfaces;

namespace SistemaCitas.Application.Chat.Commands.EnviarMensajeChat;

public sealed record EnviarMensajeChatCommand(string Mensaje, List<MensajeChatDto> Historial)
    : IRequest<RespuestaChatDto>, IAuthorizedRequest
{
    public string[] RolesPermitidos => new[] { "Paciente", "admin" };
}