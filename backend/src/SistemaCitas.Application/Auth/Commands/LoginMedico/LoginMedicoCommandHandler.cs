using MediatR;
using SistemaCitas.Application.Common.Interfaces;
using SistemaCitas.Domain.Exceptions;
using SistemaCitas.Domain.Interfaces;

namespace SistemaCitas.Application.Auth.Commands.LoginMedico;

public sealed class LoginMedicoCommandHandler : IRequestHandler<LoginMedicoCommand, AuthResponseDto>
{
    private readonly IMedicoRepository _medicoRepository;
    private readonly IPasswordHasher _passwordHasher;
    private readonly IJwtService _jwtService;

    public LoginMedicoCommandHandler(
        IMedicoRepository medicoRepository,
        IPasswordHasher passwordHasher,
        IJwtService jwtService)
    {
        _medicoRepository = medicoRepository;
        _passwordHasher = passwordHasher;
        _jwtService = jwtService;
    }

    public async Task<AuthResponseDto> Handle(LoginMedicoCommand request, CancellationToken ct)
    {
        var medico = await _medicoRepository.ObtenerPorCorreoAsync(request.Correo, ct);

        if (medico is null || !_passwordHasher.Verificar(request.Password, medico.PasswordHash))
            throw new CredencialesInvalidasException("Correo o contraseña incorrectos.");

        if (!medico.Activo)
            throw new AccesoDenegadoException("Esta cuenta de médico está desactivada. Contacta al administrador.");

        var token = _jwtService.GenerarToken(medico.Id, medico.Correo, "Medico");

        return new AuthResponseDto(
            token,
            medico.Id,
            $"{medico.Nombre} {medico.Apellido}",
            medico.Correo,
            "Medico");
    }
}