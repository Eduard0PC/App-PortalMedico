using FluentValidation;

namespace SistemaCitas.Application.Chat.Commands.EnviarMensajeChat;

public sealed class EnviarMensajeChatCommandValidator : AbstractValidator<EnviarMensajeChatCommand>
{
    public EnviarMensajeChatCommandValidator()
    {
        RuleFor(x => x.Mensaje).NotEmpty().MaximumLength(2000);

        RuleFor(x => x.Historial)
            .Must(h => h.Count <= 20)
            .WithMessage("El historial no puede tener más de 20 mensajes.");

        RuleForEach(x => x.Historial).ChildRules(mensaje =>
        {
            mensaje.RuleFor(m => m.Rol)
                .Must(r => r is "user" or "assistant")
                .WithMessage("El rol de cada mensaje del historial debe ser 'user' o 'assistant'.");

            mensaje.RuleFor(m => m.Contenido).NotEmpty();
        });
    }
}