namespace SistemaCitas.Application.Common.Interfaces;

public interface IChatService
{
    Task<string> ObtenerRespuestaAsync(
        string mensaje, List<Chat.MensajeChatDto> historial, CancellationToken ct);
}