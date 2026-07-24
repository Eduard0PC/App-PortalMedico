using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SistemaCitas.Application.Chat;
using SistemaCitas.Application.Chat.Commands.EnviarMensajeChat;

namespace SistemaCitas.API.Controllers;

public sealed record EnviarMensajeRequest(string Mensaje, List<MensajeChatDto>? Historial);

[ApiController]
[Route("api/chat")]
public sealed class ChatController : ControllerBase
{
    private readonly ISender _sender;

    public ChatController(ISender sender) => _sender = sender;

    [Authorize(Roles = "Paciente")]
    [HttpPost("mensaje")]
    public async Task<ActionResult<RespuestaChatDto>> EnviarMensaje(
        EnviarMensajeRequest request, CancellationToken ct)
    {
        var command = new EnviarMensajeChatCommand(request.Mensaje, request.Historial ?? new());
        return Ok(await _sender.Send(command, ct));
    }
}