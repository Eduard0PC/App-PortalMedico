using MediatR;
using SistemaCitas.Application.Common.Interfaces;
using SistemaCitas.Domain.Exceptions;
using SistemaCitas.Domain.Interfaces;

namespace SistemaCitas.Application.Auth.Commands.LoginPaciente;

public sealed class LoginPacienteCommandHandler : IRequestHandler<LoginPacienteCommand, AuthResponseDto>
{
    private readonly IPacienteRepository _pacienteRepository;
    private readonly IPasswordHasher _passwordHasher;
    private readonly IJwtService _jwtService;

    public LoginPacienteCommandHandler(
        IPacienteRepository pacienteRepository,
        IPasswordHasher passwordHasher,
        IJwtService jwtService)
    {
        _pacienteRepository = pacienteRepository;
        _passwordHasher = passwordHasher;
        _jwtService = jwtService;
    }

    public async Task<AuthResponseDto> Handle(LoginPacienteCommand request, CancellationToken ct)
    {
        var paciente = await _pacienteRepository.ObtenerPorCorreoAsync(request.Correo, ct);

        if (paciente is null || !_passwordHasher.Verificar(request.Password, paciente.PasswordHash))
            throw new CredencialesInvalidasException("Correo o contraseña incorrectos.");

        var token = _jwtService.GenerarToken(paciente.Id, paciente.Correo, "Paciente");

        return new AuthResponseDto(
            token,
            paciente.Id,
            $"{paciente.Nombre} {paciente.Apellido}",
            paciente.Correo,
            "Paciente");
    }
}