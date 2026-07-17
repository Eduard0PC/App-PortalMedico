using MediatR;
using SistemaCitas.Application.Common.Interfaces;
using SistemaCitas.Domain.Exceptions;
using SistemaCitas.Domain.Interfaces;

namespace SistemaCitas.Application.Auth.Commands.LoginAdministrador;

public sealed class LoginAdministradorCommandHandler
    : IRequestHandler<LoginAdministradorCommand, AuthResponseDto>
{
    private readonly IAdministradorRepository _administradorRepository;
    private readonly IPasswordHasher _passwordHasher;
    private readonly IJwtService _jwtService;

    public LoginAdministradorCommandHandler(
        IAdministradorRepository administradorRepository,
        IPasswordHasher passwordHasher,
        IJwtService jwtService)
    {
        _administradorRepository = administradorRepository;
        _passwordHasher = passwordHasher;
        _jwtService = jwtService;
    }

    public async Task<AuthResponseDto> Handle(LoginAdministradorCommand request, CancellationToken ct)
    {
        var administrador = await _administradorRepository.ObtenerPorCorreoAsync(request.Correo, ct);

        if (administrador is null || !_passwordHasher.Verificar(request.Password, administrador.PasswordHash))
            throw new CredencialesInvalidasException("Correo o contraseña incorrectos.");

        var token = _jwtService.GenerarToken(administrador.Id, administrador.Correo, "Administrador");

        return new AuthResponseDto(
            token,
            administrador.Id,
            administrador.Nombre,
            administrador.Correo,
            "Administrador");
    }
}